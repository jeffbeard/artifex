# Claude Code Guidelines for Artifex

This document contains instructions and guidelines for Claude Code when working with the Artifex repository.

## Pull Request Management

**IMPORTANT: Merging pull requests is always a human task.**

When creating pull requests:
- Create the PR with appropriate title and description
- Provide the PR URL to the user
- DO NOT merge the PR automatically
- Wait for human review and approval before any merge occurs

## Repository Purpose

Artifex is a personal collection of Claude Code skills created largely by Claude to enhance productivity and intelligent automation.

## Skill Development

When adding or updating skills in this repository:
1. Place skills in the `skills/` directory
2. Each skill should have a `SKILL.md` file with proper YAML frontmatter
3. Include clear documentation with examples
4. Test the skill before committing
5. Update the README.md to document new skills

## Commit Messages

Follow conventional commit format and include the Claude Code attribution:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```
