# Case study — timed lab engagements with `open-sesame`

This page tells the story behind the numbers in [`BENCHMARKS.md`](BENCHMARKS.md). It covers
three lab engagements run end to end with the skills in this repo, and what they show about
the skills, the tooling, and the report output.

Both targets were lab systems under our control. The detailed reports are generated
locally and kept out of git, because target data should never be committed.

---

## Case 1 — Metasploitable2: a known-weak box, from zero to root in minutes

**Context.** Metasploitable2 is an intentionally insecure Linux image. It is a standard
practice target for learning web and network testing. It was run locally in Docker and was
never exposed beyond the lab network.

**What the skills did.**

1. **Recon.** A port scan and service fingerprinting mapped the exposed network services and
   the web application on the host.
2. **Enumeration.** The web application was reviewed for exposed content and the services were
   checked for default configuration. The landing page itself published a working credential,
   which is the kind of disclosure that turns a reconnaissance step into a shortcut.
3. **Access and escalation.** The credential gave an authenticated shell. A sudo configuration
   that was far too permissive then allowed the account to reach root.
4. **Independent finding.** A separate check found that the web server accepted file uploads
   with no authentication. This path does not depend on the first one, so fixing the
   credential alone would not close it.
5. **Reporting.** Three documents were produced: a technical report, a one-page stakeholder
   summary, and a how-to-recreate guide. Each was rendered to PDF.

**What it shows.**

- **Speed is a property of the target, not the tool.** The run took about six minutes, but
  most of that speed came from the target handing over its own access path. The benchmark
  should not be read as a claim about real-world pace.
- **Dormant risk gets its own finding.** Several old, well-known services were not reachable
  from outside because of how the container's ports were configured. The report records them
  as an informational finding so that a future port change is not mistaken for a new problem.
- **Scope discipline held.** The engagement stopped once full access was proven. It did not
  go on to exploit the extra demo applications, because that would add no new information.

**Lessons.**

- Read the landing page before any scanning. Lab and real systems alike sometimes publish
  their own shortcuts.
- Check for a second path to the same objective. A single fix can leave the other path open.
- Report timings with their precision and their caveats. An unqualified "six minutes" invites
  the wrong comparison.

---

## Case 2 — Samba Active Directory lab: no credentials to Domain Admin

**Context.** A throwaway Samba AD domain (`lab.local`) was built in an isolated Docker network
for this exercise. The domain has one domain controller and one
attacker host. The attacker starts with a network position and nothing else.

**What the skills did.**

1. **Anonymous enumeration.** Null-session SMB and RPC queries returned the domain user list
   with no credentials.
2. **Password spraying.** A small, lockout-safe candidate list, tried once per account, found
   two valid accounts on the first pass.
3. **Privilege escalation through an ACL.** One service account held an over-broad right to
   reset the built-in Administrator's password. The reset needed no knowledge of the old one.
4. **Domain Admin.** Access as Administrator was confirmed by creating a proof-of-concept
   account and checking it independently. That account was then deleted.

**What went wrong, and why we kept it.**

- AS-REP Roasting, Kerberoasting, and DCSync all failed. The causes were interoperability gaps
  between Samba's KDC and DRSUAPI and the impacket tooling, not hardening. The report records
  each failure and says that the techniques need to be re-validated against a real Windows
  domain controller.
- About seven of the roughly fourteen minutes went to these dead ends. Leaving them out would
  make the run look cleaner and less useful to someone repeating it.

**What it shows.**

- **Honest reporting of planted findings.** Two critical findings were added to the lab
  mid-engagement, with the owner's approval, so that a complete chain could be shown. The
  reports label them as lab-injected in the executive summary, in each affected finding, and in
  the stakeholder note, so no reader mistakes a planted scenario for a discovered one.
- **Methodology over exploit reliability.** The lab has two hosts and no Windows enterprise
  features, so lateral movement and LSASS theft could not be tested. The benchmark shows that
  the skill can drive the whole method and produce usable output. It does not show that the
  Windows-specific techniques are reliable.
- **Cleanup is part of the job.** The proof-of-concept account was removed. The report notes
  that the Administrator password was left changed and must be reset before the lab is reused.

**Lessons.**

- Document dead ends with their causes. A future tester will hit the same interop gaps.
- Label every planted finding. A benchmark is only evidence if the reader can tell what was
  discovered from what was added.
- Say what the target cannot prove. A two-host lab cannot stand in for a forest.

---

## Case 3 — OWASP Juice Shop: a web app from anonymous to admin in two and a half minutes

**Context.** OWASP Juice Shop is an intentionally vulnerable web application. It is a common
practice target for web testing. It ran in its own separate Docker container and was reached
at `http://localhost:3000`.

**What the skills did.**

1. **Recon.** The login, product search, and file-serving features were mapped, along with
   the API endpoints behind them.
2. **Targeted validation.** Each suspected issue was checked with the smallest proof that
   shows impact. Nothing was run for its own sake, and nothing was changed on the target.
3. **Access and data exposure.** Without any account, the login path gave administrator
   access. A separate search weakness exposed the customer account records. A public folder
   also exposed files marked confidential.
4. **Lower-severity issues.** The run also recorded a DOM-based cross-site scripting issue,
   weak password hashing, verbose error messages, and missing security headers.
5. **Reporting.** Seven findings were written up across the three reports, then rendered to PDF.

**What it shows.**

- **Known targets are fast, and that's a limit on the number.** The active phase took about
  two and a half minutes and the full run about five. Those figures come from a deliberately
  broken app with a published catalogue of flaws, so they say little about an unfamiliar one.
- **Impact drives the rating.** The two critical findings each needed a single request, but
  the stakeholder summary explains their impact in plain terms: full admin control and
  exposure of every customer record. That framing is what leadership acts on.
- **Read-only testing still proves the point.** The run changed and deleted nothing and still
  demonstrated complete compromise. Each finding was proven with the smallest possible request.

**Lessons.**

- Fix the root cause, not the symptom. The two critical findings share a database query
  pattern, so one fix closes both break-in and data-theft paths.
- Note how the timings were taken. The Juice Shop figures were timed by hand, which makes
  them less precise than the Metasploitable2 log-based numbers.

---

## Takeaways across all three cases

| | Metasploitable2 | Samba AD lab | Juice Shop |
|---|---|---|---|
| Start state | Zero credentials | Zero credentials | No account |
| Objective | Root | Domain Admin | Admin and customer data |
| Time to objective | ~3 min active | ~14 min active | ~2.5 min active |
| Time to delivered PDFs | ~6 min total | ~17 min total | ~5 min total |
| Main limit | Target is pre-solved | Interop gaps; two-host lab | Target is pre-solved; hand-timed |

The skills were able to run a full engagement on both targets and produce deliverables that
do more than list tool output. The limits are real and are stated in each case. Those limits
matter more than the speed figures.
