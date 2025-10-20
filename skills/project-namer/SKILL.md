---
name: project-namer
description: Generate creative, meaningful project names through a guided questionnaire. Draws from multiple language traditions (Latin, Greek, Norse, Gaelic, etc.) and provides etymology for each suggestion. Perfect for naming software projects, products, repositories, or any creative endeavor.
---

# Project Namer

## Overview

This skill helps generate thoughtful, memorable project names by understanding your project's essence and your naming preferences. It uses a structured questionnaire approach to capture the right vibe, then generates 10 carefully curated name suggestions with full etymological context.

## When to Use This Skill

Use this skill when:
- Starting a new project and need a name
- Rebranding or renaming an existing project
- Want creative names with meaningful origins
- Need multiple options to choose from
- Prefer names with linguistic depth (Latin, Greek, Norse, Gaelic, etc.)

## Workflow

### 1. Gather Initial Context

First, understand what the user is trying to name by asking open-ended questions:
- What type of project is this? (software, product, repository, etc.)
- What does the project do or what problem does it solve?
- Are there any specific words, concepts, or themes you want reflected?
- Any examples of names you like or want to avoid?

### 2. Run the Questionnaire

Use the AskUserQuestion tool to present a structured questionnaire with these questions:

#### Question 1: Theme/Vibe
**Question:** "What vibe or theme should the name convey for your project?"
**Header:** "Theme"
**multiSelect:** false
**Options:**
1. **Discovery & exploration** - Names that evoke finding, seeking, or uncovering (e.g., Latin 'inveni' = I found)
2. **Tools & craft** - Names related to tools, building, or craftsmanship (e.g., Norse 'smiðr' = craftsman)
3. **Wisdom & knowledge** - Names associated with learning, wisdom, or insight (e.g., Greek 'sophia' = wisdom)
4. **Speed & efficiency** - Names suggesting quickness, agility, or streamlined work (e.g., Latin 'celer' = swift)
5. **Power & strength** - Names conveying force, capability, or robustness (e.g., Norse 'þórr' = thunder)
6. **Creativity & art** - Names related to creation, beauty, or artistic expression (e.g., Latin 'ars' = art)

#### Question 2: Explicitness
**Question:** "How directly should the name reference what your project does?"
**Header:** "Directness"
**multiSelect:** false
**Options:**
1. **Explicit/Descriptive** - Clear about functionality (e.g., 'file-organizer', 'code-formatter')
2. **Subtle reference** - Hints at purpose without being literal (e.g., 'nexus' for connector, 'forge' for builder)
3. **Abstract/Poetic** - Pure concept words with metaphorical connection (e.g., 'zenith', 'lumen')
4. **Hybrid** - Combines descriptive + creative (e.g., 'git-kraken', 'docker-compose')

#### Question 3: Tone
**Question:** "How formal or playful should the name feel?"
**Header:** "Tone"
**multiSelect:** false
**Options:**
1. **Professional** - Serious, business-appropriate, scholarly (e.g., 'enterprise', 'architect')
2. **Balanced** - Professional but approachable, works in any context (e.g., 'notion', 'figma')
3. **Creative** - Memorable, shows personality, perhaps whimsical (e.g., 'spotify', 'slack')
4. **Technical** - Appeals to developers, embraces jargon (e.g., 'webpack', 'rustc')

#### Question 4: Language Traditions
**Question:** "Which language traditions should I draw from? (Select all that apply)"
**Header:** "Languages"
**multiSelect:** true
**Options:**
1. **Latin** - Classical, scholarly, widely recognized (e.g., 'opus', 'nexus', 'lumen')
2. **Ancient Greek** - Philosophical, technical, academic (e.g., 'tekne', 'logos', 'sophia')
3. **Old Norse** - Strong, mythological, unique (e.g., 'skjold', 'rune', 'saga')
4. **Gaelic** (Irish/Scottish) - Poetic, distinctive, Celtic (e.g., 'ceardlann', 'fios', 'aisling')
5. **Old English** - Foundational, familiar, Anglo-Saxon (e.g., 'craft', 'loom', 'wyrd')
6. **Modern English** - Contemporary, accessible, clear

