package k8srequiredlabels

# Define the required labels for different kinds of resources
required := {
  "workload": ["app.kubernetes.io/name", "app.kubernetes.io/instance", "app.kubernetes.io/component", "app.kubernetes.io/managed-by"],
  "environment": ["environment", "team", "cost-center"]
}

# Get the resource kind
resourceKind := input.review.object.kind

# Get the resource metadata
resourceMetadata := input.review.object.metadata

# Check if the resource has required labels based on its kind
deny[msg] {
  resourceKind == "Deployment"
  missing := missing_labels(required["workload"], resourceMetadata.labels)
  count(missing) > 0
  msg := sprintf("Deployment is missing required labels: %v", [missing])
}

deny[msg] {
  resourceKind == "StatefulSet"
  missing := missing_labels(required["workload"], resourceMetadata.labels)
  count(missing) > 0
  msg := sprintf("StatefulSet is missing required labels: %v", [missing])
}

deny[msg] {
  resourceKind == "DaemonSet"
  missing := missing_labels(required["workload"], resourceMetadata.labels)
  count(missing) > 0
  msg := sprintf("DaemonSet is missing required labels: %v", [missing])
}

deny[msg] {
  resourceKind == "Service"
  missing := missing_labels(required["workload"], resourceMetadata.labels)
  count(missing) > 0
  msg := sprintf("Service is missing required labels: %v", [missing])
}

# Special handling for namespaces
deny[msg] {
  resourceKind == "Namespace"
  missing := missing_labels(required["environment"], resourceMetadata.labels)
  count(missing) > 0
  msg := sprintf("Namespace is missing required labels: %v", [missing])
}

# Helper function to find missing labels
missing_labels(required, provided) = missing {
  provided_set = {label | label := provided[_]}
  required_set = {label | label := required[_]}
  missing = difference(required_set, provided_set)
}