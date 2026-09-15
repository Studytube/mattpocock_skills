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
