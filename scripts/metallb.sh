#!/bin/bash
#

# Install MetalLB

helm upgrade --install metallb metallb \
  --repo https://metallb.github.io/metallb \
  --namespace metallb-system --create-namespace
  
  while kubectl -n metallb-system get pods -A -l app.kubernetes.io/name=metallb | awk 'split($3, a, "/") && a[1] != a[2] { print $0; }' | grep -v "RESTARTS"; do
    echo 'Waiting for MetalLB Controller to be ready...'
    sleep 5
  done
  echo 'MetalLB Controller is ready. Creating ip pool...'

  cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ip-pool
  namespace: metallb-system
spec:
  addresses:
  - 10.10.0.100-10.10.0.200
EOF

  cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: ip-pool-advert
  namespace: metallb-system
spec:
  ipAddressPools:
  - ip-pool
EOF