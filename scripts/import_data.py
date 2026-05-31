#!/usr/bin/env python3
"""
Import Météo-France daily observations into PostgreSQL.

Downloads RR-T-Vent files for selected departments,
filters to 1990+, and imports via COPY (fast bulk insert).

Usage:
    python import_data.py           # import
    python import_data.py --reset   # truncate table then import
"""

import csv
import gzip
import io
import os
import sys

import psycopg2
import requests
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

# ── Configuration ────────────────────────────────────────────────────────────

DEPARTMENTS = ["13", "31", "33", "34", "38", "44", "59", "67", "75", "76"]

BASE_URL = (
    "https://object.files.data.gouv.fr"
    "/meteofrance/data/synchro_ftp/BASE/QUOT"
)
FILE_TEMPLATES = [
    "Q_{dept}_previous-1950-2024_RR-T-Vent.csv.gz",
    "Q_{dept}_latest-2025-2026_RR-T-Vent.csv.gz",
]

DATE_FROM = 19900101  # filtre : on ignore tout avant 1990

DB = dict(
    host=os.getenv("DB_HOST", "localhost"),
    port=int(os.getenv("DB_PORT", "5432")),
    dbname=os.getenv("DB_NAME", "myBdd"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
)

COLUMNS = [
    "num_poste", "nom_usuel", "lat", "lon", "alti", "aaaammjj",
    "rr", "qrr", "tn", "qtn", "htn", "qhtn",
    "tx", "qtx", "htx", "qhtx", "tm", "qtm",
    "tntxm", "qtntxm", "tampli", "qtampli",
    "tnsol", "qtnsol", "tn50", "qtn50", "dg", "qdg",
    "ffm", "qffm", "ff2m", "qff2m",
    "fxy", "qfxy", "dxy", "qdxy", "hxy", "qhxy",
    "fxi", "qfxi", "dxi", "qdxi", "hxi", "qhxi",
    "fxi2", "qfxi2", "dxi2", "qdxi2", "hxi2", "qhxi2",
    "fxi3s", "qfxi3s", "dxi3s", "qdxi3s", "hxi3s", "qhxi3s",
    "drr", "qdrr", "status_fxi3s", "status_dxi3s",
]

BATCH_SIZE = 50_000

# ── Download ──────────────────────────────────────────────────────────────────

def fetch_and_decompress(url: str) -> list[str] | None:
    """Download a .csv.gz file and return its lines. Returns None if 404."""
    print(f"  Downloading {url.split('/')[-1]} ...", end=" ", flush=True)
    resp = requests.get(url, timeout=180)
    if resp.status_code == 404:
        print("(not found, skipped)")
        return None
    resp.raise_for_status()
    content = gzip.decompress(resp.content).decode("utf-8", errors="replace")
    lines = content.splitlines()
    print(f"{len(lines) - 1} raw rows")
    return lines

# ── Import ────────────────────────────────────────────────────────────────────

def copy_lines_to_db(cur, lines: list[str]) -> int:
    """Parse CSV lines, filter by date, bulk-COPY into observations table."""
    reader = csv.DictReader(lines, delimiter=";")
    buf = io.StringIO()
    writer = csv.writer(buf, delimiter="\t")
    count = flushed = 0

    for row in reader:
        row = {k.lower(): v for k, v in row.items()}

        try:
            if int(row.get("aaaammjj", 0)) < DATE_FROM:
                continue
        except ValueError:
            continue

        # Empty string → NULL (\N in PostgreSQL COPY format)
        writer.writerow([row.get(col) or r"\N" for col in COLUMNS])
        count += 1

        if count - flushed >= BATCH_SIZE:
            buf.seek(0)
            cur.copy_from(buf, "observations", sep="\t", null=r"\N", columns=COLUMNS)
            buf = io.StringIO()
            writer = csv.writer(buf, delimiter="\t")
            flushed = count
            print(f"    ... {count:,} rows so far")

    if count > flushed:
        buf.seek(0)
        cur.copy_from(buf, "observations", sep="\t", null=r"\N", columns=COLUMNS)

    return count

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    reset = "--reset" in sys.argv

    print("Connecting to PostgreSQL...")
    conn = psycopg2.connect(**DB)

    if reset:
        with conn.cursor() as cur:
            cur.execute("TRUNCATE TABLE observations;")
        conn.commit()
        print("Table truncated.")

    grand_total = 0

    try:
        for dept in DEPARTMENTS:
            print(f"\n── Department {dept} ──────────────────────")
            dept_total = 0

            for tpl in FILE_TEMPLATES:
                url = f"{BASE_URL}/{tpl.format(dept=dept)}"
                lines = fetch_and_decompress(url)
                if lines is None:
                    continue

                with conn.cursor() as cur:
                    n = copy_lines_to_db(cur, lines)
                conn.commit()

                print(f"    {n:,} rows imported")
                dept_total += n

            print(f"  Department {dept} total : {dept_total:,} rows")
            grand_total += dept_total

    except Exception as e:
        conn.rollback()
        print(f"\nError: {e}", file=sys.stderr)
        raise
    finally:
        conn.close()

    print(f"\n{'=' * 45}")
    print(f"Done. Total rows imported : {grand_total:,}")


if __name__ == "__main__":
    main()
