package k8simagepolicy

# Define allowed registries
allowed_registries := {
  "docker.io/library/",
  "gcr.io/",
  "quay.io/",
  "public.ecr.aws/",
  "your-company.registry.com/"
}

# Define blocked registries
blocked_registries := {
  "untrusted.registry.com/"
}

# Get all containers in the pod spec
containers[container] {
  some i
  container := input.review.object.spec.containers[i]
}

containers[container] {
  some i
  container := input.review.object.spec.initContainers[i]
}

# Deny containers with images from blocked registries
deny[msg] {
  container := containers[_]
  image := container.image
  startswith(image, blocked_registry)
  blocked_registry := blocked_registries[_]
  msg := sprintf("Container image %v is from a blocked registry", [image])
}

# Deny containers with images not from allowed registries
deny[msg] {
  container := containers[_]
  image := container.image
  not startswith(image, allowed_registry)
  allowed_registry := allowed_registries[_]
  msg := sprintf("Container image %v is not from an allowed registry", [image])
}

# Deny containers with images using 'latest' tag
deny[msg] {
  container := containers[_]
  image := container.image
  contains(image, ":latest")
  not contains(image, "@")  # Allow images with digest tags
  msg := sprintf("Container image %v uses 'latest' tag which is not allowed", [image])
}

# Deny containers with images without tag or digest
deny[msg] {
  container := containers[_]
  image := container.image
  not contains(image, ":")
  not contains(image, "@")
  msg := sprintf("Container image %v must have a tag or digest", [image])
}

# Allow specific exceptions (for special cases)
allow {
  input.review.object.metadata.annotations["policy.idp.internal/allow-unsigned"] == "true"
}