# NodeJS demo

## Functions framework

```shell
npm install --save @google-cloud/functions-framework
```

### package.json

* start: "ENV MESSAGE='Hello GDG from local runner' functions-framework --target=hellogdg"

## Deploy to Cloud Functions

```shell
gcloud functions deploy hellogdg --project serverless-c0cec1 \
    --region us-central1 \
    --runtime nodejs10 \
    --trigger-http \
    --set-env-vars MESSAGE="Hello GDG from GCF"
```

## Deploy to Cloud Run

```shell
docker build -t us.gcr.io/serverless-c0cec1/hellogdg .
docker push us.gcr.io/serverless-c0cec1/hellogdg:latest
gcloud beta run deploy hellogdg --project serverless-c0cec1 \
    --region us-central1 \
    --image us.gcr.io/serverless-c0cec1/hellogdg:latest \
    --set-env-vars MESSAGE="Hello GDG from Cloud Run"
```

## Deploy to Cloud Run on GKE

```shell
gcloud beta run deploy hellogdg --project serverless-c0cec1 \
    --cluster run-on-gke \
    --cluster-location us-west1-a \
    --image us.gcr.io/serverless-c0cec1/hellogdg:latest \
    --set-env-vars MESSAGE="Hello GDG from Cloud Run on GKE"
```

## Didn't have time to setup custom domain forwarding - use CURL

```shell
curl -v -H "Host: hellogdg.default.example.com" http://34.83.242.225
```

## Clean up

```shell
gcloud beta run services delete hellogdg --cluster run-on-gke --cluster-location us-west1-a
```
