# Known Skill Repositories and Marketplaces

This document maintains a list of known sources for Claude Code skills and plugins.

## Official Sources

### Anthropic Skills Repository ⭐ PRIMARY SOURCE
- **URL:** https://github.com/anthropics/skills
- **Type:** Official example skills repository
- **Description:** Anthropic's public repository with 14+ example skills demonstrating best practices. Announced November 14, 2025.
- **Categories:** Creative & Design, Development & Technical, Enterprise & Communication, Meta Skills, Document Skills
- **Installation:** Clone or copy skills to `.claude/skills/` directory
- **Search approach:** Browse repository directly, use as reference for skill structure and best practices

### Anthropic Plugin Marketplaces
- **Documentation:** https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
- **Type:** Plugin distribution system
- **Description:** Plugins bundle skills, MCP servers, slash commands, and hooks into installable packages
- **Format:** `.claude-plugin/marketplace.json` in git repositories
- **Installation:** Use `/plugin install <url>` command in Claude Code
- **Search approach:** Look for repositories with `.claude-plugin/marketplace.json` files

### Anthropic Official Documentation
- **URL:** https://docs.claude.com/en/docs/claude-code/
- **Type:** Official documentation
- **Description:** Official documentation for Claude Code skills, plugins, and MCP integration
- **Search approach:** Look for "skills", "plugins", "extending claude code"

## Community Curated Lists

### Awesome Claude Skills
- **URL:** https://github.com/travisvn/awesome-claude-skills
- **Type:** Comprehensive curated list
- **Description:** Community-maintained list with categories, security guidelines, tutorials, and verified skills
- **Categories:** Collections & Libraries, Individual Skills, Tools, Documentation, Tutorials, Articles, Security Guidelines
- **Installation:** Follow specific instructions for each listed skill
- **Search approach:** Browse by category or search within README

### Superpowers Core Skills Library
- **URL:** https://github.com/obra/superpowers
- **Type:** Battle-tested skills collection
- **Description:** 20+ production-ready skills for testing, debugging, collaboration, and meta-workflows
- **Categories:** Testing, Debugging, Collaboration, Meta
- **Installation:** Follow repository instructions
- **Search approach:** Browse skills by category folder

## Skill Discovery Websites

### SkillsMP
- **URL:** https://skillsmp.com
- **Type:** Skill aggregator and marketplace
- **Description:** Independent community project aggregating 10,000+ Claude skills
- **Features:** Filtering by category, author, and popularity; intelligent search
- **Search approach:** Use website search and category filters

### Claude Code Plugin Directory
- **URL:** https://claudecodeplugin.com
- **Type:** Plugin and skill directory
- **Description:** Community directory for plugins, skills, commands, agents, and hooks
- **Search approach:** Browse or search by functionality

### Claude Code Marketplace
- **URL:** https://claudecodemarketplace.com
- **Type:** Community marketplace
- **Description:** Community-driven marketplace for Claude Code extensions
- **Search approach:** Browse marketplace listings

## MCP Server Directories

Skills are often bundled with MCP servers in plugins. Search these directories for complementary capabilities:

### MCP List
- **URL:** https://mcplist.ai
- **Type:** MCP server directory
- **Description:** Directory of 775+ Model Context Protocol servers with searchable database
- **Features:** Filtering, searching, comprehensive server information
- **Use case:** Find MCP servers that complement skills or provide external tool/data access

### Official MCP Servers Repository
- **URL:** https://github.com/modelcontextprotocol/servers
- **Type:** Reference implementations
- **Description:** Official MCP reference servers maintained by Anthropic and the community
- **Categories:** Filesystem, Git, Memory, Fetch, Sequential Thinking, and more
- **Installation:** Follow per-server installation instructions

### MCP Market
- **URL:** https://mcpmarket.com
- **Type:** MCP marketplace
- **Description:** Marketplace for Model Context Protocol servers by company/provider
- **Search approach:** Browse by provider or functionality

### MCP Server Finder
- **URL:** https://mcpserverfinder.com
- **Type:** MCP server search engine
- **Description:** Specialized finder for Model Context Protocol servers
- **Search approach:** Search by keyword or category

## Community Sources

### GitHub
- **Search queries:**
  - `claude code skill [topic]`
  - `claude-plugin marketplace.json [topic]`
  - `.claude/skills/ [topic]`
  - `anthropic claude skill [topic]`
- **Common repositories:**
  - User skill repositories often follow pattern: `username/claude-code-skills`
  - Plugin repositories contain `.claude-plugin/` directory
  - Look for `.claude/skills/` directory structure
- **Installation:** Usually involves copying skill directory to local `.claude/skills/` or using `/plugin install`

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
