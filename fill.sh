#!/usr/bin/env bash
# Tile a -15% version of the user's real 30-day pattern, with the extreme June
# spikes capped so the recent weeks don't tower over the rest. Keeps varied,
# random-looking shades across the whole year. Throwaway repo only.
set -euo pipefail

EMAIL="228658663+Mohamed-Alaboudi@users.noreply.github.com"
NAME="Mohamed-Alaboudi"
export GIT_AUTHOR_NAME="$NAME" GIT_COMMITTER_NAME="$NAME"
export GIT_AUTHOR_EMAIL="$EMAIL" GIT_COMMITTER_EMAIL="$EMAIL"

git config gc.auto 0
git config gc.autoDetach false

END_DATE="2026-06-25"
DAYS=365

# Pattern = real 30-day tile, each value *0.85, then spikes capped at 60 so the
# end-of-June cluster blends with the rest. Hand-tuned from:
#   orig: 11 14 15 14 9 14 15 14 17 6 3 10 12 13 15 49 67 107 22 76 24 92 97 37 9 56 56 4 19 63
PATTERN=(9 12 13 12 8 12 13 12 14 5 3 9 10 11 13 42 52 58 19 55 20 57 60 31 8 46 44 3 16 50)
PLEN=${#PATTERN[@]}

# Precompute count[i] (i=0 today, DAYS oldest); tile pattern backward from today.
declare -a COUNT
for ((i=0; i<=DAYS; i++)); do
  j=$(( PLEN - 1 - (i % PLEN) ))
  COUNT[$i]=${PATTERN[$j]}
done

total=0
for ((i=DAYS; i>=0; i--)); do
  day=$(date -j -v-"${i}"d -f "%Y-%m-%d" "$END_DATE" "+%Y-%m-%d")
  n=${COUNT[$i]}
  for ((c=1; c<=n; c++)); do
    hour=$(printf "%02d" $(( RANDOM % 24 )))
    min=$(printf "%02d" $(( RANDOM % 60 )))
    sec=$(printf "%02d" $(( RANDOM % 60 )))
    stamp="${day}T${hour}:${min}:${sec}"
    GIT_AUTHOR_DATE="$stamp" GIT_COMMITTER_DATE="$stamp" \
      git commit -q --allow-empty -m "chore: activity ${day} (${c}/${n})"
    total=$((total+1))
  done
  printf '%s -> %3d (total %d)\n' "$day" "$n" "$total" >&2
done
echo "Created $total commits across $((DAYS+1)) days."
