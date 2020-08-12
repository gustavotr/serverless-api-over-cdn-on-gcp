#!/bin/bash

if [[ ! -f .env ]] ; then
    echo 'File ".env" does not exists, aborting.'
    exit
fi

export $(cat .env)

cd function/hello
zip -r hello.zip ./*

cd ../..

terraform apply -auto-approve

bash ./scripts/gcloud_build_image.sh \
  -s $(terraform output cloud_run_host) \
  -c $(terraform output endpoint_config) \
  -p $TF_VAR_PROJECT_NAME \
  -r $TF_VAR_CLOUD_RUN_SERVICE

gcloud beta compute network-endpoint-groups create serverless-neg \
    --region=$TF_VAR_REGION \
    --network-endpoint-type=SERVERLESS  \
    --cloud-run-service=$TF_VAR_CLOUD_RUN_SERVICE

gcloud compute backend-services create api-backend-service \
    --global

gcloud beta compute backend-services add-backend api-backend-service \
    --global \
    --network-endpoint-group=serverless-neg \
    --network-endpoint-group-region=$TF_VAR_REGION

gcloud compute url-maps create api-url-map \
    --default-service api-backend-service

gcloud compute target-https-proxies create api-https-proxy \
    --ssl-certificates=www-ssl-cert \
    --url-map=api-url-map

gcloud compute forwarding-rules create https-content-rule \
    --address=$(terraform output ip_address) \
    --target-https-proxy=api-https-proxy \
    --global \
    --ports=443

gcloud compute backend-services update api-backend-service \
    --enable-cdn \
    --global






