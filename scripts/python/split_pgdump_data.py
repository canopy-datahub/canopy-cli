#!/usr/bin/env python3
"""
split_pgdump_data.py
====================

Splits a pg_dump-style data dump (INSERTs / COPY blocks) into per-table files.

Companion to split_pgdump.py, which handles schema/DDL dumps. Used to split
03_populate_base_tables.sql and 04_populate_variable_tables.sql into
canopy-cli/assets/db/postgres/init/7NN_data_<table>.sql files.

Each pg_dump block looks like:

    --
    -- TOC entry NN (class 0 OID K)
    -- Dependencies: ...
    -- Data for Name: <table>; Type: TABLE DATA; Schema: public; Owner: ...
    --

    INSERT INTO public.<table> VALUES (...);
    INSERT ...

    -- or, for sequence resets:

    --
    -- TOC entry NN (class 0 OID 0)
    -- Name: <seq>; Type: SEQUENCE SET; Schema: public; Owner: ...
    --

    SELECT pg_catalog.setval('public.<seq>', N, true);

ROUTING
-------
   - TABLE DATA <table>     -> 7NN_data_<table>.sql (sequential by appearance)
   - SEQUENCE SET <seq>     -> 800_sequence_resets.sql (single bundle)
   - Preamble (file head)   -> ignored (just SET statements; DDL files set them)
   - Tail (post-final TOC)  -> appended to 800_sequence_resets.sql

USAGE
-----
    python3 split_pgdump_data.py <input.sql> <output-dir> [--start NUM]

The optional --start lets you continue the 7NN sequence across multiple
input files. Default is 700 for the first call. Run with --start 725 (for
example) to continue numbering from a previous run.
"""

import argparse
import re
import sys
from pathlib import Path

DATA_NAME_RE = re.compile(
    r"^-- Data for Name: (.+?); Type: TABLE DATA;", re.IGNORECASE
)
NAME_RE = re.compile(r"^-- Name: (.+?); Type: ([A-Z ]+);", re.IGNORECASE)
TOC_RE = re.compile(r"^-- TOC entry ", re.IGNORECASE)
SEQ_SET_RE = re.compile(
    r"^-- Name: (.+?); Type: SEQUENCE SET;", re.IGNORECASE
)


def is_block_start(line: str) -> bool:
    """A new block starts at a TOC entry OR (for files without TOC) at
    a Data-for-Name / Name SEQUENCE SET header line."""
    return bool(TOC_RE.match(line) or DATA_NAME_RE.match(line) or SEQ_SET_RE.match(line))


def parse_blocks(lines):
    """Yield (kind, name, block_lines).

    kind is one of: 'preamble', 'data', 'sequence_set', 'other'.
    The first yielded block is the preamble (everything before the first
    block start). Subsequent blocks are classified by their header.
    """
    block = []
    is_first = True

    def classify(blk):
        if is_first_yield:
            return "preamble", None
        for ln in blk:
            m = DATA_NAME_RE.match(ln)
            if m:
                return "data", m.group(1).strip()
            m = SEQ_SET_RE.match(ln)
            if m:
                return "sequence_set", m.group(1).strip()
        return "other", None

    is_first_yield = True
    for line in lines:
        if is_block_start(line):
            if block:
                # When the previous block is just the boundary "--" line(s)
                # before a new header, attach them to the new block instead.
                # Heuristic: if the previous block's non-blank content is only
                # "--" lines, treat it as part of the upcoming block.
                stripped = [l for l in block if l.strip() and l.strip() != "--"]
                if stripped or is_first_yield:
                    k, n = classify(block)
                    yield (k, n, block)
                    is_first_yield = False
                    block = []
                # else: drop the bare "--" lines (they belong to the new block)
            block.append(line)
        else:
            block.append(line)
    if block:
        k, n = classify(block)
        yield (k, n, block)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input", type=Path)
    ap.add_argument("outdir", type=Path)
    ap.add_argument("--start", type=int, default=700,
                    help="starting index for 7NN_data_*.sql files (default 700)")
    args = ap.parse_args()

    if not args.input.exists():
        print(f"Input not found: {args.input}", file=sys.stderr)
        return 2
    args.outdir.mkdir(parents=True, exist_ok=True)

    print(f"Reading {args.input}…")
    lines = args.input.read_text().splitlines(keepends=True)
    print(f"  {len(lines):,} lines")

    data_files = []         # list of (filename, lines)
    sequence_block = []     # accumulated SEQUENCE SET blocks
    other_tail = []         # any uncategorized tail

    idx = args.start
    for kind, name, blk in parse_blocks(lines):
        if kind == "preamble":
            # discard pg_dump SET preamble; DDL files already set these
            continue
        if kind == "data":
            fname = f"{idx}_data_{name}.sql"
            idx += 1
            data_files.append((fname, blk))
        elif kind == "sequence_set":
            sequence_block.extend(blk)
        else:
            other_tail.extend(blk)

    print(f"\nWriting {len(data_files)} data files + 1 sequence file to {args.outdir}\n")

    written = []
    for fname, blk in data_files:
        path = args.outdir / fname
        path.write_text("".join(blk))
        written.append((fname, path.stat().st_size))

    if sequence_block or other_tail:
        seq_path = args.outdir / "800_sequence_resets.sql"
        # append if exists (multi-input), else create
        mode = "a" if seq_path.exists() else "w"
        with seq_path.open(mode) as f:
            f.write("".join(sequence_block))
            if other_tail:
                f.write("".join(other_tail))
        written.append(("800_sequence_resets.sql", seq_path.stat().st_size))

    for fname, size in written:
        print(f"     {fname:<55s} {size/1024:6.1f} KB")

    print(f"\nNext --start: {idx}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
