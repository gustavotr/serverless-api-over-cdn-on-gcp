provider "google" {
  project = var.PROJECT_NAME
  region  = var.REGION
  zone    = "us-central1-c"
}

data "google_project" "project" {
}

locals {
   project_number = data.google_project.project.number
}

###
### STORAGE
###
resource "google_storage_bucket" "bucket" {
  name = var.BUCKET_NAME
}

resource "google_storage_bucket_object" "archive" {
  name   = "hello.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./function/hello/hello.zip"
}

###
### FUNCTION
###
resource "google_cloudfunctions_function" "hello_function" {
  name        = "hello"
  description = "Hello function"
  runtime     = "nodejs10"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "helloGET"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.hello_function.project
  region         = google_cloudfunctions_function.hello_function.region
  cloud_function = google_cloudfunctions_function.hello_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${local.project_number}-compute@developer.gserviceaccount.com"
}

###
### HTML
###
resource "google_storage_bucket_object" "html" {
  name   = "html/index.html"
  source = "./storage/index.html"
  bucket = var.BUCKET_NAME

  depends_on = [
    google_cloudfunctions_function.hello_function,
  ]
}

resource "google_storage_object_acl" "html" {
  bucket = google_storage_bucket.bucket.name
  object = google_storage_bucket_object.html.output_name

  role_entity = [
    "READER:allUsers",
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

###
### CLOUD RUN
###
resource "google_cloud_run_service" "default" {
  name     = var.CLOUD_RUN_SERVICE
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/endpoints-release/endpoints-runtime-serverless:2"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

locals {
  cloud_run_url = google_cloud_run_service.default.status[0].url
  cloud_run_host = replace(google_cloud_run_service.default.status[0].url, "https://", "")
}

output "cloud_run_host" {
  value = local.cloud_run_host
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

###
### ENDPOINTS
###
resource "google_endpoints_service" "openapi_service" {
  service_name   = replace(local.cloud_run_url, "https://", "")
  project        = var.PROJECT_NAME
  openapi_config = templatefile("openapi_template.yml", { HOST = local.cloud_run_host, FUNCTION = "https://${var.REGION}-${var.PROJECT_NAME}.cloudfunctions.net/${google_cloudfunctions_function.hello_function.name}" })

  depends_on = [
    google_cloud_run_service.default,
  ]
}

output "endpoint_config" {
  value = google_endpoints_service.openapi_service.config_id
}
