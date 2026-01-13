package k8sresourcelimits

# Define default resource limits
default_cpu_limit := "500m"
default_memory_limit := "512Mi"
default_cpu_request := "100m"
default_memory_request := "128Mi"

# Maximum allowed resources
max_cpu_limit := "4"
max_memory_limit := "8Gi"
max_cpu_request := "2"
max_memory_request := "4Gi"

# Get all containers in the pod spec
containers[container] {
  some i
  container := input.review.object.spec.containers[i]
}

containers[container] {
  some i
  container := input.review.object.spec.initContainers[i]
}

# Check if resources are specified
resources_not_specified[container] {
  container := containers[_]
  not container.resources
}

resources_not_specified[container] {
  container := containers[_]
  container.resources
  not container.resources.limits
  not container.resources.requests
}

# Deny if no resource limits or requests are specified
deny[msg] {
  container := resources_not_specified[_]
  msg := sprintf("Container '%v' must specify resource limits and/or requests", [container.name])
}

# Check CPU limits
deny[msg] {
  container := containers[_]
  limits := container.resources.limits
  cpu_limit := limits.cpu
  parsed_cpu_limit := parse_cpu(cpu_limit)
  max_allowed_cpu := parse_cpu(max_cpu_limit)
  parsed_cpu_limit > max_allowed_cpu
  msg := sprintf("Container '%v' CPU limit %v exceeds maximum allowed %v", [container.name, cpu_limit, max_cpu_limit])
}

# Check memory limits
deny[msg] {
  container := containers[_]
  limits := container.resources.limits
  memory_limit := limits.memory
  parsed_memory_limit := parse_memory(memory_limit)
  max_allowed_memory := parse_memory(max_memory_limit)
  parsed_memory_limit > max_allowed_memory
  msg := sprintf("Container '%v' memory limit %v exceeds maximum allowed %v", [container.name, memory_limit, max_memory_limit])
}

# Check CPU requests
deny[msg] {
  container := containers[_]
  requests := container.resources.requests
  cpu_request := requests.cpu
  parsed_cpu_request := parse_cpu(cpu_request)
  max_allowed_cpu := parse_cpu(max_cpu_request)
  parsed_cpu_request > max_allowed_cpu
  msg := sprintf("Container '%v' CPU request %v exceeds maximum allowed %v", [container.name, cpu_request, max_cpu_request])
}

# Check memory requests
deny[msg] {
  container := containers[_]
  requests := container.resources.requests
  memory_request := requests.memory
  parsed_memory_request := parse_memory(memory_request)
  max_allowed_memory := parse_memory(max_memory_request)
  parsed_memory_request > max_allowed_memory
  msg := sprintf("Container '%v' memory request %v exceeds maximum allowed %v", [container.name, memory_request, max_memory_request])
}

# Helper function to parse CPU values
parse_cpu(cpu_str) = cpu_float {
  is_string(cpu_str)
  endswith(cpu_str, "m")
  cpu_val := builtin.trim_suffix(cpu_str, "m")
  cpu_float := cast.to_number(cpu_val) / 1000
}

parse_cpu(cpu_str) = cpu_float {
  is_string(cpu_str)
  not endswith(cpu_str, "m")
  cpu_float := cast.to_number(cpu_str)
}

# Helper function to parse memory values
parse_memory(mem_str) = mem_bytes {
  is_string(mem_str)
  endswith(mem_str, "Ki")
  mem_val := builtin.trim_suffix(mem_str, "Ki")
  num_val := cast.to_number(mem_val)
  mem_bytes := num_val * 1024
}

parse_memory(mem_str) = mem_bytes {
  is_string(mem_str)
  endswith(mem_str, "Mi")
  mem_val := builtin.trim_suffix(mem_str, "Mi")
  num_val := cast.to_number(mem_val)
  mem_bytes := num_val * 1024 * 1024
}

parse_memory(mem_str) = mem_bytes {
  is_string(mem_str)
  endswith(mem_str, "Gi")
  mem_val := builtin.trim_suffix(mem_str, "Gi")
  num_val := cast.to_number(mem_val)
  mem_bytes := num_val * 1024 * 1024 * 1024
}

parse_memory(mem_str) = mem_bytes {
  is_string(mem_str)
  not endswith(mem_str, "Ki")
  not endswith(mem_str, "Mi")
  not endswith(mem_str, "Gi")
  mem_bytes := cast.to_number(mem_str)
}