# Contributing to HQ9 - Thorium VNC Browser

Thank you for interest in contributing! Here are the guidelines.

## How to Contribute

### Reporting Bugs

1. Check existing issues first
2. Create a new issue with:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment info (OS, Docker version, etc.)
   - Logs if available

### Suggesting Features

1. Open an issue with label `enhancement`
2. Describe the feature and why it would be useful
3. Provide examples if possible

### Submitting Changes

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test thoroughly (see TESTING.md)
5. Commit with clear messages: `git commit -am "Add feature description"`
6. Push to your fork: `git push origin feature/your-feature`
7. Open a Pull Request

## Development Setup

```bash
# Clone the repository
git clone https://github.com/russeljimmy/hq9.git
cd hq9

# Build the image
docker-compose build

# Start development
docker-compose up -d

# Access logs
docker-compose logs -f
```

## Code Contributions

### Scripts (shell, Python, etc.)

- Use clear variable names
- Add comments for complex logic
- Follow existing code style
- Test on multiple systems if possible

### Dockerfile

- Keep it clean and ordered
- Use `--no-cache` comments where appropriate
- Minimize layer count
- Document non-obvious steps

### Documentation

- Use clear, simple English
- Include examples
- Keep lines reasonably short
- Update table of contents if adding sections
- Include code blocks with syntax highlighting

## Testing Requirements

Before submitting:

```bash
# Validate configuration
docker-compose config
docker build --dry-run .

# Run full test suite
bash test.sh

# Or use make
make status
make test-connectivity

# Verify no errors in logs
docker-compose logs | grep -i error
```

## Commit Message Guidelines

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move file to..." not "Moves file to...")
- Limit first line to 72 characters
- Reference issues when applicable: "Fix #123"

Examples:
```
Add GPU support configuration
Fix entrypoint script crash on Alpine
Update documentation for SSL setup
Improve performance by reducing color depth
```

## Pull Request Process

1. Update README if adding features
2. Update TESTING.md with new test cases
3. Ensure all GitHub Actions pass
4. Provide description of changes
5. Link related issues
6. Request review from maintainers
7. Be open to feedback

## Documentation Updates

When updating docs:
- Keep QUICK_START.md concise
- Update README.md for major changes
- Add detailed info to BUILD_GUIDE.md
- Include examples in TESTING.md

## Performance Considerations

- Test memory usage: `docker stats`
- Check startup time
- Verify network efficiency
- Test with different resolutions
- Monitor CPU usage over time

## Areas Needing Help

- [ ] Thorium browser direct integration (not just Chromium)
- [ ] Performance optimizations
- [ ] Additional platform support (Mac M1, ARM)
- [ ] Automated testing improvements
- [ ] Docker Hub registry integration
- [ ] Kubernetes manifests
- [ ] Documentation translations

## Code of Conduct

- Be respectful and inclusive
- No harassment or discrimination
- Constructive feedback only
- Respect others' time and effort

## License

By contributing, you agree your code will be licensed under the MIT License.

## Questions?

Open an issue labeled `question` or start a discussion.

Thank you for helping make this project better! 🚀
