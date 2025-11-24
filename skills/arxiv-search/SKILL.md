---
name: arxiv-search
description: Search and retrieve academic papers from ArXiv (arxiv.org). Use when users request research papers, academic literature, preprints, or ask about papers in fields like AI, ML, mathematics, physics, or computer science. Provides paper metadata, abstracts, and PDF links.
---

# ArXiv Search

## Overview

This skill enables searching the ArXiv preprint repository for academic papers. ArXiv hosts over 2 million papers in physics, mathematics, computer science, quantitative biology, quantitative finance, statistics, electrical engineering, and economics. Use this skill to find papers by keywords, authors, categories, or ArXiv IDs, and retrieve paper metadata, abstracts, and PDF links.

## When to Use This Skill

Activate this skill when users:
- Request research papers or academic literature on specific topics
- Ask about recent papers or developments in a research field
- Need to find papers by specific authors
- Want to explore papers in specific ArXiv categories (cs.AI, math.CO, etc.)
- Reference ArXiv explicitly or ask about preprints
- Need paper metadata, abstracts, or PDF access

Examples of triggering queries:
- "Find recent papers on transformer architectures"
- "What are the latest papers by Geoffrey Hinton?"
- "Search for papers about quantum computing on ArXiv"
- "Get me papers in the cs.LG category from the last month"
- "Find the paper with ArXiv ID 2103.14030"

## Search Workflow

### 1. Determine Search Approach

Choose between two methods based on the situation:

**Method A: Direct API Access via WebFetch** (Preferred for simple searches)
- Best for: Single searches, quick lookups, when Python isn't needed
- Use WebFetch to query the ArXiv API directly
- Parse XML response and format results
- More token-efficient for simple queries

**Method B: Python Script** (Preferred for complex searches or reliability)
- Best for: Multiple searches, complex queries, when reliability is critical
- Use the bundled `scripts/search_arxiv.py` script
- Handles parsing, formatting, and error handling automatically
- More robust for production use

### 2. Construct the Search Query

Reference `references/arxiv_api_reference.md` for detailed query syntax. Key patterns:

**Basic Searches:**
```
all:machine learning          # Search all fields
ti:neural networks           # Search titles only
au:Hinton                    # Search by author
cat:cs.AI                    # Search by category
id:2103.14030               # Lookup specific paper
```

**Boolean Combinations:**
```
ti:machine AND ti:learning
au:Hinton OR au:LeCun
cat:cs.AI ANDNOT ti:survey
```

**Phrase Searching:**
```
ti:"deep learning"
abs:"convolutional neural network"
```

### 3. Execute the Search

#### Option A: Direct API Access with WebFetch

```python
# Construct API URL
base_url = "http://export.arxiv.org/api/query"
params = {
    "search_query": "all:transformer AND cat:cs.LG",
    "max_results": 10,
    "sortBy": "submittedDate",
    "sortOrder": "descending"
}
url = f"{base_url}?{urlencode(params)}"

# Use WebFetch to retrieve and parse results
```

Then parse the Atom XML response to extract paper metadata.

#### Option B: Use Python Script

```bash
# Search by keywords
python scripts/search_arxiv.py --query "transformer" --category cs.LG --max-results 10

# Search by author
python scripts/search_arxiv.py --author "Hinton" --max-results 5

# Lookup specific paper
python scripts/search_arxiv.py --id "2103.14030"

# Complex search with sorting
python scripts/search_arxiv.py --query "neural networks" --category cs.AI --sort-by submittedDate --format markdown
```

Script parameters:
- `--query, -q`: Search terms for title/abstract/content
- `--author, -a`: Author name
- `--category, -c`: ArXiv category (cs.AI, math.CO, etc.)
- `--id`: Specific ArXiv ID
- `--max-results, -n`: Maximum results (default: 10)
- `--sort-by`: Sort by relevance, lastUpdatedDate, or submittedDate
- `--sort-order`: ascending or descending
- `--format, -f`: Output format (text, json, markdown)

### 4. Format and Present Results

Present results in a user-friendly format with:
- Paper title
- Authors
- ArXiv ID
- Publication date
- Categories
- Abstract (summary)
- Links to abstract page and PDF

