# open-sesame 🔓 — an AI web-pentest skill for Claude

*Say the magic words, and the web app opens up — the authorized way.*


A [Claude](https://claude.com/claude-code) skill that guides a disciplined,
methodology-driven web-application security test — from reconnaissance through
exploitation to a clean, dual-audience report. It's built around the
[OWASP Web Security Testing Guide (WSTG)](https://owasp.org/www-project-web-security-testing-guide/)
so coverage stays systematic instead of ad-hoc.

> ⚠️ **Authorized testing only.** This skill is for assessing systems you own or
> are explicitly permitted to test (your own apps, a signed client engagement, an
> in-scope bug-bounty target, or a CTF/practice lab). It refuses to help attack
> third-party systems without authorization, and treats the platform/host a target
> runs on as out of scope by default. Use it responsibly and legally.

## What it does

- **Authorization-first workflow** — confirms scope before any active testing.
- **Full OWASP WSTG checklist** — recon, configuration, auth, session, access
  control (incl. multi-tenant isolation), injection, errors/crypto, business
  logic, client-side, and API-specific tests.
- **Tooling playbook** — how to drive Burp, ffuf, nuclei, sqlmap, nmap,
  subfinder/httpx, etc., chained into a repeatable flow.
- **Authenticated & multi-tenant testing** — what to get from the client and how
  to prove cross-user / cross-tenant access.
- **Safe RCE validation & post-exploitation** — prove code execution with the
  lightest signal first; reverse/bind shells and cleanup rules when impact must
  be shown.
- **Reports for two audiences** — a technical report *and* a plain-language
  stakeholder summary, both rendered to **PDF**.

## Install

Drop the skill where Claude Code looks for skills:

- **Per project:** `.claude/skills/web-pentest/` (as in this repo).
- **Personal (all projects):** `~/.claude/skills/web-pentest/`.

Claude discovers it automatically. Invoke it by asking for a web pentest (or
`/web-pentest`); it also triggers on phrases like *"find vulns in my web app"*,
*"test this endpoint for IDOR/SQLi"*, *"map the attack surface"*, *"write up this
finding"*, or *"validate this RCE"*.

## Structure

```
.claude/skills/web-pentest/
├── SKILL.md                     # entry point: authorization, workflow, pointers
├── references/
│   ├── methodology.md           # the OWASP WSTG test checklist (core)
│   ├── tooling.md               # tool commands & safe-usage workflows
│   ├── post-exploitation.md     # RCE validation, reverse shells, cleanup
│   ├── reporting.md             # severity (CVSS), evidence, dual-audience + PDF
│   └── lab-targets.md           # legal practice targets & a learning path
├── assets/
│   └── report-template.md       # fill-in findings report
├── scripts/
│   └── render-report.sh         # Markdown report → styled PDF
└── evals/
    ├── evals.json               # trigger/behavior test cases
    └── benchmarks/              # validation results (see below)
```

## Reports → PDF

After writing a report in Markdown, render it to a styled PDF:

```bash
.claude/skills/web-pentest/scripts/render-report.sh report.md report.pdf
```

The script converts Markdown → HTML (via `pandoc`, else `npx marked`) → PDF (via
headless Chrome/Chromium, else `weasyprint`, else macOS `cupsfilter`). At least one
tool from each stage must be installed.

## Validation

The skill was built and tuned with Anthropic's `skill-creator` and validated over
two eval iterations (methodology, reporting, authorization-gating, RCE/reverse-shell
guidance, cross-tenant IDOR, and scope discipline). Summary results are in
[`evals/benchmarks/`](.claude/skills/web-pentest/evals/benchmarks/).

## License

Add your preferred license here.
