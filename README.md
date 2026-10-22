<div align="center">

# open-sesame 🔓

**AI penetration-testing skills for [Claude](https://claude.com/claude-code) — web apps *and* networks.**

*Say the magic words, and the target opens up — the authorized way.*

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Claude Skills](https://img.shields.io/badge/Claude-Skills-8A5CF6.svg)](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview)
[![Methodology: OWASP WSTG + PTES](https://img.shields.io/badge/methodology-OWASP%20WSTG%20%2B%20PTES-005FAD.svg)](https://owasp.org/www-project-web-security-testing-guide/)

</div>

---

`open-sesame` is a **suite of skills** that turns Claude into a disciplined penetration
tester. Point it at a target you're authorized to assess and it runs the whole
engagement — maps the attack surface, works methodically through an industry
methodology, validates findings with the lightest safe proof, and writes clean reports
for both engineers and leadership.

| Skill | For | Methodology |
|-------|-----|-------------|
| **[`web-pentest`](.claude/skills/web-pentest/)** | A single web application / API | OWASP WSTG |
| **[`net-pentest`](.claude/skills/net-pentest/)** | Networks & infrastructure, incl. Active Directory | PTES / NIST SP 800-115 |

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

- **Authorization-first** — both skills confirm scope and rules of engagement before any
  active test, and treat third-party platform/cloud infrastructure as out of scope.
- **Web (`web-pentest`)** — full OWASP WSTG coverage: recon, configuration, auth, session,
  access control (incl. multi-tenant isolation), injection, crypto, business logic,
  client-side, and API tests; safe RCE validation and reverse shells.
- **Network (`net-pentest`)** — PTES-based external *and* internal testing: host discovery,
  port/service scanning, enumeration, vuln ID, exploitation, privilege escalation (Linux +
  Windows), pivoting, and **Active Directory** attacks (Kerberoasting, BloodHound, NTLM
  relay, the path to Domain Admin) — plus **hybrid/cloud identity** (Entra ID, AWS),
  **Wi-Fi**, and **container/Kubernetes** testing.
- **Tooling playbooks** — concrete, safe-usage workflows for Burp, ffuf, nuclei, sqlmap,
  nmap, masscan, netexec, impacket, responder, BloodHound, and more.
- **Three reports, two audiences** — a technical findings report, a plain-language
  stakeholder summary, and a how-to-recreate guide, each rendered to **PDF**.

## 🚀 Quick start

### 1. Install the skill

Clone into a location Claude discovers skills from:

```bash
# Per project (available inside one repo) — installs both skills
git clone https://github.com/hassan-algo/open-sesame.git
cp -r open-sesame/.claude/skills/* .claude/skills/

# Or personal (available in every project)
cp -r open-sesame/.claude/skills/* ~/.claude/skills/
```

### 2. Use it

In Claude Code, just describe the work — the right skill triggers automatically:

```
Pentest my web app at https://staging.myapp.example — I own it. Start with recon.
Scan my network 10.0.0.0/24 and enumerate Active Directory — it's my lab.
```

`web-pentest` triggers on things like *"find vulns in my web app"*, *"test for IDOR/SQLi"*,
*"validate this RCE"*; `net-pentest` on *"scan this subnet"*, *"enumerate these hosts"*,
*"Kerberoasting / BloodHound"*, *"privilege escalation on this box"*. Or invoke explicitly
with `/web-pentest` or `/net-pentest`.

### 3. Get PDF reports

After a report is drafted in Markdown, render it to a styled PDF:

```bash
# each skill ships the same renderer
.claude/skills/web-pentest/scripts/render-report.sh report.md report.pdf
```

The script converts Markdown → HTML (`pandoc`, else `npx marked`) → PDF (headless
Chrome/Chromium, else `weasyprint`, else macOS `cupsfilter`). Install at least one tool
from each stage.

## 🗂️ How it's organized

```
.claude/skills/
├── web-pentest/                 # single web application (OWASP WSTG)
│   ├── SKILL.md                 #   authorization, workflow, pointers
│   ├── references/              #   methodology, tooling, post-exploitation,
│   │                            #   reporting, lab-targets
│   ├── assets/report-template.md
│   ├── scripts/render-report.sh
│   └── evals/                   #   test cases + benchmarks
└── net-pentest/                 # networks & Active Directory (PTES / NIST)
    ├── SKILL.md
    ├── references/              #   methodology, active-directory, privesc,
    │                            #   pivoting, password-attacks, cloud-identity,
    │                            #   wireless, containers, tooling, reporting,
    │                            #   lab-targets
    ├── assets/report-template.md
    ├── scripts/render-report.sh
    └── evals/evals.json         #   trigger/behavior test cases
```

Supporting folders at the repo root:

- **`ad-lab/`** — the Docker Compose Samba AD lab (one domain controller, one attacker
  box) used for the `net-pentest` benchmark.
- **`index.html`** — the project landing page.
- **`reports/`** — generated engagement reports. Keep them local: `reports/` is not yet in
  `.gitignore`, so add it before committing.

Each skill uses **progressive disclosure**: `SKILL.md` is always loaded; the `references/`
files are pulled in only when a phase needs them, keeping the context lean and the
workflow fast.

## 🧪 Validation

`web-pentest` was built and tuned with Anthropic's `skill-creator` and validated across
two eval iterations — methodology, reporting, authorization-gating, RCE/reverse-shell
guidance, cross-tenant IDOR, and scope discipline. Summary results live in
[`.claude/skills/web-pentest/evals/benchmarks/`](.claude/skills/web-pentest/evals/benchmarks/).

Beyond the evals, see **[`BENCHMARKS.md`](BENCHMARKS.md)** for timed, end-to-end
engagements, and **[`CASE-STUDY.md`](CASE-STUDY.md)** for the story behind each one:

| Target | Skill | Objective | Active | Total (incl. PDFs) |
|--------|-------|-----------|--------|--------------------|
| Metasploitable2 (Docker) | `web-pentest` + `net-pentest` | Root | ≈ 3 min | ≈ 6 min |
| Samba AD lab (`ad-lab/`) | `net-pentest` | Domain Admin | ≈ 14 min | ≈ 17 min |
| OWASP Juice Shop (Docker) | `web-pentest` | Admin + customer data | ≈ 2.5 min | ≈ 5 min |

Dead ends and lab-injected findings are documented, not hidden.

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
  & [Top 10](https://owasp.org/www-project-top-ten/), the [PTES](http://www.pentest-standard.org/),
  [NIST SP 800-115](https://csrc.nist.gov/pubs/sp/800/115/final), and [MITRE ATT&CK](https://attack.mitre.org/).
- Built as [Claude Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview).

---

<div align="center">
<sub>Built for defenders and authorized testers. Hack responsibly. 🔓</sub>
</div>
