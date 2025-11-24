#!/usr/bin/env python3
"""
ArXiv Search Script

This script provides a reliable interface to the ArXiv API for searching and retrieving
academic papers. It handles API requests, parses results, and formats output.

Usage:
    python search_arxiv.py --query "machine learning" --max-results 10
    python search_arxiv.py --author "Hinton" --category cs.AI
    python search_arxiv.py --id "2103.14030"
"""

import argparse
import urllib.request
import urllib.parse
import xml.etree.ElementTree as ET
from datetime import datetime
import json
import sys


class ArXivSearcher:
    """Handler for ArXiv API searches"""

    BASE_URL = "http://export.arxiv.org/api/query"
    NAMESPACE = {"atom": "http://www.w3.org/2005/Atom"}

    def __init__(self, max_results=10):
        self.max_results = max_results

    def search(self, query=None, author=None, category=None, arxiv_id=None, sort_by="relevance", sort_order="descending"):
        """
        Search ArXiv with various criteria

        Args:
            query: Search terms for title/abstract
            author: Author name
            category: ArXiv category (e.g., cs.AI, math.CO)
            arxiv_id: Specific ArXiv ID
            sort_by: Sort criterion (relevance, lastUpdatedDate, submittedDate)
            sort_order: Sort order (ascending, descending)

        Returns:
            List of paper dictionaries with metadata
        """
        # Build search query
        search_parts = []

        if arxiv_id:
            # Direct ID lookup
            search_query = f"id:{arxiv_id}"
        else:
            if query:
                search_parts.append(f"all:{query}")
            if author:
                search_parts.append(f"au:{author}")
            if category:
                search_parts.append(f"cat:{category}")

            if not search_parts:
                raise ValueError("Must provide at least one search criterion")

            search_query = " AND ".join(search_parts)

        # Build URL parameters
        params = {
            "search_query": search_query,
            "start": 0,
            "max_results": self.max_results,
            "sortBy": sort_by,
            "sortOrder": sort_order
        }

        url = f"{self.BASE_URL}?{urllib.parse.urlencode(params)}"

        # Make request
        try:
            with urllib.request.urlopen(url) as response:
                xml_data = response.read().decode('utf-8')
        except Exception as e:
            raise Exception(f"Failed to fetch from ArXiv API: {str(e)}")

        # Parse XML response
        return self._parse_response(xml_data)

    def _parse_response(self, xml_data):
        """Parse ArXiv API XML response"""
        root = ET.fromstring(xml_data)
        papers = []

        for entry in root.findall("atom:entry", self.NAMESPACE):
            paper = self._parse_entry(entry)
            papers.append(paper)

        return papers

    def _parse_entry(self, entry):
        """Parse a single paper entry from XML"""
        ns = self.NAMESPACE

        # Extract basic fields
        paper = {
            "id": self._get_text(entry, "atom:id", ns),
            "title": self._get_text(entry, "atom:title", ns).strip().replace("\n", " "),
            "summary": self._get_text(entry, "atom:summary", ns).strip().replace("\n", " "),
            "published": self._get_text(entry, "atom:published", ns),
            "updated": self._get_text(entry, "atom:updated", ns),
            "authors": [],
            "categories": [],
            "links": {}
        }

        # Extract ArXiv ID from full URL
        arxiv_id = paper["id"].split("/abs/")[-1]
        paper["arxiv_id"] = arxiv_id

        # Extract authors
        for author in entry.findall("atom:author", ns):
            name = self._get_text(author, "atom:name", ns)
            if name:
                paper["authors"].append(name)

        # Extract categories
        for category in entry.findall("atom:category", ns):
            term = category.get("term")
            if term:
                paper["categories"].append(term)

        # Extract links
        for link in entry.findall("atom:link", ns):
            link_type = link.get("title")
            link_href = link.get("href")
            if link_type and link_href:
                paper["links"][link_type] = link_href

        # Ensure PDF link exists
        if "pdf" not in paper["links"]:
            paper["links"]["pdf"] = f"https://arxiv.org/pdf/{arxiv_id}.pdf"

        # Ensure abstract page link exists
        paper["links"]["abstract"] = f"https://arxiv.org/abs/{arxiv_id}"

        return paper

    def _get_text(self, element, path, namespace):
        """Safely extract text from XML element"""
        found = element.find(path, namespace)
        return found.text if found is not None else ""

    def format_results(self, papers, output_format="text"):
        """Format search results for display"""
        if output_format == "json":
            return json.dumps(papers, indent=2)

        elif output_format == "text":
            output = []
            for i, paper in enumerate(papers, 1):
                output.append(f"\n{'='*80}")
                output.append(f"Paper {i}/{len(papers)}")
                output.append(f"{'='*80}")
                output.append(f"Title: {paper['title']}")
                output.append(f"Authors: {', '.join(paper['authors'])}")
                output.append(f"ArXiv ID: {paper['arxiv_id']}")
                output.append(f"Published: {paper['published'][:10]}")
                output.append(f"Categories: {', '.join(paper['categories'])}")
                output.append(f"\nAbstract:\n{paper['summary']}")
                output.append(f"\nLinks:")
                output.append(f"  Abstract: {paper['links']['abstract']}")
                output.append(f"  PDF: {paper['links']['pdf']}")

            return "\n".join(output)

        elif output_format == "markdown":
            output = []
            for i, paper in enumerate(papers, 1):
                output.append(f"\n## {i}. {paper['title']}")
                output.append(f"\n**Authors:** {', '.join(paper['authors'])}")
                output.append(f"**ArXiv ID:** {paper['arxiv_id']}")
                output.append(f"**Published:** {paper['published'][:10]}")
                output.append(f"**Categories:** {', '.join(paper['categories'])}")
                output.append(f"\n**Abstract:** {paper['summary']}")
                output.append(f"\n**Links:** [Abstract]({paper['links']['abstract']}) | [PDF]({paper['links']['pdf']})")
                output.append("\n---")

            return "\n".join(output)


def main():
    parser = argparse.ArgumentParser(description="Search ArXiv for academic papers")
    parser.add_argument("--query", "-q", help="Search query for title/abstract/content")
    parser.add_argument("--author", "-a", help="Author name")
    parser.add_argument("--category", "-c", help="ArXiv category (e.g., cs.AI, math.CO)")
    parser.add_argument("--id", help="Specific ArXiv ID")
    parser.add_argument("--max-results", "-n", type=int, default=10, help="Maximum number of results (default: 10)")
    parser.add_argument("--sort-by", choices=["relevance", "lastUpdatedDate", "submittedDate"],
                       default="relevance", help="Sort criterion")
    parser.add_argument("--sort-order", choices=["ascending", "descending"],
                       default="descending", help="Sort order")
    parser.add_argument("--format", "-f", choices=["text", "json", "markdown"],
                       default="markdown", help="Output format")

    args = parser.parse_args()

    # Validate input
    if not any([args.query, args.author, args.category, args.id]):
        parser.error("Must provide at least one search criterion (--query, --author, --category, or --id)")

    try:
        # Perform search
        searcher = ArXivSearcher(max_results=args.max_results)
        papers = searcher.search(
            query=args.query,
            author=args.author,
            category=args.category,
            arxiv_id=args.id,
            sort_by=args.sort_by,
            sort_order=args.sort_order
        )

        if not papers:
            print("No papers found matching your search criteria.", file=sys.stderr)
            sys.exit(1)

        # Format and print results
        output = searcher.format_results(papers, output_format=args.format)
        print(output)

    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
