# Default Renovate Config for Jolt Design

This is the default [Renovate](https://www.mend.io/renovate/) config for [Jolt Design](https://www.joltdesign.co.uk/) repos. They mostly make Renovate's commits and issues look more like Dependabot's.

Use the following to get the whole thing:

```json
{
  "extends": ["github>Jolt-Design/Renovate-Config"]
}
```

or you can enable individual features with the sub files, e.g.L

```json
{
  "extends": [
    "github>Jolt-Design/Renovate-Config:labels",
    "github>Jolt-Design/Renovate-Config:separate-branches",
    "github>Jolt-Design/Renovate-Config:weekly-lockfiles"
  ]
}
```

## Files

An overview of the purpose of the config files.

### [commit-messages](commit-messages.json)

Add extra info to commit messages, such as the directory being updated and the version being updated from.

### [default](default.json)

This is the default config, pulled in if you extend the whole repo rather than an individual file.

### [ignore-paths](ignore-paths.json)

Default ignore paths. This possibly doesn't actually work!

### [labels](labels.json)

Add category labels to PRs a la Dependabot, as well as labelling vulnerability fix PRs.

### [local](local.json)

Localise Renovate for Jolt, e.g. time zones, etc.

### [package-rules](package-rules.json)

Additional rules for individual package groups

### [separate-branches](separate-branches.json)

Makes separate PRs for each package file, so e.g. a Biome update in `src/` makes a separate PR to one in `functions/` rather than being grouped together.

### [weekly-lockfiles](weekly-lockfiles.json)

Enables weekly lockfile maintenance commits.
