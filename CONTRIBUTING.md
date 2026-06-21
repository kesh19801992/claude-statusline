# Contributing to claude-statusline

Thanks for your interest! This is a tiny, single-purpose tool, so the bar for contributing is low — but a few conventions keep it tidy.

## Project layout

| File | Purpose |
| --- | --- |
| `statusline-body.sh` | The renderer. **Edit this to change appearance** (colors, thresholds, segments). Reads the Claude Code JSON from `$input`, prints to stdout. |
| `install.sh` | Idempotent installer. Auto-detects Vibe Island; appends a marker-wrapped block or writes a standalone script + registers `settings.json`. |
| `SKILL.md` | Makes the repo usable as a Claude Code skill (`/claude-statusline`). |
| `assets/` | README images (PNG/SVG/GIF). |

## Development

**Requirements:** `bash`, `jq`. Optional: `git` (branch segment), ImageMagick + a headless browser (only to regenerate `assets/`).

**Lint** before every commit:

```bash
bash -n install.sh
bash -n <(printf '#!/bin/bash\ninput="{}"\n'; cat statusline-body.sh)
```

**Manually test the renderer** with a synthetic payload:

```bash
now=$(date +%s)
sample='{"model":{"display_name":"Opus 4.8"},"context_window":{"used_percentage":58},
"rate_limits":{"five_hour":{"used_percentage":47,"resets_at":'$((now+9000))'},
"seven_day":{"used_percentage":82,"resets_at":'$((now+300000))'}}}'
printf '%s' "$sample" | bash <(printf '#!/bin/bash\ninput=$(cat)\n'; cat statusline-body.sh)
```

`install.sh` is safe to re-run; it backs up every file it edits (`*.bak.<timestamp>`).

## Commit messages — [Conventional Commits](https://www.conventionalcommits.org/)

Format:

```
<type>(<optional scope>): <subject>
```

- **Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`.
- **Subject:** imperative mood, lower-case, no trailing period, ≤ 72 chars (`add weekly reset countdown`, not `Added ...`).
- Body (optional): explain *why*, wrap at ~72 cols. Reference issues like `Closes #12`.
- Breaking change: add `!` after type/scope (`feat!:`) and a `BREAKING CHANGE:` footer.

Examples:

```
feat(render): add session cost segment from .cost.total_cost_usd
fix(install): keep file perms by writing in place instead of mv
docs: translate README to zh-CN
```

## Pull requests

- Keep each PR to one logical change.
- Run the lint commands above; make sure `bash -n` passes.
- If you change the **appearance**, regenerate / attach a before-and-after screenshot.
- If you change **behavior**, update **both** `README.md` and `README.zh-CN.md`.

## Code style (bash)

- Target `/bin/bash` 3.2 (macOS default) — avoid `mapfile`, `${var^^}`, associative arrays.
- Keep renderer functions namespaced (`_csl_*`) so the block stays safe when appended into another script (e.g. Vibe Island).
- Quote variables; prefer `printf` over `echo` for anything with escapes.

## License

By contributing, you agree your contributions are licensed under the [MIT License](LICENSE).
