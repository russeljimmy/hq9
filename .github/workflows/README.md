# GitHub Actions Workflows

This directory contains CI/CD workflows for automated building, testing, and publishing of the Thorium VNC Server Docker image.

## Workflows

### 1. build.yml - Build & Test Pipeline

**Triggers**: Push to main, PRs, manual dispatch  
**Duration**: ~15-20 minutes

#### Steps:

1. **Validate Configuration**
   - Dockerfile syntax check (hadolint)
   - Docker Compose configuration validation
   - File permissions verification

2. **Build Docker Image**
   - Sets up Docker BuildX
   - Builds image with caching
   - Optimizes layers

3. **Security Scanning**
   - Trivy vulnerability scanner
   - SARIF report generation
   - GitHub Security tab integration

4. **Documentation Verification**
   - README.md existence
   - BUILD_GUIDE.md existence
   - TESTING.md existence
   - Key content verification (VNC, Docker, access info)

#### Status Checks:

- ✅ Dockerfile validates
- ✅ Configuration valid
- ✅ Build succeeds
- ✅ Documentation complete
- ✅ No vulnerabilities (warnings allowed)

### 2. publish.yml - Docker Registry Publish

**Triggers**: Tag pushed (v*), manual dispatch  
**Duration**: ~15-20 minutes

#### Prerequisites:

Set these secrets in GitHub repo (Settings → Secrets):

```
DOCKER_USERNAME        # Docker Hub username
DOCKER_PASSWORD        # Docker Hub personal access token
```

#### Publishes To:

1. **GitHub Container Registry (ghcr.io)**
   - Always publishes
   - Uses GitHub token (automatic)
   - Tags: `latest`, `v1.0.0`, etc.

2. **Docker Hub** (optional)
   - Requires DOCKER_USERNAME & DOCKER_PASSWORD secrets
   - Tags: `latest`, version tags, etc.

#### Release Creation:

- Creates GitHub Release for each tag
- Includes access instructions
- Provides quick-start guide

## Configuration

### Environment Variables

Workflows automatically use:
- `github.ref` - Git reference (branch/tag)
- `github.actor` - Username pushing changes
- `github.token` - GitHub API token (automatic)

### Cache Management

Both workflows use BuildKit cache:
- Caches intermediate layers
- Reduces build time on repeats
- GitHub Actions cache automatically managed

## Usage

### Automatic Testing (on push)

```bash
git push origin main
# Automatically runs build.yml
# Check "Actions" tab in GitHub
```

### Manual Testing

1. Go to GitHub repository
2. Click "Actions" tab
3. Select "Build and Test Docker Image"
4. Click "Run workflow"
5. Wait for completion

### Publishing Release

```bash
git tag v1.0.0
git push origin v1.0.0
# Automatically runs publish.yml
# Creates GitHub Release
# Publishes Docker images
```

### Push to Docker Hub

1. Add secrets to GitHub (if not done)
2. Tag and push as above
3. Check Docker Hub registry

## Troubleshooting

### Build Fails

1. Check build logs in GitHub Actions
2. Look for "ERROR" messages
3. Review Dockerfile changes
4. Test locally: `docker build .`

### Publish Fails

1. Verify secrets are set correctly
2. Check Docker credentials valid
3. Review publish.yml logs
4. Try manual test build first

### Vulnerability Scan Issues

- Warnings are allowed (won't block merge)
- Critical issues block workflow
- Review Trivy report
- Update base image if needed

## Best Practices

### For Contributors

1. Each push triggers build.yml
2. All checks must pass for merge
3. Fix any failed checks
4. Use meaningful commit messages

### For Maintainers

1. Ensure secrets are protected
2. Review security scan results
3. Test publish workflow before release
4. Keep base images updated
5. Monitor for dependency updates

## Advanced Configuration

### Change Build Triggers

Edit workflow yaml:
```yaml
on:
  push:
    branches: [ main, develop ]  # Add branches
    paths:
      - 'Dockerfile'             # Add/remove paths
```

### Add Push to Docker Hub

Set secrets first, then uncomment in publish.yml:
```yaml
- name: Push to Docker Hub
  uses: docker/build-push-action@v4
  with:
    tags: |
      ${{ secrets.DOCKER_USERNAME }}/thorium-vnc:latest
```

### Add Slack Notifications

Add step to workflow:
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    status: ${{ job.status }}
```

## File Structure

```
.github/
└── workflows/
    ├── build.yml       # Build & test on push
    └── publish.yml     # Publish on release
```

## Integration Points

### GitHub Features

- **Branches Protection**: Can require passing checks
- **PR Reviews**: Gate merges with workflow status
- **Release Notes**: Auto-populate from workflow
- **Deployment**: Trigger via workflow dispatch

### External Services

- **Docker Hub**: Image registry
- **GitHub Container Registry**: Built-in
- **Trivy**: Security scanning
- **BuildKit**: Advanced Docker builds

## Monitoring

### GitHub Actions Dashboard

- Monitor workflow runs
- View step-by-step logs
- Download artifacts (if added)
- Re-run failed jobs

### Notifications

- Email on workflow failure (default)
- Watch for CRITICAL security issues
- Subscribe to release notifications

## Maintenance

### Regular Updates

1. Keep base image updated quarterly
2. Review and update dependencies
3. Test new Docker features
4. Keep GitHub Actions updated

### Security Review

Monthly:
- Review Trivy scan results
- Check for critical CVEs
- Update vulnerable packages
- Audit secrets access

## Useful Commands

```bash
# View local workflow
cat .github/workflows/build.yml

# Validate workflow syntax
docker run --rm -i ghcr.io/rhysd/actionlint < .github/workflows/build.yml

# Test action locally (requires act)
act -j build
```

## Resources

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Docker Build&Push Action](https://github.com/docker/build-push-action)
- [Trivy Action](https://github.com/aquasecurity/trivy-action)
- [Docker BuildKit](https://docs.docker.com/build/buildkit/)

## Support

For workflow issues:
1. Check workflow logs in Actions tab
2. Review each step for errors
3. Test locally if possible
4. Check GitHub Actions status page
5. Review relevant documentation

---

**Last Updated**: 2026-04-22  
**Status**: ✅ Ready for use
