#!/bin/bash -e

# Fix error 
# https://stackoverflow.com/questions/59484509/node-had-taints-that-the-pod-didnt-tolerate-error-when-deploying-to-kubernetes
for node in $(kubectl get nodes --selector='kubernetes.io/hostname' | awk 'NR>1 {print $1}' ) ; do
    kubectl taint nodes $node node-role.kubernetes.io/master- ;
done