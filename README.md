# Studytube mirror of mattpocock/skills

This repository makes [Matt Pocock's agent skills](https://github.com/mattpocock/skills) discoverable by Devin (and any other harness that scans `.agents/skills/`) across Studytube.

**This is not a maintained fork.** It started as one, but upstream is now treated purely as a data source: we never merge or rebase upstream history into this repo. Instead, a manual GitHub Actions workflow clones upstream, flattens its skills into `.agents/skills/`, and commits the result. Git histories can diverge freely and syncing can never conflict.

## Why this repo exists

Devin discovers skills by indexing the committed contents of connected repositories, and it only scans the flat pattern `.agents/skills/<skill-name>/SKILL.md` (see the [Devin skills docs](https://docs.devin.ai/product-guides/skills)). Upstream nests its skills in bucket folders (`skills/engineering/...`, `skills/productivity/...`), one level too deep, and symlinks do not survive indexing. So this repo carries a real, committed, flattened mirror.

Devin has no org-level skills feature yet; a dedicated connected repo like this one is the workaround its docs recommend. If Cognition ships first-class org-level skills, this repo can be retired.

## How to sync from upstream

Run the **Sync skills from upstream** workflow. It is manual only (no schedule).

From the GitHub UI: **Actions → Sync skills from upstream → Run workflow**. Leave the `ref` input empty to sync the tip of upstream `main`, or pass an upstream tag (for example `v1.2.3`) to pin a release.

From the CLI:

```bash
gh workflow run sync-skills.yml -R Studytube/mattpocock_skills
```

```bash
gh workflow run sync-skills.yml -R Studytube/mattpocock_skills -f ref=v1.2.3
```

The workflow clones `mattpocock/skills` at the requested ref, regenerates `.agents/skills/` from it, and pushes a commit only when the mirror actually changed. The commit message records the ref and the upstream SHA it resolved to. Devin picks the change up when it re-indexes the repo.

## Repository layout

- `.agents/skills/` is the product of this repo: the flattened, generated mirror that Devin reads. **Never edit it by hand**; the next sync would overwrite any manual change. It is regenerated wholesale from upstream on every sync.
- [`.agents/UPSTREAM_VERSION`](.agents/UPSTREAM_VERSION) records which upstream version the mirror was last generated from (the requested ref, the tag pointing at it if any, and the commit SHA). The workflow rewrites it on every sync; the same version also lands in the sync commit message and the run's step summary.
- [`scripts/sync-agents-skills.sh`](scripts/sync-agents-skills.sh) produces the mirror from a clone of upstream, which the workflow passes to it. It is the only script in the repo.
- [`.github/workflows/sync-skills.yml`](.github/workflows/sync-skills.yml) is the manual sync described above, and the repo's only workflow.

That is the whole repo, on purpose: upstream's own files (`skills/`, `docs/`, package tooling, release automation) are not carried here, because this repo consumes upstream as a data source rather than tracking its git history.

## Making changes to skills

Do not customize skills here: the mirror is regenerated from upstream on every sync, so local edits to `.agents/skills/` are lost. Propose improvements upstream at [mattpocock/skills](https://github.com/mattpocock/skills). If Studytube ever needs skills of its own, put them in a separate repo (or a separate, non-mirrored directory wired into the sync script) rather than editing the mirrored files.

## Attribution

All skill content is authored by [Matt Pocock](https://github.com/mattpocock) and mirrored under the terms of the upstream [LICENSE](LICENSE). See the [upstream README](https://github.com/mattpocock/skills#readme) for what the skills do and how to use them in your own editor or agent.
