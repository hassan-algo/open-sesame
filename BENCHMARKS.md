# Benchmarks — real engagements, honestly timed

These are end-to-end runs of the `open-sesame` skills against targets we control,
timed from the first command to a confirmed objective. They're here as evidence the
skills actually drive a full engagement — not just answer questions about one — and
as an honest record of where tooling hit its limits.

> All timings are from real command/log/file timestamps, not estimates. Dead ends and
> tooling failures are kept in, because a benchmark that hides them isn't a benchmark.

---

## 1. `net-pentest` — internal Active Directory, no creds → Domain Admin

**Target:** a throwaway Samba AD lab (`lab.local`), built for the exercise
([`ad-lab/`](ad-lab/)) — one domain controller, one attacker box, isolated Docker
network.
**Start state:** assumed-breach — on the network, **zero credentials**, no map, no hints.
**Objective:** reach full Domain Admin control and produce the deliverables.
**Result:** ✅ **objective reached — full Domain Admin.**

### Headline numbers

| Metric | Value |
|---|---|
| **Cold start → confirmed Domain Admin** | **≈ 14 minutes** |
| Of which, dead ends (Samba/impacket interop) | ≈ 7 minutes |
| Draft + render all 3 report PDFs | ≈ 1.5 minutes |
| **First command → delivered deliverables** | **≈ 17 minutes** |

### Timeline (UTC, from actual timestamps)

| Phase | Time | Duration |
|---|---|---|
| Started recon (first `docker ps` check) | 17:26:08 | — |
| Fixed a broken DC container, rebuilt | 17:26 – 17:29 | ~3 min |
| Ground-truth check → no DA path found → asked the owner a clarifying question | ~17:29 – 17:31 | ~2 min *(owner response time, not attack time)* |
| Added a realistic privesc misconfig (owner-approved), rebuilt; enumeration, AS-REP roast + Kerberoast + DCSync attempts (interop dead ends), password spray (success) | 17:31 – 17:38 | ~7 min |
| Pivoted the misconfig, final rebuild, abused it, reset Administrator's password, confirmed DA, cleaned up | 17:38:25 – ~17:40 | ~2 min |
| **Live attack chain, cold start → confirmed Domain Admin** | **17:26:08 → ~17:40** | **≈ 14 min** |
| Wrote + rendered all 3 report PDFs | 17:41:55 → 17:43:21 | ≈ 1.5 min |
| **First command → delivered PDFs** | **17:26:08 → 17:43:21** | **≈ 17 min** |

### The chain it walked

1. **Anonymous enumeration** — null-session SMB/SAMR (`smbclient -N`, `rpcclient enumdomusers`) returned the full user list with no credentials.
2. **Password spray** — a lockout-safe `Season+Year+!` list (25 candidates × 5 accounts) recovered `svc_mssql` and `jdoe` on the first pass.
3. **Privilege escalation** — `svc_mssql` held an over-broad `User-Force-Change-Password` ACL over the built-in `Administrator` account; it reset Administrator's password without knowing the old one.
4. **Domain Admin** — authenticated as `Administrator`, created and independently verified a new domain account, then deleted the proof-of-concept account as cleanup.

### What it got *right* beyond just winning

- **Documented every dead end instead of hiding it.** AS-REP Roasting, Kerberoasting ticket extraction, and live DCSync all failed against Samba's KDC/DRSUAPI (impacket interop gaps, not hardening). The report records each failure, explains the cause, and says "re-validate against a real Windows DC" — rather than faking a hash dump.
- **Flagged lab-injected findings.** The two critical privesc findings (DCSync + force-change-password) didn't exist in the base lab; they were added mid-engagement **with the owner's explicit approval** so a complete chain could be shown. The reports call this out prominently in the executive summary, every affected finding, and the stakeholder note — so nobody mistakes a planted scenario for a discovered one.
- **Stayed in scope and cleaned up.** Docker host out of scope, PoC account removed, and the report flags that Administrator's password was left changed (reset / re-provision before reuse).

### Deliverables produced

Three files, all rendered to PDF via `scripts/render-report.sh` (kept locally and
not committed, so target data never lands in the repo):

