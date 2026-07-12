# Contributing

Bug reports, doc fixes and new examples are all fair game. Open an issue first
if the change is large or would create billable AWS resources in CI.

## Before you open a PR

- Use [Conventional Commits](https://www.conventionalcommits.org/) for commit
  messages (`fix:`, `feat:`, `docs:`, `ci:` ...). The existing history follows it.
- Run the same checks CI runs:
  - `terraform fmt -check -recursive`, `terraform validate`, `tflint` and
    `tfsec` for anything under `terraform/` (see
    [terraform-checks.yml](.github/workflows/terraform-checks.yml))
  - `scripts/validate-addons.sh` for add-on values changes (renders every
    chart and schema-checks the output; no cluster needed)
- Keep PRs small and focused. If you touch behaviour, update the relevant
  README in the same PR.
- New scripts or manifests should carry enough comments to explain the
  non-obvious choices, same as the existing ones.

Questions: open an issue or a discussion.
