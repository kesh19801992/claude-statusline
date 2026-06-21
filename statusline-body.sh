# ── claude-statusline render — expects $input (the JSON Claude Code pipes to statusLine) ──
# deps: jq (required), git (optional, for the branch segment). Safe to run after: input=$(cat)
# Functions are namespaced (_csl_*) so this block can be appended into another statusline
# script (e.g. Vibe Island) without clobbering its functions.
_now=$(date +%s)
_model=$(printf '%s' "$input" | jq -r '.model.display_name // "?"' 2>/dev/null)
_ctx=$(printf '%s'   "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
_dir=$(basename "$PWD" 2>/dev/null)
_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
# rate limits: live from stdin, fall back to Vibe Island cache if present
_rl=$(printf '%s' "$input" | jq -c '.rate_limits // empty' 2>/dev/null)
[ -z "$_rl" ] && _rl=$(cat "$HOME/.vibe-island/cache/rl.json" 2>/dev/null)
_p5=$(printf '%s' "$_rl" | jq -r '.five_hour.used_percentage // 0' 2>/dev/null)
_r5=$(printf '%s' "$_rl" | jq -r '.five_hour.resets_at // 0' 2>/dev/null)
_p7=$(printf '%s' "$_rl" | jq -r '.seven_day.used_percentage // 0' 2>/dev/null)
_r7=$(printf '%s' "$_rl" | jq -r '.seven_day.resets_at // 0' 2>/dev/null)

_dim=$'\033[90m'; _rst=$'\033[0m'; _bold=$'\033[1m'

# _csl_clr <pct> [yellow] [red] : color by load (default <50 green, 50-69 yellow, >=70 red)
# green = emerald/翠绿 (truecolor #2ecc71); needs a truecolor terminal (Ghostty/iTerm2/modern).
_csl_clr() {
  local p=${1%.*} y=${2:-50} r=${3:-70}; [ -z "$p" ] && p=0
  if   [ "$p" -ge "$r" ]; then printf '\033[31m'
  elif [ "$p" -ge "$y" ]; then printf '\033[33m'
  else                         printf '\033[38;2;46;204;113m'; fi
}

# _csl_bar <pct> <width> [yellow] [red] : colored progress bar (fill tinted by load)
_csl_bar() {
  local p=${1%.*} w=$2 y=${3:-50} r=${4:-70}; [ -z "$p" ] && p=0
  local f=$(( p * w / 100 )); [ $f -gt $w ] && f=$w; [ $f -lt 0 ] && f=0
  local e=$(( w - f ))
  printf '%s' "$(_csl_clr "$p" "$y" "$r")"; local i=0
  while [ $i -lt $f ]; do printf '█'; i=$((i+1)); done
  printf '\033[90m'; i=0
  while [ $i -lt $e ]; do printf '░'; i=$((i+1)); done
  printf '\033[0m'
}

# _csl_eta <unix_ts> : human countdown until reset
_csl_eta() {
  local t=${1%.*}; { [ -z "$t" ] || [ "$t" -le 0 ]; } 2>/dev/null && { printf '?'; return; }
  local d=$(( t - _now )); [ $d -lt 0 ] && d=0
  printf '%dh%02dm' $(( d/3600 )) $(( (d%3600)/60 ))
}

# line 1: model · dir · branch
printf '%s%s%s  %s' "$_bold" "$_model" "$_rst" "$_dir"
[ -n "$_branch" ] && printf ' %sgit:(%s)%s' "$_dim" "$_branch" "$_rst"
printf '\n'

# line 2: context · 5h usage · weekly usage  (number tinted to match its bar)
# Context/Usage use default 50/70 thresholds; Weekly raises the red line to 80.
_l2=""
[ -n "$_ctx" ] && _l2="Context $(_csl_bar "$_ctx" 8) $(_csl_clr "$_ctx")${_ctx%.*}%${_rst}   "
_l2="${_l2}Usage $(_csl_bar "$_p5" 8) $(_csl_clr "$_p5")${_p5%.*}%${_rst} ${_dim}($(_csl_eta "$_r5"))${_rst}"
_l2="${_l2}   Weekly $(_csl_bar "$_p7" 8 50 80) $(_csl_clr "$_p7" 50 80)${_p7%.*}%${_rst} ${_dim}($(_csl_eta "$_r7"))${_rst}"
printf '%s' "$_l2"
