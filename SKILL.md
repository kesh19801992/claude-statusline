---
name: claude-statusline
description: Install or update a colored Claude Code status line (model, dir/branch, context %, 5h & weekly usage with reset countdowns). Use when the user wants to set up, enable, install, import, restore, or update the terminal status line / bottom status bar — on this machine or a new one. Auto-detects Vibe Island and keeps its notch display working.
---

# claude-statusline

Installs a custom Claude Code **statusLine** that renders at the bottom of the terminal:

```
Opus 4.8 (1M context)  myproject git:(main)
Context ███░░░░░ 42%   Usage ████░░░░ 58% (2h05m)   Weekly ██████░░ 82% (40h00m)
```

Colored bars + matching numbers. Thresholds: Context/Usage → emerald green <50, yellow 50–69, red ≥70. Weekly → red line raised to 80. Green is emerald (#2ecc71, truecolor).

## How it works (no external service needed)

Claude Code pipes a JSON to the program named in `statusLine.command` on every assistant message — it contains `model`, `context_window.used_percentage`, `rate_limits` (5h + weekly), `cwd`, `cost`, etc. The script reads that JSON from **stdin** and prints the bar to **stdout**. `rate_limits` comes from Claude Code itself; Vibe Island is NOT required.

## To install or update — run the bundled installer

```bash
bash ~/.claude/skills/claude-statusline/install.sh
```

(If this skill lives under a project's `.claude/skills/` instead of `~/.claude/skills/`, run `install.sh` from that path.)

The installer auto-detects the machine and is safe to re-run:

- **Vibe Island present** (`~/.vibe-island/bin/vibe-island-statusline` exists) → appends the render block, wrapped in markers, to the end of that script. The notch/灵动岛 keeps working and `statusLine.command` is left untouched.
- **No Vibe Island** → writes `~/.claude/statusline.sh` and registers it in `~/.claude/settings.json` (`.statusLine`).

It backs up every file it changes (`*.bak.<timestamp>`), is idempotent (re-running replaces the marked block instead of duplicating), and prints a synthetic-data preview at the end.

**Requirements:** `jq` (the installer aborts with an install hint if missing). `git` is optional — only used for the branch segment.

After it runs: tell the user to reopen Claude Code or send any message to see it, and report which mode was used + the preview.

## Customizing

Edit `statusline-body.sh`, then re-run the installer to apply:

- **Colors:** `_csl_clr` — green is `\033[38;2;46;204;113m` (emerald, truecolor); yellow `\033[33m`; red `\033[31m`.
- **Thresholds:** per-bar `[yellow] [red]` args. Defaults `50 70`; the Weekly line passes `50 80`.
- **Bar width:** the `8` args to `_csl_bar`.
- **More segments:** the input JSON also has `.cost.total_cost_usd`, `.version`, `.effort`, `.fast_mode` — add them to the output lines if wanted.
