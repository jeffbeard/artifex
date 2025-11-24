# ArXiv API Reference

This document provides comprehensive reference information for the ArXiv API, including search syntax, categories, and advanced query construction.

## API Endpoint

```
http://export.arxiv.org/api/query
```

## Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `search_query` | The search query string | `all:machine learning` |
| `id_list` | Comma-separated list of ArXiv IDs | `2103.14030,2103.00020` |
| `start` | Index of first result (0-based) | `0` |
| `max_results` | Maximum number of results to return | `10` |
| `sortBy` | Sort criterion | `relevance`, `lastUpdatedDate`, `submittedDate` |
| `sortOrder` | Sort order | `ascending`, `descending` |

## Search Query Syntax

### Basic Syntax

Searches use prefix notation to specify which fields to search:

- `ti:` - Title
- `au:` - Author
- `abs:` - Abstract
- `co:` - Comment
- `jr:` - Journal Reference
- `cat:` - Subject Category
- `rn:` - Report Number
- `id:` - ArXiv ID
- `all:` - All fields

### Examples

```
ti:machine learning              # Papers with "machine learning" in title
au:Hinton                        # Papers by author Hinton
cat:cs.AI                        # Papers in cs.AI category
all:neural networks              # "neural networks" in any field
```

### Boolean Operators

Combine search terms with boolean operators:

- `AND` - Both terms must be present
- `OR` - Either term can be present
- `ANDNOT` - First term present, second term absent

Examples:
```
ti:machine AND ti:learning
au:Hinton OR au:LeCun
cat:cs.AI ANDNOT ti:survey
```

### Phrase Searching

Use quotes for exact phrase matching:
```
ti:"deep learning"
abs:"convolutional neural network"
```

### Grouping

Use parentheses to group terms:
```
(ti:neural OR ti:network) AND cat:cs.AI
```

## ArXiv Categories

### Computer Science (cs)

| Category | Description |
|----------|-------------|
| cs.AI | Artificial Intelligence |
| cs.CL | Computation and Language |
| cs.CV | Computer Vision and Pattern Recognition |
| cs.LG | Machine Learning |
| cs.NE | Neural and Evolutionary Computing |
| cs.RO | Robotics |
| cs.CR | Cryptography and Security |
| cs.DS | Data Structures and Algorithms |
| cs.DB | Databases |
| cs.SE | Software Engineering |
| cs.PL | Programming Languages |
| cs.DC | Distributed, Parallel, and Cluster Computing |

### Mathematics (math)

| Category | Description |
|----------|-------------|
| math.AG | Algebraic Geometry |
| math.CO | Combinatorics |
| math.CT | Category Theory |
| math.DG | Differential Geometry |
| math.GR | Group Theory |
| math.LO | Logic |
| math.NA | Numerical Analysis |
| math.NT | Number Theory |
| math.OC | Optimization and Control |
| math.PR | Probability |
| math.ST | Statistics Theory |

### Physics

| Category | Description |
|----------|-------------|
| astro-ph | Astrophysics |
| cond-mat | Condensed Matter |
| gr-qc | General Relativity and Quantum Cosmology |
| hep-ex | High Energy Physics - Experiment |
| hep-lat | High Energy Physics - Lattice |
| hep-ph | High Energy Physics - Phenomenology |
| hep-th | High Energy Physics - Theory |
| math-ph | Mathematical Physics |
| nucl-ex | Nuclear Experiment |
| nucl-th | Nuclear Theory |
| physics | Physics (other) |
| quant-ph | Quantum Physics |

### Other Fields

| Category | Description |
|----------|-------------|
| q-bio | Quantitative Biology |
| q-fin | Quantitative Finance |
| stat | Statistics |
| econ | Economics |
| eess | Electrical Engineering and Systems Science |

## ArXiv ID Format

ArXiv IDs have changed format over time:

### New Format (April 2007 onwards)
```
YYMM.NNNNN
```
- `YY` - Year (two digits)
- `MM` - Month (two digits)
- `NNNNN` - Sequence number (5 digits, zero-padded)

Example: `2103.14030` (March 2021, paper #14030)

### Old Format (Before April 2007)
```
archive.category/YYMMNNN
```
Example: `cs.AI/0701001`

### Version Numbers
Papers can have multiple versions, indicated by `vN`:
```
2103.14030v1  # First version
2103.14030v2  # Second version (revision)
```

## Response Format

The API returns results in Atom XML format. Each entry contains:

- `title` - Paper title
- `summary` - Abstract
- `id` - ArXiv identifier URL
- `published` - Original publication date
- `updated` - Last update date
- `author` - Author information (can be multiple)
- `link` - Links to abstract page and PDF
- `category` - Subject categories (can be multiple)
- `primary_category` - Primary subject category
- `comment` - Optional comments
- `journal_ref` - Journal reference if published
- `doi` - DOI if available

## Rate Limiting and Best Practices

1. **Rate Limits**: ArXiv asks for no more than 1 request per 3 seconds
2. **Batch Requests**: Use `max_results` to get multiple papers in one request
3. **Pagination**: Use `start` parameter to paginate through large result sets
4. **Caching**: Cache results when possible to reduce API load
5. **User Agent**: Include a descriptive User-Agent header

## Common Search Patterns

### Latest Papers in a Field
```
cat:cs.AI
sortBy=submittedDate
sortOrder=descending
```

### Papers by Multiple Authors
```
au:Hinton OR au:Bengio OR au:LeCun
```

### Recent Papers on a Topic
```
all:transformer AND cat:cs.LG
sortBy=submittedDate
sortOrder=descending
```

### Highly Cited Papers (Proxy)
Search for papers with many versions (often indicates significant work):
```
all:attention mechanism
sortBy=lastUpdatedDate
sortOrder=descending
```

### Cross-Listed Papers
Papers in multiple categories:
```
cat:cs.LG AND cat:stat.ML
```

## URLs and Access

### Abstract Page
```
https://arxiv.org/abs/{arxiv_id}
```
Example: `https://arxiv.org/abs/2103.14030`

### PDF Download
```
https://arxiv.org/pdf/{arxiv_id}.pdf
```
Example: `https://arxiv.org/pdf/2103.14030.pdf`

### Source Files (LaTeX, etc.)
```
https://arxiv.org/e-print/{arxiv_id}
```

### Specific Version
```
https://arxiv.org/abs/{arxiv_id}v{version}
```
Example: `https://arxiv.org/abs/2103.14030v2`

## Error Handling

Common issues and solutions:

1. **Empty Results**: Check query syntax, try broader terms
2. **Malformed Query**: Verify boolean operators and parentheses
3. **Network Errors**: Implement retry logic with exponential backoff
4. **Invalid Category**: Check category codes against official list
5. **Rate Limiting**: Add delays between requests

## Additional Resources

- Official ArXiv API Documentation: https://arxiv.org/help/api/
- ArXiv Category Taxonomy: https://arxiv.org/category_taxonomy
- ArXiv Identifier Scheme: https://arxiv.org/help/arxiv_identifier
