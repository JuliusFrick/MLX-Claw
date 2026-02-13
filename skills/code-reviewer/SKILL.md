# Code Reviewer Skill

**Author:** Edgar  
**Version:** 1.0.0  
**Description:** AI-powered code review for pull requests, commits, and code analysis

## Overview

This skill provides intelligent code review capabilities for GitHub repositories, analyzing:
- Pull requests
- Commits  
- Code quality issues
- Security vulnerabilities
- Performance concerns
- Documentation gaps

## Setup

### GitHub Token (Optional)
For private repos or higher rate limits, set a GitHub token:
```bash
export GITHUB_TOKEN="ghp_xxxx"
```

### Configuration (Optional)
```bash
# Review focus areas
REVIEW_FOCUS="security,performance,bugs"

# Exclude patterns  
EXCLUDE_PATTERNS="**/*.lock,**/Pods/**"

# Enable specific checks
CHECKS="typos,security,performance,style,tests"
```

## Usage

### Analyze a Pull Request
```
@Edgar review pr <owner>/<repo>/<pr-number>
@Edgar review pr JuliusFrick/DailyDigest/64
```

### Review Recent Commits
```
@Edgar review commits <owner>/<repo>
@Edgar review commits --since="1 week ago"
```

### Review Specific Files
```
@Edgar review files <owner>/<repo> <file1> <file2>
@Edgar review diff <owner>/<repo>/commit/<sha>
```

### Quick Code Analysis
```
@Edgar analyze code "<code snippet>"
@Edgar suggest improvements for "<code>"
```

## Output Format

The skill returns a structured review:

```
## 📋 Review Summary
- **Files Changed:** 12
- **Lines Added:** +234
- **Lines Removed:** -89
- **Risk Level:** 🟡 Medium

## ✅ Strengths
- Clean separation of concerns
- Good error handling patterns
- Comprehensive test coverage

## ⚠️ Issues Found

### 🐛 Bugs (3)
1. [File] Line 45 - Potential nil unwrap
2. [File] Line 78 - Off-by-one error in loop
3. [File] Line 112 - Missing null check

### ⚡ Performance (2)
1. [File] Line 23 - O(n²) operation
2. [File] Line 67 - Redundant API call

### 🔒 Security (1)
1. [File] Line 90 - Hardcoded API key

### 📝 Style (4)
1. Use consistent naming convention
2. Add documentation comments
3. Split long functions
4. Consider using guard statements

## 💡 Suggestions
1. Extract helper functions for repeated logic
2. Add integration tests for edge cases
3. Consider caching expensive operations

## 📊 Files Requiring Attention
- `src/core/service.ts` (High)
- `src/utils/helpers.ts` (Medium)
- `tests/integration.spec.ts` (Low)
```

## Focus Areas

### Security Checks
- Hardcoded secrets/credentials
- SQL injection vulnerabilities
- XSS attack vectors
- Insecure deserialization
- Authentication bypass patterns
- Authorization issues

### Performance Checks  
- N+1 query patterns
- Unnecessary re-renders
- Memory leaks
- Inefficient loops
- Missing indexes/optimizations
- Large bundle sizes

### Code Quality
- Code duplication
- Complex functions (high cyclomatic complexity)
- Missing tests
- Poor naming conventions
- Long parameter lists
- Feature envy

### Best Practices
- SOLID principles violations
- DRY principle violations
- Proper error handling
- Async/await patterns
- Dependency injection
- Logging and monitoring

## Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `--focus` | Review focus area | all |
| `--files` | Specific files to review | all changed |
| `--format` | Output format (text,json,markdown) | markdown |
| `--max-comments` | Max review comments | 50 |
| `--auto-approve` | Auto-approve safe PRs | false |

## Examples

### Full PR Review
```bash
@Edgar review pr owner/repo/123 --focus=security,performance
```

### Quick Security Scan
```bash
@Edgar security-scan pr owner/repo/64
```

### Diff Review
```bash
@Edgar review diff --repo=owner/repo --commit=abc123
```

### Analyze Local Changes
```bash
@Edgar review local --staged
```

## Limitations

- Maximum files per review: 50
- Maximum lines per file: 2000
- Token limit: 50,000 tokens per review
- Supported languages: Swift, TypeScript, Python, Go, Rust, Java, Kotlin

## Requirements

- GitHub CLI (`gh`) installed and authenticated
- Repository cloned locally (for file-based reviews)
- Git configuration set up

## Troubleshooting

**"Repository not found"**
- Check GitHub authentication: `gh auth status`
- Verify repository exists and is accessible

**"Rate limit exceeded"**
- Set GitHub token for higher limits
- Wait 1 hour for reset

**"No changes to review"**
- PR may be empty or already merged
- Check if commits are pushed

**"File too large"**
- Files over 2000 lines are skipped
- Review specific functions instead
