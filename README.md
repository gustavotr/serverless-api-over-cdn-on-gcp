# Serverless API over CDN on GCP

This is a simple test on how to set a Serverless API with SSR over a CDN using Google Cloud Platform.

## Requirements

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts)
- [Docker](https://www.docker.com/)
- [Terraform](https://www.terraform.io/downloads.html)

## Before Deploy

Rename the `.env.sample` file to just `.env` and edit to your preferences.

Run `gcloud auth login` to make sure you have access to your Google Cloud account.

Make sure you have an SSL certificate resource ready for use. You can generate one by running the command bellow replacing `[DOMAIN]` with your own:

```bash
gcloud compute ssl-certificates create www-ssl-cert \
  --domains [DOMAIN]
```

Google will manage the certificate creation but this could take up to 60 mins.

Alternatively you can use you own signed certificate to create an SSL resource by running the following:

```bash
gcloud compute ssl-certificates create www-ssl-cert \
  --certificate [CRT_FILE_PATH] \
  --private-key [KEY_FILE_PATH]
```


## Deploying

Run `bash main.sh` to deploy.

## Links

[Serverless CDN Configuration on GCP](https://cloud.google.com/load-balancing/docs/negs/setting-up-serverless-negs#gcloud-using-curl)