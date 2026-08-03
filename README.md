# Homebrew Actions

This is a prototype Homebrew tap for installing GitHub Actions as packages. It accompanies [brew install actions/checkout](https://nesbitt.io/2026/08/04/brew-install-actions-checkout.html), an experiment in putting a reviewed index between an action release and the runner that executes it.

Each formula pins a source archive to a commit and SHA-256 hash. Composite action references become Homebrew dependencies and local paths at install time, which makes their dependency graph visible to `brew deps --tree`.

The first four formulae cover a Node action, a composite action with a dependency, and a Docker action:

- `actions-checkout`
- `actions-cache`
- `pre-commit-action`
- `actions-first-interaction`

Add an Actionfile to the repository using the actions:

```ruby
tap "andrew/actions"
brew "andrew/actions/pre-commit-action"
```

Run the setup action after checkout, then reference the installed action through the workspace:

```yaml
steps:
  - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1
  - uses: andrew/homebrew-actions@<commit-sha>
  - uses: ./.brew-actions/pre-commit-action
```

The setup action runs `brew bundle` through Homebrew's bundled Ruby, copies requested actions and their action dependencies into `.brew-actions`, and preserves hidden files. `actions-checkout` remains a bootstrap exception because the workspace does not exist until checkout has run.

This repository is an experiment. The larger critical-actions sample found stale release metadata, mutable Docker image references, missing license data, and zizmor findings that need policy decisions before the full set should be bottled.

## Local checks

```sh
ruby -Itest test/setup_actions_test.rb
ruby -Itest test/formulae_test.rb
```

## License

The tap is available under the MIT License. Packaged actions retain their upstream licenses.
