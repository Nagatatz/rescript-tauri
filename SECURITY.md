# Security Policy

## Supported Versions

Phase 1 + Phase 2 implementations are merged on `main`; the first published `@rescript-tauri/*` release (`v0.1.0` track) is pending. Until that release lands, "supported version" means the `main` branch HEAD. Reports against the merged code, the design documents, or RFC content are all welcome through the channel below.

## Reporting a Vulnerability

**Please do not open a public GitHub Issue for security reports.**

The primary channel is **GitHub Security Advisories (GHSA)**:

- Open the repository's **Security** tab → **Report a vulnerability**
- Direct URL (once private vulnerability reporting is enabled by the repository owner): <https://github.com/Nagatatz/rescript-tauri/security/advisories/new>

If GHSA is not yet enabled on the repository, or if you cannot use the GHSA workflow for any reason, fall back to email:

- **nagata.hbdc@gmail.com** with subject `[rescript-tauri SECURITY]`

## What to Include

The more of the following you can supply, the faster we can triage:

- Affected component, file path, or line number if known
- Reproduction steps (a minimal proof-of-concept is ideal)
- Impact assessment (what can an attacker do?)
- Suggested mitigation, if any
- Your preferred contact method and credit name (or request for anonymity)

## Response Timeline

Best-effort timelines apply until the first npm publish; a guaranteed timeline applies starting with the first published release.

| Stage | Target |
|---|---|
| Acknowledgement of report | within 7 days |
| Initial assessment / severity estimate | within 14 days |
| Fix, mitigation, or status update | within 30 days |

## Disclosure Policy

- **Coordinated disclosure** is preferred. We will work with the reporter to agree on a disclosure date.
- Reporters are credited in the resulting security advisory unless anonymity is requested.
- A CVE will be requested via GHSA when applicable.
- Once the fix is released, the GHSA will be made public.

## Out of Scope

The following are not handled here; please report them to the appropriate upstream project:

- Vulnerabilities in **upstream dependencies** — `@tauri-apps/api`, `rescript`, `@rescript/core`, or any `@tauri-apps/plugin-*` package. Report to the corresponding upstream repository.
- Issues solely in **example code under `examples/`** (once that directory exists), unless the underlying flaw is in `@rescript-tauri/core` and the example just demonstrates it.
- Generic Tauri or ReScript ecosystem questions that are not specific to this binding library.
