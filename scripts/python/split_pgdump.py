#!/usr/bin/env python3
"""
split_pgdump.py
===============

Splits a pg_dump-style schema file into per-object files for cleaner version
control and review. Used to maintain canopy-cli/assets/db/postgres/init/.

Each pg_dump TOC block looks like:

    --
    -- TOC entry NN (class M OID K)
    -- Name: <object>; Type: <TYPE>; Schema: <schema>; Owner: <owner>
    [-- Dependencies: ...]
    --

    [SQL statement(s)]

ROUTING
-------
Two passes over the file:

1. **Discovery**: scan all `-- Name: ... ; Type: ...` headers to build the
   complete set of public tables, history tables, and views. Each table
   gets a stable numeric index — `TABLE_ORDER` listed entries first, then
   alphabetical for the rest.

2. **Routing**: each block is dispatched based on its (Name, Type):

   - SCHEMA / SCHEMA COMMENT      -> 020_schemas.sql
   - FUNCTION (+ FUNCTION ACL)    -> 030_functions.sql / 600_grants.sql
   - PROCEDURE                    -> 040_procedures.sql
   - TYPE                         -> 050_types.sql
   - public.<table>               -> 1NN_table_<name>.sql
       (CREATE TABLE, SEQUENCE, DEFAULT, PKey, INDEX, GRANT, COMMENT)
   - canopy_history.<x>_history   -> 2NN_history_<x>.sql
   - VIEW (+ TABLE <view> ACL)    -> 400_views.sql
   - FK CONSTRAINT                -> 300_foreign_keys.sql
   - TRIGGER                      -> 500_triggers.sql
   - DEFAULT ACL                  -> 600_grants.sql
   - Tail content (post-TOC)      -> 600_grants.sql
   - Anything else                -> 999_misc.sql (review manually)

USAGE
-----
    python3 split_pgdump.py <input.sql> <output-dir>
"""

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

# ----------------------------------------------------------------------------
# Block parsing
# ----------------------------------------------------------------------------

NAME_RE = re.compile(r"^-- Name: (.+?); Type: ([A-Z ]+);", re.IGNORECASE)
TOC_RE = re.compile(r"^-- TOC entry ", re.IGNORECASE)


def parse_blocks(lines):
    """Yield (name, obj_type, block_lines, is_first). The first block is the
    file preamble (everything before the first -- TOC entry)."""
    block = []
    name = None
    obj_type = None
    is_first = True

    for line in lines:
        if TOC_RE.match(line):
            if block:
                yield (name, obj_type, block, is_first)
                is_first = False
            block = [line]
            name = None
            obj_type = None
        else:
            if name is None:
                m = NAME_RE.match(line)
                if m:
                    name = m.group(1).strip()
                    obj_type = m.group(2).strip().upper()
            block.append(line)
    if block:
        yield (name, obj_type, block, is_first)


# ----------------------------------------------------------------------------
# Per-table ordering hint — listed tables get stable numbers in this order.
# Unlisted tables are assigned alphabetically *after* this list.
# ----------------------------------------------------------------------------

TABLE_ORDER = [
    # Lookups
    "lkup_role",
    "lkup_status",
    "lkup_country",
    "lkup_state",
    "lkup_institution_type",
    "lkup_referrer",
    "lkup_researcher_level",
    "lkup_resolution_type",
    "lkup_support_request_type",
    "lkup_severity",
    "lkup_assignee",
    "lkup_news_type",
    "lkup_event_type",
    "lkup_data_file_category",
    "lkup_file_type",
    "lkup_property_codelist",
    "lkup_property_codelist_value",
    "lkup_property_source",
    "lkup_property_type",
    "lkup_entity_type",
    "lkup_metrics_report_type",
    "lkup_submission_step",
    "lkup_variable_category",
    "lkup_center",
    "lkup_core_variable_property_value",
    "lkup_core_variable_permissible_value",
    # Users / auth
    "users",
    "user_role",
    "user_login",
    "user_referrer",
    "user_file_upload",
    "institution",
    # Studies
    "study",
    "study_property_value",
    "variables",
    "entity_property",
    "entity_property_display_setting",
    "entity_property_mta_mapping",
    # Submissions / data files
    "data_submission",
    "data_file",
    "data_file_download",
    "s3_file",
    "sas_data_file",
    # Support
    "support_request",
    # Metrics / reports
    "metrics_report",
    "hub_content_metrics",
    "user_metrics",
    "datafile_harmonization_metrics",
    # Content
    "events",
    "event_link",
    "news",
    "newsletter",
    "funding",
]


