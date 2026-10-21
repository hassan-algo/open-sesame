# Contributing to open-sesame

Thanks for helping improve this skill! It gets sharper the more real-world testing
experience goes into it.

## Ground rule

Everything here is for **authorized, non-destructive, methodical** web-app testing.
Contributions that add offensive capability without that framing — or that help target
systems without permission — will not be merged. When in doubt, lead with authorization
and the lightest-possible-proof principle.

## Ways to contribute

- **Methodology** — add or refine OWASP WSTG test cases in
  `.claude/skills/web-pentest/references/methodology.md`.
- **Tooling** — contribute real command workflows and safe-usage notes in
  `references/tooling.md`.
- **Reporting** — improve the templates, CVSS/severity guidance, or add a backend to
  `scripts/render-report.sh`.
- **Evals** — add prompts to `.claude/skills/web-pentest/evals/evals.json` that catch
  gaps, edge cases, or regressions.
- **Docs** — clarify anything confusing.

## How to propose a change

1. Fork the repo and create a branch (`git checkout -b improve-xyz`).
2. Make your change. Keep `SKILL.md` lean (under ~500 lines); put depth in `references/`.
3. If you touched behavior, add or update an eval case so it's covered.
4. Open a pull request describing **what** changed and **why**, and note any testing
   you did.

## Style

- Prefer clear, imperative instructions and explain the *why* behind a test — the skill
  is read by a capable model and by humans.
- Keep examples generic (use `example.com`, lab targets, or placeholders). **Never commit
  real target data, client names, findings, or credentials.**

## Reporting issues

Open a GitHub issue for bugs, gaps in coverage, or ideas. For anything that could be a
security concern in the skill itself, note it clearly in the issue.
