#!/usr/bin/env python3
"""
Link preview metadata extractor using Open Graph and Twitter Card metadata.
Fetches title, description, image, and other metadata from URLs.
Includes special support for YouTube, Twitter, and other oEmbed services.
"""

import json
import re
import sys
import urllib.error
import urllib.request
from html.parser import HTMLParser
from urllib.parse import quote, urljoin, urlparse


def extract_youtube_id(url):
    """Extract YouTube video ID from various YouTube URL formats."""
    patterns = [
        r"(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})",
        r"youtube\.com\/embed\/([a-zA-Z0-9_-]{11})",
        r"youtube\.com\/v\/([a-zA-Z0-9_-]{11})",
        r"youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})",
    ]

    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    return None


def fetch_youtube_metadata(url, timeout=5):
    """Fetch metadata from YouTube using oEmbed API."""
    video_id = extract_youtube_id(url)
    if not video_id:
        return None

    try:
        # Use YouTube oEmbed API
        oembed_url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"

        req = urllib.request.Request(oembed_url)
        with urllib.request.urlopen(req, timeout=timeout) as response:
            data = json.loads(response.read().decode("utf-8"))

        # YouTube oEmbed returns: title, author_name, thumbnail_url, etc.
        # Try to get maxresdefault (1280x720), fall back to hqdefault
        thumbnail = data.get("thumbnail_url", "")
        if "hqdefault" in thumbnail:
            # Try maxresdefault first
            maxres_thumbnail = thumbnail.replace("hqdefault", "maxresdefault")
            # We'll use maxresdefault - if it doesn't exist, YouTube will return hqdefault anyway
            thumbnail = maxres_thumbnail

        return {
            "title": data.get("title", ""),
            "description": f"{data.get('author_name', 'Unknown')}",
            "image": thumbnail,
            "url": url,
            "site_name": "YouTube",
            "type": "video",
            "favicon": "https://www.youtube.com/s/desktop/9c0f82da/img/favicon_144x144.png",
            "author": data.get("author_name", ""),
            "video_id": video_id,
        }
    except Exception as e:
        return None


def fetch_twitter_metadata(url, timeout=5):
    """Fetch metadata from Twitter/X using oEmbed API."""
    try:
        # Twitter oEmbed API
        oembed_url = f"https://publish.twitter.com/oembed?url={quote(url)}"

        req = urllib.request.Request(oembed_url)
        with urllib.request.urlopen(req, timeout=timeout) as response:
            data = json.loads(response.read().decode("utf-8"))

        return {
            "title": data.get("author_name", "Tweet"),
            "description": re.sub(r"<[^>]+>", "", data.get("html", "")),  # Strip HTML
            "image": "",
            "url": url,
            "site_name": "X (Twitter)",
            "type": "article",
            "favicon": "https://abs.twimg.com/favicons/twitter.3.ico",
            "author": data.get("author_name", ""),
        }
    except Exception as e:
        return None


def is_youtube_url(url):
    """Check if URL is a YouTube URL."""
    return "youtube.com" in url or "youtu.be" in url


def is_twitter_url(url):
    """Check if URL is a Twitter/X URL."""
    return "twitter.com" in url or "x.com" in url


