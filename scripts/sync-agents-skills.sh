#!/usr/bin/env bash
set -euo pipefail

# Mirrors the promoted skills (skills/engineering and skills/productivity) into
# .agents/skills/<skill-name>/ so harnesses that only scan the fixed
# .agents/skills root, one level deep, discover them. Devin Cloud is one of
# those: it indexes SKILL.md files from a repo's committed contents, so the
# mirror has to be real files rather than symlinks.
#
# The mirror is generated. Edit skills/ and re-run this script after adding,
# removing, or renaming a skill, or after syncing with upstream.
#
# Usage: sync-agents-skills.sh [source-checkout]
# With no argument the skills are read from this repo's own skills/ directory.
# Pass a path to another checkout (for example a clone of mattpocock/skills at
# a given tag) to regenerate the mirror from that source instead; this is what
# .github/workflows/sync-skills.yml does.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:-$REPO}"
if [ ! -d "$SRC/skills" ]; then
  echo "error: '$SRC' has no skills/ directory." >&2
  exit 1
fi
DEST="$REPO/.agents/skills"
BUCKETS=("engineering" "productivity")

rm -rf "$DEST"
mkdir -p "$DEST"

for bucket in "${BUCKETS[@]}"; do
  while IFS= read -r -d '' skill_md; do
    src="$(dirname "$skill_md")"
    name="$(basename "$src")"
    if [ -e "$DEST/$name" ]; then
      echo "error: duplicate skill name '$name' ($src)." >&2
      exit 1
    fi
    cp -R "$src" "$DEST/$name"
    echo "mirrored $bucket/$name"
  done < <(find "$SRC/skills/$bucket" -name SKILL.md -not -path '*/node_modules/*' -print0 | sort -z)
done

cat > "$DEST/README.md" <<'EOF'
# .agents/skills

Generated mirror of the promoted skills in [`skills/`](../../skills), produced by
[`scripts/sync-agents-skills.sh`](../../scripts/sync-agents-skills.sh).

`skills/` groups skills into bucket folders (`engineering/`, `productivity/`),
which puts every `SKILL.md` one level deeper than harnesses that scan
`.agents/skills/<skill-name>/SKILL.md` expect. This directory flattens them so
those harnesses, Devin Cloud among them, discover the skills straight from the
repository.

Do not edit anything here. Change the skill under `skills/` and re-run the sync
script.
EOF

echo "wrote $DEST/README.md"
