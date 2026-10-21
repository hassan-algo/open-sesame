<div align="center">

# open-sesame 🔓

**An AI web-application penetration-testing skill for [Claude](https://claude.com/claude-code).**

*Say the magic words, and the web app opens up — the authorized way.*

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Claude Skill](https://img.shields.io/badge/Claude-Skill-8A5CF6.svg)](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)
[![Methodology: OWASP WSTG](https://img.shields.io/badge/methodology-OWASP%20WSTG-005FAD.svg)](https://owasp.org/www-project-web-security-testing-guide/)

</div>

---

`open-sesame` is a **skill** that turns Claude into a disciplined web-app penetration
tester. Give it a target you're authorized to assess and it runs the whole engagement —
maps the attack surface, works methodically through the [OWASP Web Security Testing
Guide](https://owasp.org/www-project-web-security-testing-guide/), validates findings
with the lightest safe proof, and writes clean reports for both engineers and
leadership.

It's built as a set of Markdown instructions and small helper scripts — no model
fine-tuning, no binaries. You can read every line of what it tells Claude to do.

> [!WARNING]
> **Authorized testing only.** This skill is for systems you **own** or have **explicit
> permission** to test (your own apps, a signed client engagement, an in-scope
> bug-bounty target, or a CTF / practice lab). It is designed to *refuse* unauthorized
> targets, treat the platform/host a target runs on as out of scope by default, and
> prefer non-destructive proofs. Using it against systems you don't have permission to
> test may be illegal. **You are responsible for staying within scope and the law.**

## ✨ What it does

- **Authorization-first** — confirms scope and rules of engagement before any active test.
- **Full OWASP WSTG coverage** — recon, configuration, authentication, session
  management, access control (incl. multi-tenant isolation), injection, error/crypto,
  business logic, client-side, and API-specific tests.
- **Tooling playbook** — how to drive Burp Suite, ffuf, nuclei, sqlmap, nmap,
  subfinder/httpx and friends, chained into a repeatable workflow.
- **Authenticated & multi-tenant testing** — what to request from the client and how to
  prove cross-user / cross-tenant access safely.
- **Safe RCE validation** — prove code execution with the lightest signal first;
  reverse/bind shells, TTY upgrade, and strict cleanup rules only when impact must be
  shown.
- **Reports for two audiences** — a technical findings report *and* a plain-language
  stakeholder summary, each rendered to **PDF**.

## 🚀 Quick start

### 1. Install the skill

Clone into a location Claude discovers skills from:

```bash
# Per project (available inside one repo)
git clone https://github.com/hassan-algo/open-sesame.git
cp -r open-sesame/.claude/skills/web-pentest .claude/skills/

# Or personal (available in every project)
cp -r open-sesame/.claude/skills/web-pentest ~/.claude/skills/
```

### 2. Use it

In Claude Code, just describe the work — the skill triggers automatically:

```
Pentest my web app at https://staging.myapp.example — I own it. Start with recon.
```

It also triggers on phrases like *"find vulns in my web app"*, *"test this endpoint for
IDOR/SQLi"*, *"map the attack surface"*, *"write up this finding"*, or *"validate this
RCE"* — or invoke it explicitly with `/web-pentest`.

### 3. Get PDF reports

After a report is drafted in Markdown, render it to a styled PDF:

```bash
.claude/skills/web-pentest/scripts/render-report.sh report.md report.pdf
```

The script converts Markdown → HTML (`pandoc`, else `npx marked`) → PDF (headless
Chrome/Chromium, else `weasyprint`, else macOS `cupsfilter`). Install at least one tool
from each stage.

## 🗂️ How it's organized

```
.claude/skills/web-pentest/
├── SKILL.md                     # entry point: authorization, workflow, pointers
├── references/
│   ├── methodology.md           # the OWASP WSTG test checklist (the core)
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
    └── benchmarks/              # validation results
```

Skills use **progressive disclosure**: `SKILL.md` is always loaded; the `references/`
files are pulled in only when a phase needs them, keeping the context lean and the
workflow fast.

## 🧪 Validation

The skill was built and tuned with Anthropic's `skill-creator` and validated across two
eval iterations — methodology, reporting, authorization-gating, RCE/reverse-shell
guidance, cross-tenant IDOR, and scope discipline. Summary results live in
[`.claude/skills/web-pentest/evals/benchmarks/`](.claude/skills/web-pentest/evals/benchmarks/).

## 🤝 Contributing

Contributions are very welcome — this gets better the more practitioners shape it. Good
first contributions:

- **Extend the methodology** — add or sharpen WSTG test cases in `references/methodology.md`.
- **Add tooling recipes** — real-world command workflows in `references/tooling.md`.
- **Improve reporting** — templates, severity guidance, or the `render-report.sh` backends.
- **Add eval cases** — new prompts in `evals/` that catch gaps or regressions.

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to propose changes. Please keep everything
aligned with the skill's core principle: **authorized, non-destructive, methodical
testing** — contributions that add offensive capability without that framing won't be
merged.

## 📜 License

[MIT](LICENSE) — free to use, modify, and share.

## 🙏 Acknowledgements

- Methodology based on the [OWASP Web Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
  and the [OWASP Top 10](https://owasp.org/www-project-top-ten/).
- Built as a [Claude Agent Skill](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview).

---

<div align="center">
<sub>Built for defenders and authorized testers. Hack responsibly. 🔓</sub>
</div>
