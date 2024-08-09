#!/bin/bash

# Enter the directory where the Nextcloud files are located
cd nextcloud

# Create the nextcloud namespace
kubectl create namespace nextcloud

# Define the persistent volumes and the persistent volume claims
# to store the data in case of a pod failure
cd volumes # This directory contains the yaml files for the persistent volumes and the persistent volume claims
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl apply -f nextcloud-pv.yaml -n nextcloud
kubectl apply -f nextcloud-pvc.yaml -n nextcloud
kubectl apply -f nextcloud-postgresql-pv.yaml -n nextcloud
kubectl apply -f nextcloud-postgresql-pvc.yaml -n nextcloud

# Install the Metallb Load Balancer
cd ../metallb # This directory contains the yaml files for the Metallb Load Balancer
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
# Wait for the controller to be available
kubectl wait --for=condition=available --timeout=600s deployment/controller -n metallb-system
# Apply the configuration for the Metallb Load Balancer
kubectl apply -f configmap.yaml
kubectl apply -f ipaddresspool.yaml
kubectl apply -f l2advertisement.yaml

# Create the secrets
cd ../secrets # This directory contains the yaml files for the secrets
kubectl apply -f nextcloud-secrets.yaml -n nextcloud
kubectl apply -f nextcloud-postgresql-secrets.yaml -n nextcloud
kubectl apply -f nextcloud-redis-secrets.yaml -n nextcloud

# Exit the secrets directory
cd ..

# Download the Nextcloud Helm chart and install it
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update
helm install nextcloud-advanced nextcloud/nextcloud -f values.yaml -n nextcloud
