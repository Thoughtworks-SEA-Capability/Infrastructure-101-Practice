# !/usr/bin/env bash

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm install gocd --namespace gocd --values ./values.yaml stable/gocd
