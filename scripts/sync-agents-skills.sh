#!/usr/bin/env bash
set -euo pipefail

# Regenerates .agents/skills/ from a checkout of mattpocock/skills: the
# promoted buckets (skills/engineering and skills/productivity) are flattened
# into .agents/skills/<skill-name>/ so harnesses that only scan the fixed
# .agents/skills root, one level deep, discover them. Devin Cloud is one of
# those: it indexes SKILL.md files from a repo's committed contents, so the
# mirror has to be real files rather than symlinks.
#
# Usage: sync-agents-skills.sh <source-checkout>
# where <source-checkout> is a clone of https://github.com/mattpocock/skills
# at the version to mirror. This is what .github/workflows/sync-skills.yml
# runs; there is normally no reason to run it by hand.

if [ $# -lt 1 ]; then
  echo "usage: $0 <source-checkout>  (a clone of mattpocock/skills)" >&2
  exit 1
fi
SRC="$1"
if [ ! -d "$SRC/skills" ]; then
  echo "error: '$SRC' has no skills/ directory." >&2
  exit 1
fi

REPO="$(cd "$(dirname "$0")/.." && pwd)"
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

Generated mirror of the promoted skills in
[mattpocock/skills](https://github.com/mattpocock/skills), produced by
[`scripts/sync-agents-skills.sh`](../../scripts/sync-agents-skills.sh) via the
`Sync skills from upstream` workflow.

Upstream groups skills into bucket folders (`engineering/`, `productivity/`),
which puts every `SKILL.md` one level deeper than harnesses that scan
`.agents/skills/<skill-name>/SKILL.md` expect. This directory flattens them so
those harnesses, Devin Cloud among them, discover the skills straight from the
repository.

Do not edit anything here: the next sync overwrites it. Propose skill changes
upstream instead. `../UPSTREAM_VERSION` records the upstream version this
mirror was generated from.
EOF

echo "wrote $DEST/README.md"