Example presentation:
```markdown
## 1. Attention Is All You Need

**Authors:** Ashish Vaswani, Noam Shazeer, Niki Parmar, Jakob Uszkoreit, Llion Jones, Aidan N. Gomez, Lukasz Kaiser, Illia Polosukhin
**ArXiv ID:** 1706.03762
**Published:** 2017-06-12
**Categories:** cs.CL, cs.LG

**Abstract:** The dominant sequence transduction models are based on complex recurrent or convolutional neural networks...

**Links:** [Abstract](https://arxiv.org/abs/1706.03762) | [PDF](https://arxiv.org/pdf/1706.03762.pdf)
```

### 5. Handle Common Scenarios

**No Results Found:**
- Suggest broader search terms
- Try removing boolean operators
- Check category codes are valid
- Search without category restrictions

**Too Many Results:**
- Refine query with more specific terms
- Add category filters
- Use date sorting to find recent papers
- Increase relevance by using title/abstract fields instead of "all"

**Finding Related Papers:**
- Use same categories
- Search for citing authors
- Use similar keywords from relevant papers found
- Explore cross-listed categories

## ArXiv Category Reference

Quick reference for common categories (see `references/arxiv_api_reference.md` for complete list):

**Computer Science:**
- cs.AI - Artificial Intelligence
- cs.CL - Computation and Language
- cs.CV - Computer Vision
- cs.LG - Machine Learning
- cs.NE - Neural and Evolutionary Computing
- cs.RO - Robotics

**Mathematics:**
- math.CO - Combinatorics
- math.LO - Logic
- math.NA - Numerical Analysis
- math.OC - Optimization and Control
- math.PR - Probability
- math.ST - Statistics Theory

**Physics:**
- astro-ph - Astrophysics
- cond-mat - Condensed Matter
- quant-ph - Quantum Physics

**Other:**
- stat - Statistics
- q-bio - Quantitative Biology
- q-fin - Quantitative Finance
- econ - Economics

## Advanced Query Techniques

### Multi-Author Search
```
au:Hinton OR au:Bengio OR au:LeCun
```

### Date-Restricted Search
Sort by submission date and limit results:
```
cat:cs.AI sortBy=submittedDate sortOrder=descending max_results=20
```
Then filter results by publication date in your presentation.

### Cross-Category Search
```
cat:cs.LG AND cat:stat.ML
```

### Topic with Exclusions
```
all:neural networks ANDNOT ti:survey ANDNOT ti:review
```

## Best Practices

1. **Start Broad, Then Narrow**: Begin with general terms, then refine based on results
2. **Use Categories**: Greatly improves relevance for field-specific searches
3. **Sort by Date**: For "latest papers" queries, always use `sortBy=submittedDate`
4. **Reasonable Limits**: Default to 10 results, adjust based on user needs
5. **Provide Links**: Always include both abstract and PDF links
6. **Check References**: For detailed query syntax or category codes, read `references/arxiv_api_reference.md`
7. **Handle Errors Gracefully**: If API fails, suggest alternative search terms or manual search
8. **Respect Rate Limits**: Space out multiple searches if needed (1 request per 3 seconds)

## Resources

### scripts/search_arxiv.py
Executable Python script for searching ArXiv. Handles API requests, XML parsing, formatting, and error handling. Can be run directly or its code can be adapted for inline use.

Features:
- Multiple search criteria (query, author, category, ID)
- Boolean search support
- Multiple output formats (text, JSON, markdown)
- Automatic error handling and validation
- Configurable sorting and result limits

### references/arxiv_api_reference.md
Comprehensive reference documentation for the ArXiv API, including:
- Complete query syntax and boolean operators
- Full category taxonomy across all fields
- ArXiv ID format specifications
- Response format details
- Rate limiting guidelines
- Common search patterns
- URL schemes for accessing papers

Load this reference when:
- Constructing complex queries
- Need category codes beyond common ones
- Debugging search issues
- Understanding API responses
- Building custom search logic

## Troubleshooting

**Script execution fails:**
- Verify Python 3 is available
- Check network connectivity
- Ensure no firewall blocking export.arxiv.org
- Try direct API access via WebFetch as fallback

**Empty or unexpected results:**
- Verify query syntax (especially boolean operators)
- Check category codes are valid
- Try simpler query first
- Read `references/arxiv_api_reference.md` for syntax details

**Need more results:**
- Increase `--max-results` parameter
- Use pagination with `start` parameter
- Broaden search terms

**Finding very recent papers:**
- Use `sortBy=submittedDate` with `sortOrder=descending`
- Search without date restrictions
- Check if paper category is correct
