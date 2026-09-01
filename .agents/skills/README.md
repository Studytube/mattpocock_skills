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
