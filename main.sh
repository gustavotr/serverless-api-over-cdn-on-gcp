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


