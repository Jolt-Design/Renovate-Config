# Jolt Renovate Config

Shared [Renovate](https://docs.renovatebot.com/) presets for Jolt Design repos. Each root-level `*.json` (other than `biome.json` and `renovate.json`) is a preset that other repos extend as `github>Jolt-Design/Renovate-Config` (`default.json`) or `github>Jolt-Design/Renovate-Config:<file name without .json>`. This repo's own `renovate.json` extends its `default` preset.

## master is live

Renovate fetches these presets from the default branch (`master`) of the GitHub repo. A push to `master` changes Renovate's behaviour in every Jolt repo that extends them, on their next Renovate run. There is no CI and no release step in between.

- Never push to `master` without the user's approval for that push. The guard hook asks every time.
- Run the checks below before every commit.

## Commands

- Setup: `mise install && mise run setup` (tools pinned in `.mise.toml`; the `setup` task installs the pre-commit hook).
- Format and lint check: `mise exec -- biome check .` (fix: add `--write`). Config: `biome.json`.
- Validate presets: `npx --yes --package renovate -- renovate-config-validator --strict --no-global <files>`, passing every preset file. `--no-global` is required: without it, a file named on the command line is validated as global self-hosted config, not as a preset.

## Conventions

- When adding a preset, also add it to `default.json` or `generic.json` if it should be on by default, and give it an entry in the Files list in `README.md`.
- `generic.json` is for presets any repo could use; Jolt-specific or opinionated ones go in `default.json`.
- Commit directly to `master` with a short imperative subject. The pre-commit hook (`.pre-commit-config.yaml`) runs Biome on staged files.

## Integrations

- GitHub only. Use the `gh` CLI.
