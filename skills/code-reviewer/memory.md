# Code Reviewer Skill - Memory

## Created
2026-02-13 by Edgar

## Features
- PR analysis and review
- Commit review
- Security vulnerability detection
- Performance optimization suggestions
- Code quality checks
- Documentation review

## Supported Languages
- Swift
- TypeScript
- Python  
- Go
- Rust
- Java
- Kotlin

## Usage Examples
- `@Edgar review pr owner/repo/123`
- `@Edgar review commits owner/repo`
- `@Edgar security-scan pr owner/repo/64`

## Configuration
- GITHUB_TOKEN for private repos
- REVIEW_FOCUS: security, performance, bugs
- EXCLUDE_PATTERNS for skipping files
- CHECKS: typos, security, performance, style, tests

## Limitations
- Max 50 files per review
- Max 2000 lines per file
- 50,000 tokens limit per review