#### Question 5: Word Length
**Question:** "What length should the project name be?"
**Header:** "Length"
**multiSelect:** false
**Options:**
1. **Short** (4-6 letters) - Punchy, memorable, good for commands (e.g., 'vim', 'git', 'opus')
2. **Medium** (7-10 letters) - Balanced, substantive (e.g., 'artifex', 'nexus', 'codex')
3. **Long** (11+ letters) - Descriptive, compound words OK (e.g., 'thunderbird', 'elasticsearch')
4. **Flexible** - Any length that fits the concept

#### Question 6: Invented Words
**Question:** "Should I include invented/constructed words in the suggestions?"
**Header:** "Invented"
**multiSelect:** false
**Options:**
1. **Yes, include invented words** - Create new words by blending roots (e.g., 'Velox', 'Agilux', 'Expedium')
2. **Mix of real and invented** - Balance existing words with creative constructions
3. **Only real words** - Stick to actual words from the selected language traditions
4. **Surprise me** - Use your judgment based on the project context

### 3. Generate Name Suggestions

Based on the questionnaire responses and initial context, generate exactly **10 project name suggestions**.

**Regarding Invented Words:**
- If user selected "Yes, include invented words" - Generate 7-10 invented words using the techniques below
- If user selected "Mix of real and invented" - Provide roughly 5 real words and 5 invented words
- If user selected "Only real words" - Use only existing words from dictionaries and language traditions
- If user selected "Surprise me" - Use your judgment; default to "Mix" unless context strongly suggests otherwise

**Invented Word Techniques:**
- **Root blending:** Combine Latin/Greek roots in new ways (e.g., "velox" + "-ora" = "Velora")
- **Suffix modification:** Take real roots and add tech-style suffixes like -ex, -ium, -ux (e.g., "Rapidex", "Expedium", "Agilux")
- **Pure Latin/Greek words:** Use actual but rarely-used Latin/Greek words that feel invented (e.g., "Velox", "Celerity", "Rapidus")
- **Modern compounds:** Combine familiar English words in new ways (e.g., "Swiftline", "Codepath")
- Mark invented words clearly in etymology: "(Invented)" or "(Pseudo-Latin construction)" or "(Rare but real word)"

For each name, provide:
1. **The name** (formatted in bold)
2. **Etymology** - Language origin, literal meaning, relevant context. For invented words, explain the construction method and component roots.
3. **Why it fits** - How it connects to their project and preferences
4. **Pronunciation guide** (if non-obvious)
5. **Practical notes** - Domain availability considerations, similar existing projects, etc.

### 4. Format Output

Present the names in this format:

```markdown
## 10 Project Name Suggestions

### 1. **name-here**
(Language: meaning)
- **Etymology:** Full explanation of origin, historical usage, related words
- **Why it fits:** Connection to project theme, vibe, and preferences
- **Pronunciation:** /phonetic-guide/ (if needed)
- **Notes:** Any practical considerations

### 2. **name-here**
...
[Continue for all 10]

---

## My Top 3 Recommendations:
1. **name** - Brief reason
2. **name** - Brief reason
3. **name** - Brief reason

Which direction appeals to you, or would you like variations on any of these?
```

### 5. Offer Iteration

After presenting the 10 names:
- Ask if they'd like variations on any specific name
- Offer to explore different themes or language traditions
- Can generate another set with adjusted parameters
- Help refine a favorite into variations (shorter, longer, compound forms)

## Best Practices

### Invented Words Best Practices

**When to Favor Invented Words:**
- User wants something unique and ownable (low collision risk)
- Project needs a distinctive brand identity
- Real words in the theme are overused or taken
- Tech/startup context where invented names are common (Spotify, Figma, etc.)

