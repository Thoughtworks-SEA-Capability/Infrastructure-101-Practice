#!/usr/bin/env bash

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm install gocd --namespace gocd --values ./gocd/values.yaml stable/gocd
