# NodeJS demo

This folder contains the source code for a simple Cloud Functions implementation that leverages Functions Framework. If you want to walk through the steps from scratch, delete the `node_modules` folder and `src/index.js` file.

You will need a GCP project with Cloud Functions, Cloud Run and GKE enabled to execute the steps in GCP.

**Note:** You should substitute the GCP project id of *your* project, and the region/zone that your project is using!

## Use as-is

```shell
npm install
```

## Start from scratch

### Remove existing implementation

```shell
rm -rf node_modules
echo > src/index.js
```

### Install functions framework

Install functions-framework if starting from scratch.

```shell
npm install --save @google-cloud/functions-framework
```

### Modify package.json

Modify scripts section so that `npm start` will execute functions-framework runtime.

```json
...
"scripts": {
  "start": "Functions-framework --target=hellogdg"
  ...
}
```

### Create the function

Open/create `src/index.js` and create a very simple ExpressJS-like HTTP handler. E.g.

```js
exports.hellogdg = (req, res) => {
    res.send("Hello");
}
```

### Test locally

```shell
npm start
```

## Deploy to Cloud Functions

```shell
gcloud functions deploy hellogdg --project [PROJECT_ID] \
    --region [FUNCTION_REGION] \
    --runtime nodejs10 \
    --trigger-http \
    --set-env-vars MESSAGE="Hello GDG from GCF"
```

## Deploy to Cloud Run

This example is storing the image in a Google Container Repository; substitute for your docker registry or enable GCR in your project.

```shell
docker build -t us.gcr.io/serverless-c0cec1/hellogdg .
docker push us.gcr.io/serverless-c0cec1/hellogdg:latest
gcloud beta run deploy hellogdg --project [PROJECT_ID] \
    --region [CLOUD_RUN_REGION] \
    --image us.gcr.io/serverless-c0cec1/hellogdg:latest \
    --set-env-vars MESSAGE="Hello GDG from Cloud Run"
```

## Deploy to Cloud Run on GKE

```shell
gcloud beta run deploy hellogdg --project [PROJECT_ID] \
    --cluster [CLUSTER_NAME] \
    --cluster-location [CLUSTER_MASTER_ZONE] \
    --image us.gcr.io/serverless-c0cec1/hellogdg:latest \
    --set-env-vars MESSAGE="Hello GDG from Cloud Run on GKE"
```

## Didn't have time to setup custom domain forwarding - use CURL

Get the public IP address of the `istio-ingressgateway` of your cluster from console or via `kubectl`.

```shell
curl -v -H "Host: hellogdg.default.example.com" http://[ISTIO-INGRESSGATEWAY-IP]
```

## Clean up

```shell
gcloud beta run services delete hellogdg \
    --project [PROJECT_ID] \
    --cluster [CLUSTER_NAME] \ --cluster-location [CLUSTER_MASTER_ZONE]
```