- **Technical report** — 6 findings (2 Critical, 1 High, 2 Medium, 1 Info), each with CVSS 3.1 vectors, reproduction, impact, and remediation.
- **Stakeholder summary** — one-page, jargon-free, business-impact framing.
- **How-to-recreate guide** — per-finding reproduction with ✅ safe vs ⚠️ destructive steps marked, plus a re-test checklist.

**Caveat on the target.** This is a 2-host Samba lab, not a Windows enterprise forest:
no lateral movement across multiple hosts, no LSASS theft, and the three Windows-standard
techniques above couldn't be validated live here. The benchmark demonstrates the skill's
*methodology, judgment, and reporting* end-to-end — not Windows-specific exploit reliability.

---

## 2. `web-pentest` + `net-pentest` — Metasploitable2 (Docker), unauthenticated → root

**Target:** the deliberately vulnerable Metasploitable2 image, run locally in Docker on
`localhost`. Nothing outside the lab was touched.
**Start state:** on the network, **zero credentials**, no prior map.
**Objective:** demonstrate the highest level of access reachable and produce the deliverables.
**Result:** ✅ **objective reached — root on the target**, plus a second, independent
unauthenticated write path on the web server.

### Headline numbers

| Metric | Value |
|---|---|
| **First scan → last recon command** | **≈ 3 minutes** |
| Reporting (3 reports + render PDFs) | ≈ 3 minutes |
| **First scan → last PDF rendered** | **≈ 6 minutes** |
| Container start-up (before the first scan, not counted) | ≈ 2 minutes |

These timings come from captured tool timestamps (nmap's banner, HTTP `Date` headers,
report file mtimes), not a stopwatch. Expect roughly **±30–60 seconds** of accuracy.

### Timeline (PKT, UTC+5)

| Phase | Start | End | Duration |
|---|---|---|---|
| Active testing (scan → enum → exploit → cleanup) | ~21:58 (first nmap scan) | ~22:01 (last recon command) | ~3 min |
| Reporting (write 3 reports + render PDFs) | ~22:01 | 22:03:54 (last PDF rendered) | ~3 min |
| **Total** | **21:58** | **22:03:54** | **~6 min** |

### Caveats on this number

- **Start-up is excluded.** The container had been up for about 2 minutes when first checked,
  so it was started just before the run. That time isn't in the table.
- **The attack phase is unusually fast by design.** Metasploitable2 publishes its own
  access path on its landing page. A real engagement's scanning and enumeration phase alone
  would normally take far longer. Treat the 3-minute figure as a lab floor, not a forecast
  for production work.

---

*See the [case study](CASE-STUDY.md) for the narrative behind this run.*

---

## 3. `web-pentest` — OWASP Juice Shop (local Docker), unauthenticated → admin and customer data

**Target:** OWASP Juice Shop, the intentionally vulnerable web application, run in its own
separate Docker container and reached at `http://localhost:3000`. Nothing outside the lab was touched.
**Start state:** no username, no password, no prior map.
**Objective:** reach the highest access reachable from the outside and produce the deliverables.
**Result:** ✅ **objective reached — administrator access and customer data exposure confirmed**,
with 7 findings across the technical, stakeholder, and how-to-recreate reports.

### Headline numbers

| Metric | Value |
|---|---|
| **Active testing (recon → validation)** | **≈ 2.5 min** |
| **Total, including reports and PDFs** | **≈ 5 min** |

These are the figures measured for this run. They were not taken from per-command
timestamps, so treat them as approximate to within about ±30 seconds.

### Scope of the run

- Recon of the login, search, and file-serving features.
- Targeted validation of each suspected issue with the smallest proof that shows impact.
- Read-only throughout. No data was deleted or changed.
- Three reports were produced and rendered to PDF.

### Caveats

- **Juice Shop is built to be broken.** Its vulnerabilities are catalogued and well known, so
  the run is fast by design. It is not a measure of how long a live, unfamiliar application
  would take.
- **Timings are approximate.** The run was timed by hand, not from logged command timestamps,
  so the figures are less precise than the Metasploitable2 run above.