**When to Favor Real Words:**
- User prioritizes immediate understanding
- Professional/enterprise context requiring gravitas
- International audience where invented words may confuse
- The real word perfectly captures the essence

**Quality Checks for Invented Words:**
- Does it sound natural when spoken aloud?
- Can people guess the spelling after hearing it?
- Does it avoid awkward letter combinations (double-x, etc.)?
- Does the etymology story make sense?
- Is it searchable? (Too generic = bad SEO)

### Language-Specific Considerations

**Latin:**
- Often ends in -us, -ex, -is, -or
- Conveys gravitas and permanence
- Good for enterprise/professional projects

**Greek:**
- Technical prefixes (tele-, micro-, auto-)
- Philosophical depth
- Common in academic/scientific naming

**Norse:**
- Strong consonants, unique spellings (ð, þ, œ)
- Mythological references (gods, heroes, concepts)
- Stands out but may be harder to spell/pronounce

**Gaelic:**
- Beautiful sounds but challenging for non-speakers
- Often longer compound words
- Very distinctive, less likely to conflict

**Old English:**
- Familiar roots, comfortable for English speakers
- Simple, earthy, direct
- Easy to spell and pronounce

**Modern English:**
- Most accessible but higher collision risk
- Can combine with other languages for hybrid names
- Good for descriptive/explicit naming

### Name Quality Checks

Before suggesting a name, consider:
- **Memorability** - Easy to remember and recall
- **Pronounceability** - Can people say it without explanation?
- **Spellability** - Can people spell it after hearing it?
- **Distinctiveness** - Stands out from similar projects
- **Domain availability** - .com available? (mention but don't filter)
- **Cultural sensitivity** - No negative connotations in major languages
- **Length appropriateness** - Fits the use case (CLI tool vs web app)

### Avoid

- Names that are too similar to major existing projects
- Offensive or inappropriate meanings in other languages
- Names that are trendy but will age poorly
- Overly clever puns that obscure meaning
- Names that create pronunciation confusion

## Examples

### Example 1: Developer Tool

**Context:** CLI tool for managing environment variables across projects

**Questionnaire Results:**
- Theme: Tools & craft
- Directness: Subtle reference
- Tone: Technical
- Languages: Latin, Old Norse
- Length: Short
- Invented words: Mix of real and invented

**Sample Suggestions:**
- **envoy** (French via Latin: messenger) - Carries your environment settings
- **vald** (Old Norse: power, authority) - Controls your configuration
- **envex** (Invented: "env" + Latin "-ex") - Modern constructed name for env management
- **fors** (Latin: strong, powerful) - Reinforces environment consistency
- **konfig** (Invented: modern spelling of "config") - Technical, memorable spelling

### Example 2: Creative Project

**Context:** Design system for building beautiful documentation

**Questionnaire Results:**
- Theme: Creativity & art
- Directness: Abstract/Poetic
- Tone: Creative
- Languages: Greek, Latin, Modern English
- Length: Medium
- Invented words: Only real words

**Sample Suggestions:**
- **chronicle** (Greek via Latin: time + writing) - Documents your project's story
- **papyrus** (Greek/Latin: ancient writing material) - Foundation for beautiful docs
- **eloquent** (Latin: speaking out) - Helps projects speak clearly
- **canvas** (Latin via Old French: cloth for painting) - Blank surface for documentation art

## Tips for Success

1. **Listen to context** - The user's description often contains the perfect name seed
2. **Mix traditions** - Don't feel bound to one language if a good name exists elsewhere
3. **Consider the ecosystem** - What are similar projects named? Follow or diverge intentionally
4. **Think about usage** - Will this be typed frequently? Spoken aloud? In URLs?
5. **Respect preferences** - If user has strong language preferences, honor them
6. **Provide variety** - Include safe choices and bold choices in your 10
7. **Etymology matters** - The story behind a name makes it more meaningful and memorable
