# Policy Management

This directory contains policy-as-code configurations for the Internal Developer Platform using Open Policy Agent (OPA) and Gatekeeper.

## Directory Structure

```
policies/
├── opa/
│   ├── required-labels.rego
│   ├── image-policy.rego
│   └── resource-limits.rego
└── README.md
```

## Policy Definitions

### Required Labels Policy (`required-labels.rego`)

This policy enforces that all Kubernetes resources have required labels:

- **Workload Resources** (Deployments, StatefulSets, DaemonSets, Services):
  - `app.kubernetes.io/name`
  - `app.kubernetes.io/instance`
  - `app.kubernetes.io/component`
  - `app.kubernetes.io/managed-by`

- **Namespaces**:
  - `environment`
  - `team`
  - `cost-center`

### Image Policy (`image-policy.rego`)

This policy ensures container images meet security requirements:

- Images must be from approved registries
- Images must not be from blocked registries
- Images must not use the `:latest` tag
- Images must have either a tag or digest specified

### Resource Limits Policy (`resource-limits.rego`)

This policy enforces proper resource management:

- All containers must specify resource limits and/or requests
- CPU and memory limits must not exceed maximum allowed values
- CPU and memory requests must not exceed maximum allowed values

## Policy Enforcement

These policies are enforced using OPA Gatekeeper in the Kubernetes cluster. When a resource is created or updated, Gatekeeper evaluates the resource against all applicable policies. If any policy denies the resource, the operation is rejected with an appropriate error message.

## Policy Testing

To test these policies locally:

```bash
# Install OPA
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod +x opa

# Test a policy
./opa eval --data policies/opa/ --input test-input.json "data.k8srequiredlabels.deny"
```

## Policy Updates

To update policies:

1. Modify the relevant `.rego` file
2. Test the policy locally
3. Commit the changes to version control
4. The policy will be automatically applied to the cluster via GitOps

## Custom Exceptions

Some policies allow for exceptions using annotations:

- `policy.idp.internal/allow-unsigned: "true"` - Allows unsigned images in special cases

## Best Practices

- Always test policies in development before applying to production
- Use clear and descriptive error messages
- Document the purpose of each policy
- Regularly review and update policies based on changing requirements
- Use policy parameters for configuration where appropriate