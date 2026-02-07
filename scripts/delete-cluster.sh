#!/bin/bash
echo "Deleting cluster 'k8s-lab'..."
kind delete cluster --name k8s-lab
echo "Done!"
