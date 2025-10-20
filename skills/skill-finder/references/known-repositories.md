# Known Skill Repositories and Marketplaces

This document maintains a list of known sources for Claude Code skills and plugins.

## Official Sources

### Superpowers Marketplace
- **URL:** https://github.com/superpowers-ai/superpowers-marketplace
- **Type:** Marketplace plugin collection
- **Description:** Official repository for superpowers plugins that extend Claude Code with specialized workflows and capabilities
- **Installation:** Follow instructions in the marketplace repository
- **Search approach:** Browse the repository directly or search for "superpowers" + topic

## Community Sources

### GitHub
- **Search queries:**
  - `claude code skill [topic]`
  - `claude ai skill [topic]`
  - `.claude/skills [topic]`
  - `anthropic claude skill [topic]`
- **Common repositories:**
  - User skill repositories often follow pattern: `username/claude-code-skills`
  - Look for `.claude/skills/` directory structure
- **Installation:** Usually involves copying skill directory to local `.claude/skills/`

### Anthropic Documentation
- **URL:** https://docs.claude.com/en/docs/claude-code/
- **Type:** Official documentation
- **Description:** May reference example skills or official skill repositories
- **Search approach:** Look for "skills", "plugins", "extending claude code"

## Skill Structure Indicators

When evaluating search results, look for these indicators of a valid skill:

1. **Directory structure:**
   ```
   skill-name/
   ├── SKILL.md
   ├── scripts/ (optional)
   ├── references/ (optional)
   └── assets/ (optional)
   ```

2. **YAML frontmatter in SKILL.md:**
   ```yaml
   ---
   name: skill-name
   description: Description of the skill
   ---
   ```

3. **Keywords in repository:**
   - "claude code"
   - "claude skill"
   - "anthropic"
   - ".claude"
   - "skill.md"

## Search Tips

### For Superpowers Plugins
- Look for repositories under `superpowers-ai` organization
- Check for `plugin:superpowers@superpowers-marketplace` references
- Search for "superpowers skill [topic]"

### For User-Created Skills
- Use GitHub code search for YAML frontmatter patterns
- Look in `.claude/skills/` directories
- Check user repositories named "*-skills" or "*-claude-*"
- Search for README files mentioning Claude Code

### For Emerging Sources
- Check Anthropic forums and community channels
- Look for skill sharing in Reddit (r/ClaudeAI)
- Monitor GitHub topics: `claude-code`, `claude-ai`, `anthropic`

## Adding New Sources

When new skill repositories or marketplaces are discovered:
1. Add them to the appropriate section above
2. Include URL, type, description, and search approach
3. Note any special installation requirements
4. Update search tips if needed
