#!/usr/bin/env bash

kubectl delete service webhook-server -n webhook-demo
kubectl delete deployment webhook-server -n webhook-demo
kubectl delete secret webhook-server-tls -n webhook-demo
kubectl delete MutatingWebhookConfiguration demo-webhook
kubectl delete namespace webhook-demo
