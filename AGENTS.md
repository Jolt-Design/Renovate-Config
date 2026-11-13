# Jolt Renovate Config

Shared [Renovate](https://docs.renovatebot.com/) presets for Jolt Design repos. Each root-level `*.json` (other than `biome.json`, `package.json` and `renovate.json`) is a preset that other repos extend as `github>Jolt-Design/Renovate-Config` (`default.json`) or `github>Jolt-Design/Renovate-Config:<file name without .json>`. This repo's own `renovate.json` extends its `default` preset.

## master is live

Renovate fetches these presets from the default branch (`master`) of the GitHub repo. A push to `master` changes Renovate's behaviour in every Jolt repo that extends them, on their next Renovate run. There is no release step in between: CI (`.github/workflows/check.yml`) runs after the push, so it reports a broken preset but doesn't stop it going live.

- Never push to `master` without the user's approval for that push. The guard hook asks every time.
- Run the checks below before every commit.

## Commands

- Setup: `mise install && mise run setup` (see the `setup` task in `.mise.toml`).
- Format and lint check: `yarn lint` (fix: `yarn lint --write`). Config: `biome.json`.
- Validate presets: `yarn validate`. When running `renovate-config-validator` on individual files, pass `--no-global`: without it, a file named on the command line is validated as global self-hosted config, not as a preset.

## Conventions

- When adding a preset, also add it to `default.json` or `generic.json` if it should be on by default, and give it an entry in the Files list in `README.md`.
- `generic.json` is for presets any repo could use; Jolt-specific or opinionated ones go in `default.json`.
- Commit directly to `master` with a short imperative subject. The pre-commit hook (`.pre-commit-config.yaml`) runs both checks on staged files.

## Integrations

- GitHub only. Use the `gh` CLI.