def build_indices(table_names: set, history_table_names: set):
    """Return {table -> filename} for both public tables and canopy_history mirrors.

    TABLE_ORDER entries get prefix 100, 101, 102, … in order.
    Unlisted tables get sequential numbers after the listed ones, alphabetical.
    History tables use prefix 200, 201, … aligned with their public counterpart
    when listed; unlisted history tables are alphabetical after.
    """
    table_index: dict[str, int] = {}

    for i, name in enumerate(TABLE_ORDER):
        if name in table_names:
            table_index[name] = i

    extras = sorted(table_names - set(TABLE_ORDER))
    next_idx = len(TABLE_ORDER)
    for name in extras:
        table_index[name] = next_idx
        next_idx += 1

    table_files: dict[str, str] = {
        name: f"{100 + idx}_table_{name}.sql" for name, idx in table_index.items()
    }

    history_files: dict[str, str] = {}
    history_extras_sorted = []
    for name in history_table_names:
        # canopy_history.<x>_history → use index of <x> if known
        base = name[: -len("_history")] if name.endswith("_history") else name
        if base in table_index:
            history_files[name] = f"{200 + table_index[base]}_history_{base}.sql"
        else:
            history_extras_sorted.append(name)

    history_extras_sorted.sort()
    extras_start = 200 + max((idx for idx in table_index.values()), default=0) + 1
    for offset, name in enumerate(history_extras_sorted):
        base = name[: -len("_history")] if name.endswith("_history") else name
        history_files[name] = f"{extras_start + offset}_history_{base}.sql"

    return table_files, history_files


def first_token(s: str) -> str:
    return s.split()[0] if s else ""


# ----------------------------------------------------------------------------
# Routing
# ----------------------------------------------------------------------------

def route_block(
    name: str | None,
    obj_type: str | None,
    table_files: dict,
    history_files: dict,
    view_names: set,
) -> str:
    """Return the target filename for a block."""
    if not name or not obj_type:
        return "999_misc.sql"

    # ACL entries — pg_dump names them "TABLE <obj>" / "FUNCTION <obj>()" / etc.
    if obj_type == "ACL":
        parts = name.split(maxsplit=1)
        if len(parts) == 2:
            kind, target = parts[0].upper(), parts[1].strip()
            if kind == "TABLE":
                # Could be a real table, a history table, or a view —
                # pg_dump uses TABLE for all of them in ACL names.
                if target in view_names:
                    return "400_views.sql"
                if target in history_files:
                    return history_files[target]
                if target in table_files:
                    return table_files[target]
                # unknown — bucket to grants
                return "600_grants.sql"
            # Function / type / sequence ACLs go to grants
            return "600_grants.sql"
        return "600_grants.sql"

    # Comments — route based on what they're commenting on
    if obj_type == "COMMENT":
        parts = name.split(maxsplit=1)
        if len(parts) == 2:
            kind, target = parts[0].upper(), parts[1].strip()
            if kind == "SCHEMA":
                return "020_schemas.sql"
            if kind == "TABLE":
                tbl = target.split(".")[-1]
                if tbl in table_files:
                    return table_files[tbl]
                if tbl in history_files:
                    return history_files[tbl]
            if kind == "COLUMN":
                # COLUMN public.foo.bar → routes to foo's file
                bits = target.split(".")
                if len(bits) >= 2:
                    tbl = bits[-2]
                    if tbl in table_files:
                        return table_files[tbl]
        return "999_misc.sql"

    if obj_type == "SCHEMA":
        return "020_schemas.sql"
    if obj_type == "EXTENSION":
        # Extensions must load before functions that reference their types
        # (e.g. hstore is used by the audit trigger function in 030).
        return "015_extensions.sql"
    if obj_type == "FUNCTION":
        return "030_functions.sql"
    if obj_type == "PROCEDURE":
        return "040_procedures.sql"
    if obj_type == "TYPE":
        return "050_types.sql"
    if obj_type == "VIEW":
        return "400_views.sql"
    if obj_type == "FK CONSTRAINT":
        return "300_foreign_keys.sql"
    if obj_type == "TRIGGER":
        return "500_triggers.sql"
    if obj_type == "DEFAULT ACL":
        return "600_grants.sql"

    # Per-table bundle: TABLE, SEQUENCE, SEQUENCE OWNED BY, DEFAULT,
    # CONSTRAINT (PK), INDEX, MATERIALIZED VIEW
    target = first_token(name)

    # Sequences for table id columns: <table>_id_seq
    if obj_type in ("SEQUENCE", "SEQUENCE OWNED BY") and target.endswith("_id_seq"):
        target = target[: -len("_id_seq")]

    if target in history_files:
        return history_files[target]
    if target in table_files:
        return table_files[target]

    if obj_type in ("TABLE", "SEQUENCE", "SEQUENCE OWNED BY", "DEFAULT", "CONSTRAINT", "INDEX"):
        return "999_misc.sql"

    return "999_misc.sql"


# ----------------------------------------------------------------------------
# Discovery pass
# ----------------------------------------------------------------------------

