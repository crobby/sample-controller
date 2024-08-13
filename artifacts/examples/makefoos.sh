#!/bin/bash

# Array to store the names of created Foo objects
created_foos=()

# Function to clean up all Foo objects created by the script
cleanup() {
  echo "Cleaning up Foo objects..."
  for name in "${created_foos[@]}"; do
    kubectl delete foo "$name"
  done
}

# Trap INT (Ctrl+C) and TERM signals to clean up before exiting
trap cleanup INT TERM

# Create the initial example-foo object
kubectl apply -f - <<EOF
apiVersion: samplecontroller.k8s.io/v1alpha1
kind: Foo
metadata:
  name: example-foo
spec:
  IDs:
    - id1
    - id2
EOF

# Add the initial foo to the list of created objects
created_foos+=("example-foo")

# Create additional Foo objects with different IDs
for i in {1..50}; do
  name="example-foo-$i"
  kubectl apply -f - <<EOF
apiVersion: samplecontroller.k8s.io/v1alpha1
kind: Foo
metadata:
  name: $name
spec:
  IDs:
    - id${i}1
    - id${i}2
EOF
  created_foos+=("$name")
  sleep 1
done

# Modify Foo objects
end_time=$((SECONDS + 3600))
while [ $SECONDS -lt $end_time ]; do
  for name in "${created_foos[@]}"; do
    if [ "$name" == "example-foo" ]; then
      if [ "$((RANDOM % 2))" -eq 0 ]; then
        kubectl patch foo "$name" --type='json' -p='[{"op": "replace", "path": "/spec/IDs", "value": ["id1", "id2"]}]'
      else
        kubectl patch foo "$name" --type='json' -p='[{"op": "replace", "path": "/spec/IDs", "value": ["id1", "id3"]}]'
      fi
    else
      kubectl patch foo "$name" --type='json' -p="[{\"op\": \"replace\", \"path\": \"/spec/IDs\", \"value\": [\"id$((RANDOM % 5 + 1))1\", \"id$((RANDOM % 5 + 1))2\"]}]"
    fi
  done
  sleep 3
done

# Clean up Foo objects
cleanup
