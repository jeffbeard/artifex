# Artifex

> *Latin: craftsman, artist, maker*

A collection of Claude Code skills for enhanced productivity and intelligent automation.

## What is Artifex?

Artifex is a curated collection of skills that extend Claude Code's capabilities. Skills are modular instruction sets that help Claude perform specialized tasks more effectively—from finding and vetting other skills to organizing files intelligently.

## Available Skills

### skill-finder
**Description:** Discover and vet Claude Code skills from repositories and marketplaces with built-in security reviews.

**Features:**
- Searches official Anthropic repositories, community sources, and the Superpowers marketplace
- Performs mandatory security assessments on all found skills
- Provides detailed security guidance for safe skill adoption
- Rates skills as SAFE, REVIEW NEEDED, or UNSAFE

**Location:** `skills/skill-finder/`

## Installation

### Installing Individual Skills

Copy any skill directory from this repository to your Claude Code skills location:

```bash
# For personal skills (available across all projects)
cp -r skills/skill-finder ~/.claude/skills/

# For project skills (shared with your team via git)
cp -r skills/skill-finder ./.claude/skills/
```

### Installing All Skills

```bash
# Personal installation
cp -r skills/* ~/.claude/skills/

# Project installation
cp -r skills/* ./.claude/skills/
```

## Using Skills

Once installed, Claude Code automatically discovers and uses skills based on your requests. For example:

- "Find skills about file organization" → Triggers **skill-finder**
- Skills load only when needed, keeping context usage efficient

## Security

All skills in this repository follow security best practices:
- No credential access or harvesting
- No network calls to unknown domains
- User confirmation required for destructive operations
- Read-only operations preferred
- Transparent about all commands executed

The **skill-finder** skill includes comprehensive security guidance to help you evaluate skills from any source.

## Contributing

Have a useful skill to share? Contributions are welcome!

1. Fork this repository
2. Create a new skill in `skills/your-skill-name/`
3. Include a `SKILL.md` with proper frontmatter
4. Submit a pull request

Please ensure your skill follows security best practices and includes clear documentation.

## Skill Structure

Each skill follows this structure:

```
skills/
└── skill-name/
    ├── SKILL.md           # Main skill file with YAML frontmatter
    ├── scripts/           # Optional: helper scripts
    ├── references/        # Optional: reference documents
    └── assets/            # Optional: images, templates, etc.
```

## Resources

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code/)
- [Official Anthropic Skills](https://github.com/anthropics/skills)
- [Superpowers Marketplace](https://github.com/superpowers-ai/superpowers-marketplace)

## License

MIT License - See LICENSE file for details

## Etymology

**Artifex** (Latin) combines *ars* (skill, art) and *facere* (to make). It perfectly captures the essence of this project: crafting tools that make Claude Code more skillful and artful in its assistance.