def discover(lines):
    """First pass: find all public tables, history tables, and views."""
    tables: set = set()
    history_tables: set = set()
    views: set = set()

    for line in lines:
        m = NAME_RE.match(line)
        if not m:
            continue
        name = m.group(1).strip()
        obj_type = m.group(2).strip().upper()

        if obj_type == "TABLE":
            tok = first_token(name)
            if tok.endswith("_history"):
                history_tables.add(tok)
            else:
                tables.add(tok)
        elif obj_type == "VIEW":
            views.add(first_token(name))

    return tables, history_tables, views


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description="Split a pg_dump schema file into per-object files.")
    ap.add_argument("input", type=Path, help="Input pg_dump SQL file")
    ap.add_argument("output_dir", type=Path, help="Output directory (existing files overwritten)")
    ap.add_argument(
        "--preamble-file",
        default="000_preamble.sql",
        help="Filename for pg_dump preamble (SET commands etc.) — default: 000_preamble.sql",
    )
    ap.add_argument(
        "--app-user",
        default="canopy_user",
        help=(
            "Literal app-user role name as it appears in the source pg_dump "
            "output (default: canopy_user). All `GRANT … TO <app-user>;` lines "
            "in per-table / per-history / views files are stripped, and any "
            "`ALTER … OWNER TO <app-user>;` is rewritten to `OWNER TO "
            "canopy_admin;`. The intent is that 600_grants.sql alone owns "
            "every grant to the app user (parameterized via :'app_user'), so "
            "the per-table files are role-name-neutral."
        ),
    )
    args = ap.parse_args()

    if not args.input.is_file():
        print(f"Input not found: {args.input}", file=sys.stderr)
        sys.exit(2)

    args.output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Reading {args.input}…")
    lines = args.input.read_text().splitlines(keepends=True)
    print(f"  {len(lines):,} lines")

    print("Discovering tables and views…")
    tables, history_tables, views = discover(lines)
    print(f"  {len(tables)} public tables, {len(history_tables)} history tables, {len(views)} views")

    table_files, history_files = build_indices(tables, history_tables)

    # Bucket each block to a target filename
    buckets: dict[str, list[str]] = defaultdict(list)
    block_count = 0
    misc_blocks: list[tuple] = []

    for name, obj_type, block, is_first in parse_blocks(lines):
        if is_first:
            buckets[args.preamble_file].extend(block)
            continue
        if not name:
            # Trailing content after the last TOC block (e.g. manually-appended GRANTs)
            buckets["600_grants.sql"].extend(block)
            continue
        target = route_block(name, obj_type, table_files, history_files, views)
        buckets[target].extend(block)
        block_count += 1
        if target == "999_misc.sql":
            misc_blocks.append((name, obj_type))

    # Post-process per-table / per-history / views buckets: strip per-object
    # GRANTs to the app user (600_grants.sql does broad parameterized grants
    # via :'app_user'), and normalise object ownership to canopy_admin.
    strip_re = re.compile(rf"^GRANT .* TO {re.escape(args.app_user)};\s*$")
    owner_re = re.compile(
        rf"^(ALTER (?:VIEW|TABLE|SEQUENCE|MATERIALIZED VIEW) .* OWNER TO )"
        rf"{re.escape(args.app_user)}(;\s*)$"
    )
    cleaned_grants = 0
    cleaned_owners = 0
    for filename, lines in list(buckets.items()):
        if not (filename.startswith(("1", "2")) and "_table_" in filename
                or filename.startswith(("2",)) and "_history_" in filename
                or filename == "400_views.sql"):
            continue
        new_lines = []
        for line in lines:
            if strip_re.match(line):
                cleaned_grants += 1
                continue
            m = owner_re.match(line)
            if m:
                line = f"{m.group(1)}canopy_admin{m.group(2)}"
                cleaned_owners += 1
            new_lines.append(line)
        buckets[filename] = new_lines
    if cleaned_grants or cleaned_owners:
        print(
            f"\nPost-process: stripped {cleaned_grants} `GRANT … TO "
            f"{args.app_user};` lines, rewrote {cleaned_owners} "
            f"`OWNER TO {args.app_user};` → `OWNER TO canopy_admin;`."
        )

    print(f"\nWriting {len(buckets)} files to {args.output_dir}/")
    written = []
    for filename in sorted(buckets):
        path = args.output_dir / filename
        path.write_text("".join(buckets[filename]))
        written.append((filename, path.stat().st_size))

    print(f"\nWrote {block_count:,} blocks across {len(buckets)} files:")
    for filename, size in written:
        kb = size / 1024
        marker = "  ⚠" if filename == "999_misc.sql" else "   "
        print(f"  {marker}{filename:50s} {kb:8.1f} KB")

    if misc_blocks:
        print(f"\n⚠ {len(misc_blocks)} blocks ended up in 999_misc.sql:")
        for name, obj_type in misc_blocks:
            print(f"    - {obj_type}: {name}")


if __name__ == "__main__":
    main()
