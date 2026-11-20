# Artifex

> *Latin: craftsman, artist, maker*

A collection of Claude Code skills for enhanced productivity and intelligent automation, created largely by Claude.

## What is Artifex?

Artifex is my collection of skills for Claude Code.

## Available Skills

### skill-finder
**Description:** Discover and vet Claude Code skills from repositories and marketplaces with built-in security reviews.

**Features:**
- Searches official Anthropic repositories, community sources, and the Superpowers marketplace
- Performs mandatory security assessments on all found skills
- Provides detailed security guidance for safe skill adoption
- Rates skills as SAFE, REVIEW NEEDED, or UNSAFE

**Location:** `skills/skill-finder/`


### project-namer
**Description:** Use Claude to generate project names

**Features:**
- Has a questionnaire that starts with a description of the project or
  initiative
- It will ask about languages to use, themes/vibe, whether to consider invented
  words, and other relevant information.
- Produces a details list of words with their etymlogy, pronounciation, justification for inclusion, then a top 3 recommendations list.
- Optional themed word lists: periodic table elements and meteorological terms, each with word origins and name-collision warnings.
- Two-word operation-style codenames ("Operation Lead Balloon"), with the register set by the tone answer: solemn, neutral, deadpan, or dry technical.

**Location:** `skills/project-namer/`

### arxiv-search
**Description:** Search and retrieve academic papers from ArXiv (arxiv.org).

**Features:**
- Search by keywords, authors, categories, or ArXiv IDs
- Dual approach: Direct API access or bundled Python script
- Support for boolean operators and advanced queries
- Retrieve paper metadata, abstracts, and PDF links
- Comprehensive API reference with full category taxonomy
- No dependency on unstable MCP servers

**Location:** `skills/arxiv-search/`

## Synoptix: multi-agent code review

*Synoptix* is the working brand for the two cross-agent review skills below, which ship together as the `cross-agent` plugin. The name is from *synoptic*, Greek for "seeing all together": a synoptic chart puts many independent observations on one map. It is reserved as the project name if these skills are ever split into their own repository.

### agy-review
**Description:** Get a read-only review from the Antigravity CLI (`agy`), with every finding verified before it is reported.

**Features:**
- Reviews uncommitted changes, a branch diff, or an OpenSpec change
- Runs agy headless in sandbox and plan mode, never with permission bypass
- Marks each finding confirmed, unconfirmed, or wrong against the actual code
- Saves prompts and raw responses under `.agent-reviews/<timestamp>/`

**Requires:** `agy` installed and signed in.

**Location:** `skills/agy-review/`

### consensus-review
**Description:** Codex, agy, and Claude review the same target independently, debate the disagreements, and report a decision for every proposed change.

**Features:**
- Parallel, isolated reviews in a shared finding format
- One debate round on disputed and unverified items, by resuming each reviewer's session
- Decision table with justifications, unresolved items, and an ordered final changeset
- Carries on when a reviewer is missing or times out, and says who was unavailable
- Never edits files without confirmation

**Requires:** `codex` and/or `agy` installed and signed in, plus the `agy-review` skill (same plugin).

**Location:** `skills/consensus-review/`

## Installation

Artifex is a Claude Code plugin marketplace. Install all skills in one shot from inside Claude Code:

```
/plugin marketplace add github:jeffbeard/artifex
/plugin install artifex@artifex
```

The cross-agent review skills (`agy-review`, `consensus-review`) ship as a separate plugin, `cross-agent`:

```
/plugin install cross-agent@artifex
```

To pull updates later:

```
/plugin marketplace update artifex
```

### Manual installation (alternative)

You can still copy individual skill directories if you prefer not to use the plugin system:

```bash
# Personal (available across all projects)
cp -r skills/skill-finder ~/.claude/skills/

# Project-local (shared via git)
cp -r skills/skill-finder ./.claude/skills/
```

## Using Skills

Once installed, Claude Code automatically discovers and uses skills based on your requests. For example:

- "Find skills about file organization" → Triggers **skill-finder**
- "Ask agy to review the current OpenSpec change" → Triggers **agy-review**
- "Ask codex and agy to review this before we open a PR and come to a consensus" → Triggers **consensus-review**
- Skills load only when needed, keeping context usage efficient


## Contributing

Have a useful skill to share? Contributions are welcome!

1. Fork this repository
2. Create a new skill in `skills/your-skill-name/`
3. Include a `SKILL.md` with proper frontmatter
4. Submit a pull request


## Resources

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code/)
- [Official Anthropic Skills](https://github.com/anthropics/skills)
- [Superpowers Marketplace](https://github.com/superpowers-ai/superpowers-marketplace)

## License

MIT License - See LICENSE file for details

## Etymology

**Artifex** (Latin) combines *ars* (skill, art) and *facere* (to make). It perfectly captures the essence of this project: crafting tools that make Claude Code more skillful and artful in its assistance.
