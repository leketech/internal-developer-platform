# Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the Internal Developer Platform.

## Service Not Deploying

### Check ArgoCD Status
1. Navigate to the ArgoCD dashboard
2. Look for your application in the list
3. Check the sync status and health status
4. Review any error messages

### Common ArgoCD Issues
- **OutOfSync**: The cluster state doesn't match Git
- **Progressing**: The deployment is still in progress
- **Degraded**: The deployment failed or is unhealthy
- **Missing**: Required resources are not found

### Check CI/CD Pipeline
1. Go to your repository's Actions tab
2. Review the latest workflow runs
3. Check for any failed steps
4. Examine logs for error details

## Performance Issues

### High Resource Usage
- Check resource limits and requests in your deployment
- Review application logs for performance bottlenecks
- Monitor database queries if applicable
- Consider scaling options

### Slow Response Times
- Check for external service dependencies
- Review database performance
- Monitor network latency
- Check for memory leaks

## Security Issues

### Access Denied
- Verify your permissions in the platform
- Check if your GitHub account is linked properly
- Ensure your team is properly configured in the catalog
- Contact platform administrators if needed

### Image Vulnerabilities
- Review security scan results in CI/CD logs
- Update dependencies to patched versions
- Consider using different base images
- Follow security team recommendations

## Configuration Issues

### Environment Variables Not Working
- Verify environment variables are properly configured
- Check if they're defined in the correct scope
- Ensure secrets are properly stored and referenced
- Review the deployment manifest

### Service Dependencies
- Confirm dependent services are running
- Check network connectivity between services
- Verify service discovery is working
- Review any required configurations

## Debugging Steps

### 1. Check the Logs
```bash
kubectl logs -n <namespace> <pod-name>
```

### 2. Describe the Resources
```bash
kubectl describe -n <namespace> <resource-type> <resource-name>
```

### 3. Check Resource Status
```bash
kubectl get -n <namespace> <resource-type> <resource-name>
```

### 4. Port Forward for Testing
```bash
kubectl port-forward -n <namespace> <pod-name> <local-port>:<container-port>
```

## Common Solutions

### Force ArgoCD Sync
1. In ArgoCD dashboard, select your application
2. Click "Sync" button
3. Confirm the sync operation

### Rollback Deployment
1. Identify the previous stable deployment
2. Use ArgoCD to rollback to that version
3. Monitor the rollback process

### Redeploy from CI/CD
1. Trigger a new build in GitHub Actions
2. Verify the new deployment
3. Monitor for any issues

## Getting Help

### When to Contact Platform Team
- Infrastructure issues affecting multiple services
- Platform configuration problems
- Security concerns
- Performance issues with the platform itself

### Support Channels
- **Slack**: #platform-support channel
- **Jira**: Create a ticket in the platform project
- **Email**: platform-team@company.com

### Information to Provide
- Service name and namespace
- Error messages received
- Steps to reproduce the issue
- Time when the issue occurred
- Any recent changes made