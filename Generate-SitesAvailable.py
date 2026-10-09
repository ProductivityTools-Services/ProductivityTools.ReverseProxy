#!/usr/bin/env python3
"""
Generate nginx site files in ./sites-available from the Google Sheets endpoint (Apps Script).

Python port of Generate-SitesAvailable.ps1. Behaviour preserved:
  1. ./sites-available is wiped and recreated,
  2. for every sheet row with Address, Ip and Port (skipping "#REF!" and the bare
     ".productivitytools.top" placeholder) a server block is generated:
       - if ./custom-configs/<Address> exists it is used as a template
         (__ADDRESS__, __IP__, __PORT__ are substituted),
       - otherwise the default `proxy_pass http://<Ip>:<Port>` block is used,
  3. remaining files in ./custom-configs (not matching any sheet row) are copied
     as standalone sites with __ADDRESS__ replaced by the file name.

Files are written without a trailing newline, LF line endings, UTF-8 - identical to
the PowerShell output, so `git diff` stays clean.

Usage:
  python3 Generate-SitesAvailable.py            # regenerate ./sites-available
  python3 Generate-SitesAvailable.py --dry-run  # list what would be generated, touch nothing
"""

import argparse
import json
import shutil
import sys
import urllib.request
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
TARGET_DIR = SCRIPT_DIR / "sites-available"
CUSTOM_CONFIG_DIR = SCRIPT_DIR / "custom-configs"

DATA_URL = (
    "https://script.google.com/macros/s/"
    "AKfycbyMXkh3v12rqFIkeDG3dzK6WRta9TKilVJ3IOUqt-1599PnwrP5KP_-wPUyOXDbW44Z/exec"
)

DEFAULT_TEMPLATE = """server {
        listen 80;
        listen [::]:80;

        server_name __ADDRESS__;

        location / {
                proxy_pass http://__IP__:__PORT__;
        }
}"""

SKIPPED_ADDRESSES = {"#REF!", ".productivitytools.top"}


def fetch_rows(url: str) -> list[dict]:
    print(f"Fetching data from {url}")
    req = urllib.request.Request(url, headers={"User-Agent": "Generate-SitesAvailable.py"})
    with urllib.request.urlopen(req, timeout=60) as resp:  # follows redirects
        payload = json.load(resp)
    rows = payload.get("data")
    if not isinstance(rows, list):
        raise SystemExit(f"Unexpected response shape, expected {{'data': [...]}}, got keys: {list(payload)}")
    return rows


def is_blank(value) -> bool:
    """Mirror PowerShell truthiness for the fields we care about: None, '' and 0 are 'missing'."""
    return value is None or value == "" or value == 0


def render(template: str, address: str, ip: str = "", port: str = "") -> str:
    return (
        template.replace("__ADDRESS__", address)
        .replace("__IP__", str(ip))
        .replace("__PORT__", str(port))
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dry-run", action="store_true", help="print what would be generated without touching files")
    parser.add_argument("--url", default=DATA_URL, help="override the data endpoint")
    parser.add_argument("-v", "--verbose", action="store_true", help="log skipped rows")
    args = parser.parse_args()

    rows = fetch_rows(args.url)

    # 1. Wipe / create target directory
    if not args.dry_run:
        if TARGET_DIR.exists():
            print(f"Clearing directory: {TARGET_DIR}")
            shutil.rmtree(TARGET_DIR)
        else:
            print(f"Creating directory: {TARGET_DIR}")
        TARGET_DIR.mkdir(parents=True)

    generated: list[str] = []

    def write_site(file_name: str, content: str) -> None:
        if not args.dry_run:
            (TARGET_DIR / file_name).write_text(content, encoding="utf-8", newline="\n")
        generated.append(file_name)

    # 2. Sites from sheet rows
    for item in rows:
        address = item.get("Address")
        ip = item.get("Ip")
        port = item.get("Port")

        if is_blank(address) or is_blank(ip) or is_blank(port) or address in SKIPPED_ADDRESSES:
            if args.verbose:
                print(f"Skipping incomplete or invalid item: {json.dumps(item, ensure_ascii=False)}")
            continue

        custom_file = CUSTOM_CONFIG_DIR / address
        if custom_file.is_file():
            print(f"Using custom template for API site: {address}")
            template = custom_file.read_text(encoding="utf-8-sig")
        else:
            template = DEFAULT_TEMPLATE

        print(f"Generating file: {address}")
        write_site(address, render(template, address, ip, port))

    # 3. Standalone custom configs not backed by a sheet row
    if CUSTOM_CONFIG_DIR.is_dir():
        for custom_file in sorted(p for p in CUSTOM_CONFIG_DIR.iterdir() if p.is_file()):
            if custom_file.name in generated:
                continue
            print(f"Processing standalone custom config: {custom_file.name}")
            template = custom_file.read_text(encoding="utf-8-sig")
            write_site(custom_file.name, render(template, custom_file.name))

    suffix = " (dry-run, nothing written)" if args.dry_run else ""
    print(f"Generation complete. Generated {len(generated)} sites{suffix}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
