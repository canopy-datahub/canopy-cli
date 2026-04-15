#!/usr/bin/env python3
"""Generate canopy-cli cheatsheet PDF."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.backends.backend_pdf import PdfPages
import os

OUTPUT = os.path.join(os.path.dirname(__file__), 'canopy-cli.pdf')

# ── Colour palette ──────────────────────────────────────────────
BG          = '#FFFDF5'
HEADER_BG   = '#B22222'   # firebrick
HEADER_FG   = 'white'
CELL_BORDER = '#E8D8A0'
TITLE_COLOR = '#B22222'
SUB_COLOR   = '#444444'
CMD_COLOR   = '#222222'
ACCENT_GOLD = '#DAA520'

# ── Command data ────────────────────────────────────────────────
# Each card: (title, [subcommands...], emoji)
CARDS = [
    ("Init", ["init"], None),
    ("Build", ["all", "frontends", "java", "project", "this"], None),
    ("Clean", ["maven all", "maven project", "maven repos"], None),
    ("Check", ["repos", "versions"], None),
    ("Env", ["core", "filter TERM", "list"], None),
    ("Git", [
        "add-commit-push MSG",
        "branch", "checkout BR",
        "clone all",
        "fetch",
        "list branch / tag",
        "next", "pull",
        "remote", "status",
    ], None),
    ("Repo", ["config"], None),
    ("Server", ["status"], None),
    ("Start", [
        "all", "frontends",
        "infra", "java",
        "keycloak / kk",
        "microservices",
        "download", "email",
        "entity", "report",
        "search", "submission",
        "user",
    ], None),
    ("Stop", [
        "all", "frontends",
        "infra", "java",
        "keycloak / kk",
        "microservices",
    ], None),
    ("AWS", [
        "cloudformation deploy",
        "cloudformation status",
        "cloudformation status-all",
        "cloudformation list",
        "ec2 allocate-eip",
        "ecr list",
        "ecs list-services",
        "elb dns",
        "lambda list / invoke",
        "logs list",
        "opensearch endpoint",
        "rds endpoint",
        "s3 list",
        "secrets describe",
        "transfer endpoint",
    ], None),
    ("Cheat", ["cheat"], None),
    ("Status", ["status"], None),
]

# ── Layout ──────────────────────────────────────────────────────
COLS = 5
ROWS = 3

def draw_cheatsheet():
    fig = plt.figure(figsize=(16, 9), dpi=150)
    fig.patch.set_facecolor(BG)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, COLS)
    ax.set_ylim(0, ROWS)
    ax.set_aspect('equal')
    ax.axis('off')

    # Grid dimensions
    pad = 0.06
    header_h = 0.28

    for idx, (title, cmds, _emoji) in enumerate(CARDS):
        col = idx % COLS
        row = ROWS - 1 - idx // COLS  # top-to-bottom

        x0 = col + pad
        y0 = row + pad
        w = 1 - 2 * pad
        h = 1 - 2 * pad

        # Cell background
        cell = mpatches.FancyBboxPatch(
            (x0, y0), w, h,
            boxstyle="round,pad=0.02",
            facecolor='white', edgecolor=CELL_BORDER, linewidth=1.2,
        )
        ax.add_patch(cell)

        # Header bar
        hdr = mpatches.FancyBboxPatch(
            (x0, y0 + h - header_h), w, header_h,
            boxstyle="round,pad=0.02",
            facecolor=HEADER_BG, edgecolor=HEADER_BG, linewidth=0,
        )
        ax.add_patch(hdr)

        # Title text
        ax.text(
            x0 + w / 2, y0 + h - header_h / 2,
            title,
            ha='center', va='center',
            fontsize=11, fontweight='bold', color=HEADER_FG,
            fontfamily='sans-serif',
        )

        # Subcommands
        body_top = y0 + h - header_h - 0.04
        line_h = 0.052
        max_lines = int((body_top - y0 - 0.02) / line_h)
        visible = cmds[:max_lines]

        for i, cmd in enumerate(visible):
            cy = body_top - i * line_h
            ax.text(
                x0 + 0.08, cy,
                cmd,
                ha='left', va='top',
                fontsize=6.5, color=CMD_COLOR,
                fontfamily='monospace',
            )

        if len(cmds) > max_lines:
            ax.text(
                x0 + 0.08, body_top - max_lines * line_h,
                f"... +{len(cmds) - max_lines} more",
                ha='left', va='top',
                fontsize=6, color='#999999',
                fontfamily='monospace', style='italic',
            )

    # ── Title strip at very top ──
    title_y = ROWS - 0.01
    ax.text(
        COLS / 2, title_y,
        'canopy-cli  Cheatsheet',
        ha='center', va='top',
        fontsize=7, color='#999999',
        fontfamily='sans-serif',
    )

    # ── Bottom-right branding ──
    ax.text(
        COLS - 0.08, 0.06,
        'canopy-cli',
        ha='right', va='bottom',
        fontsize=8, fontweight='bold', color=ACCENT_GOLD,
        fontfamily='sans-serif',
    )

    return fig


def main():
    fig = draw_cheatsheet()
    with PdfPages(OUTPUT) as pdf:
        pdf.savefig(fig, facecolor=fig.get_facecolor())
    plt.close(fig)
    print(f"Cheatsheet saved to {OUTPUT}")


if __name__ == '__main__':
    main()
