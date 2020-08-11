# Serverless API over CDN on GCP

This is a simple test on how to set a Serverless API with SSR over a CDN using Google Cloud Platform.

## Requirements

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts)
- [Docker](https://www.docker.com/)
- [Terraform](https://www.terraform.io/downloads.html)

## Before Deploy

Rename the `.env.sample` file to just `.env` and edit to your preferences.

Run `gcloud auth login` to make sure you have access to your Google Cloud account.

## Deploying

Run `bash main.sh` to deploy.

## Links

[Serverless CDN Configuration on GCP](https://cloud.google.com/load-balancing/docs/negs/setting-up-serverless-negs#gcloud-using-curl)