class MetaTagParser(HTMLParser):
    """Parser to extract meta tags from HTML."""

    def __init__(self):
        super().__init__()
        self.metadata = {
            "title": "",
            "description": "",
            "image": "",
            "url": "",
            "site_name": "",
            "type": "website",
            "favicon": "",
        }
        self.in_title = False
        self.title_text = ""

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)

        # Handle title tag
        if tag == "title":
            self.in_title = True

        # Handle link tag for favicon
        if tag == "link":
            rel = attrs_dict.get("rel", "")
            href = attrs_dict.get("href", "")
            if rel and "icon" in rel and href:
                self.metadata["favicon"] = href

        # Handle meta tags
        if tag == "meta":
            content = attrs_dict.get("content", "")

            # Open Graph tags
            if "property" in attrs_dict and content:
                prop = attrs_dict["property"]

                if prop == "og:title":
                    self.metadata["title"] = content
                elif prop == "og:description":
                    self.metadata["description"] = content
                elif prop == "og:image":
                    self.metadata["image"] = content
                elif prop == "og:url":
                    self.metadata["url"] = content
                elif prop == "og:site_name":
                    self.metadata["site_name"] = content
                elif prop == "og:type":
                    self.metadata["type"] = content

            # Twitter Card tags (fallback)
            if "name" in attrs_dict and content:
                name = attrs_dict["name"]

                if name == "twitter:title" and not self.metadata["title"]:
                    self.metadata["title"] = content
                elif name == "twitter:description" and not self.metadata["description"]:
                    self.metadata["description"] = content
                elif name == "twitter:image" and not self.metadata["image"]:
                    self.metadata["image"] = content
                elif name == "description" and not self.metadata["description"]:
                    self.metadata["description"] = content

    def handle_data(self, data):
        if self.in_title:
            self.title_text += data

    def handle_endtag(self, tag):
        if tag == "title":
            self.in_title = False
            if not self.metadata["title"]:
                self.metadata["title"] = self.title_text.strip()


def fetch_preview(url, timeout=5):
    """
    Fetch preview metadata for a given URL.

    Args:
        url: The URL to fetch metadata from
        timeout: Request timeout in seconds

    Returns:
        Dictionary with metadata or error information
    """
    try:
        # Validate URL
        parsed = urlparse(url)
        if not parsed.scheme or not parsed.netloc:
            return {"error": "Invalid URL"}

        # Check for special URL types that have oEmbed support
        if is_youtube_url(url):
            result = fetch_youtube_metadata(url, timeout)
            if result:
                return result
            # If oEmbed fails, fall through to regular scraping

        if is_twitter_url(url):
            result = fetch_twitter_metadata(url, timeout)
            if result:
                return result
            # If oEmbed fails, fall through to regular scraping

        # Create request with headers to mimic a browser
        headers = {
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.5",
            "Accept-Encoding": "identity",
            "Connection": "close",
        }

        req = urllib.request.Request(url, headers=headers)

        # Fetch the page
        with urllib.request.urlopen(req, timeout=timeout) as response:
            # Only parse HTML content
            content_type = response.headers.get("Content-Type", "")
            if "text/html" not in content_type:
                return {"error": "Not an HTML page"}

            # Read only first 500KB to avoid large downloads
            html = response.read(500 * 1024).decode("utf-8", errors="ignore")

        # Parse the HTML
        parser = MetaTagParser()
        parser.feed(html)

        # Resolve relative URLs
        base_url = f"{parsed.scheme}://{parsed.netloc}"
        metadata = parser.metadata

        if metadata["image"] and not metadata["image"].startswith(
            ("http://", "https://")
        ):
            metadata["image"] = urljoin(url, metadata["image"])

        if metadata["favicon"] and not metadata["favicon"].startswith(
            ("http://", "https://")
        ):
            metadata["favicon"] = urljoin(url, metadata["favicon"])
        elif not metadata["favicon"]:
            metadata["favicon"] = f"{base_url}/favicon.ico"

        if not metadata["url"]:
            metadata["url"] = url

        # Set site name from domain if not present
        if not metadata["site_name"]:
            metadata["site_name"] = parsed.netloc

        return metadata

    except urllib.error.HTTPError as e:
        return {"error": f"HTTP {e.code}", "url": url}
    except urllib.error.URLError as e:
        return {"error": f"Connection failed: {e.reason}", "url": url}
    except Exception as e:
        return {"error": f"Failed to parse: {str(e)}", "url": url}


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No URL provided"}))
        sys.exit(1)

    url = sys.argv[1]
    timeout = int(sys.argv[2]) if len(sys.argv) > 2 else 5

    result = fetch_preview(url, timeout)
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
