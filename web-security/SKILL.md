---
name: web-security
description: >
  This skill should be loaded for any task involving web application security.
  Use it when building or reviewing HTTP/HTTPS endpoints, REST APIs, GraphQL
  APIs, WebSocket services, SPAs, or any server-side code that processes
  untrusted user input. Also load it for security audits, penetration testing
  guidance, secure code review, or vulnerability assessments. Triggers on:
  "security check", "vuln", "injection", "XSS", "CSRF", "auth", "session",
  "pentest", "OWASP", "CVE", "secure coding", "취약점", "웹 보안",
  "보안 점검", "시큐어코딩". When in doubt, load it.
version: 1.0.0
sources:
  - "OWASP Top 10:2025 (confirmed January 2026)"
  - "OWASP API Security Top 10:2023"
  - "OWASP WSTG v4.2"
  - "KISA 주요정보통신기반시설 취약점 분석·평가 상세가이드 (2021.03)"
  - "MOIS 홈페이지 SW(웹) 개발보안 가이드"
  - "CWE/SANS Top 25 Most Dangerous Software Weaknesses (2024)"
---

# Web Security Skill

Comprehensive web vulnerability coverage for 2026, consolidating OWASP
Top 10:2025, OWASP API Security Top 10:2023, KISA/MOIS Korean government
standards, and emerging threats (prototype pollution, cache poisoning,
HTTP smuggling, LLM prompt injection, and more).

## How to use this skill

1. Before writing any security-sensitive code, check the **Quick Decision Matrix** below.
2. During security analysis passes, run the checklist in `references/checklist.md`.
3. Any **Prohibited Pattern** found = **Critical halt** — stop and report immediately.
4. For deep exploit detail, remediation code, or test payloads, open `references/vuln-catalog.md` and read only the section you need.
5. Map every finding to severity, CWE ID, and OWASP reference in your report.
6. For automated scanning, run `scanner.py` (dynamic) and `web_quick_scan.sh`
   (TLS/headers/ports). Each check maps to the W-IDs in this file.

---

## Vulnerability Index — 57 items across 4 tiers

For full detail on any item → `references/vuln-catalog.md`

### Tier 1 · OWASP Top 10:2025 (10 items)

| ID | Name | 2025 Rank | Key CWEs | Severity |
|----|------|-----------|----------|----------|
| W-001 | Broken Access Control (incl. SSRF, IDOR) | A01 | 200,284,352,918 | **Critical** |
| W-002 | Security Misconfiguration | A02 | 16,611,732 | High |
| W-003 | Software Supply Chain Failures | A03 | 494,829,1357 | High |
| W-004 | Cryptographic Failures | A04 | 261,326,327,328 | **Critical** |
| W-005 | Injection (SQL/XSS/Cmd/LDAP/XPath/SSTI/SSI) | A05 | 74,79,89,78 | **Critical** |
| W-006 | Insecure Design | A06 | 657,840 | High |
| W-007 | Authentication Failures | A07 | 287,306,798,307 | **Critical** |
| W-008 | Software or Data Integrity Failures | A08 | 345,353,502 | High |
| W-009 | Security Logging & Alerting Failures | A09 | 117,223,778 | Medium |
| W-010 | Mishandling of Exceptional Conditions (NEW 2025) | A10 | 209,476,636,755 | Medium |

**Key 2025 changes vs 2021:** Security Misconfiguration jumped from #5→#2. Supply Chain Failures is new (expands Vulnerable Components). SSRF merged into A01. Mishandling of Exceptional Conditions is new at A10.

### Tier 2 · OWASP API Security Top 10:2023 (10 items)

| ID | Name | API Rank | CWEs | Severity |
|----|------|----------|------|----------|
| W-011 | Broken Object Level Authorization (BOLA/IDOR) | API1 | 284 | **Critical** |
| W-012 | Broken Authentication (API) | API2 | 287 | **Critical** |
| W-013 | Broken Object Property Level Auth (Mass Assignment) | API3 | 213,915 | High |
| W-014 | Unrestricted Resource Consumption | API4 | 770,400 | High |
| W-015 | Broken Function Level Authorization | API5 | 285 | High |
| W-016 | Unrestricted Access to Sensitive Business Flows | API6 | 799 | High |
| W-017 | Server-Side Request Forgery (SSRF in APIs) | API7 | 918 | **Critical** |
| W-018 | Security Misconfiguration (API) | API8 | 16 | High |
| W-019 | Improper Inventory Management | API9 | 1059 | Medium |
| W-020 | Unsafe Consumption of Third-Party APIs | API10 | 346 | High |

### Tier 3 · KISA/MOIS Korean Government Standards (28 items)

| ID | Name | Severity |
|----|------|----------|
| W-021 | Buffer Overflow | High |
| W-022 | Format String Injection | High |
| W-023 | LDAP Injection | High |
| W-024 | OS Command Execution | **Critical** |
| W-025 | SQL Injection (KISA detail) | **Critical** |
| W-026 | SSI Injection | Medium |
| W-027 | XPath Injection | High |
| W-028 | Directory Indexing | Medium |
| W-029 | Information Disclosure / Error Leakage | High |
| W-030 | Malicious Content / Content Injection | Medium |
| W-031 | Cross-Site Scripting — XSS (KISA detail) | **Critical** |
| W-032 | Weak Password Policy | High |
| W-033 | Insufficient Authentication | **Critical** |
| W-034 | Weak Password Recovery | High |
| W-035 | CSRF — Cross-Site Request Forgery | High |
| W-036 | Session Prediction | High |
| W-037 | Insufficient Authorization (IDOR/BOLA) | **Critical** |
| W-038 | Insufficient Session Expiry | High |
| W-039 | Session Fixation | High |
| W-040 | Automated Attack / Brute Force | High |
| W-041 | Process Validation Missing (Business Logic) | High |
| W-042 | File Upload Vulnerability | **Critical** |
| W-043 | File Download / Path Traversal | High |
| W-044 | Admin Page Exposure | **Critical** |
| W-045 | Directory Traversal | High |
| W-046 | Server Banner / Location Disclosure | Medium |
| W-047 | Plaintext Data Transmission | **Critical** |
| W-048 | Insecure Cookie / Cookie Tampering | High |

### Tier 4 · Emerging & Modern Threats 2024–2026 (9 items)

| ID | Name | Context | Severity |
|----|------|---------|----------|
| W-049 | Prototype Pollution | Node.js / JS | High |
| W-050 | Web Cache Poisoning | CDN / Reverse Proxy | High |
| W-051 | HTTP Request Smuggling | Reverse Proxy / Load Balancer | **Critical** |
| W-052 | Race Condition / TOCTOU | Concurrent APIs | High |
| W-053 | GraphQL-Specific (Introspection exposure, depth/complexity DoS, batching abuse) | GraphQL | High |
| W-054 | WebSocket Security (hijacking, injection, missing auth) | WebSocket | High |
| W-055 | Insecure Deserialization (detail) | Java / Python / PHP | **Critical** |
| W-056 | Subdomain Takeover | DNS / Cloud hosting | High |
| W-057 | LLM / AI Prompt Injection in Web Context | AI-integrated apps | **Critical** |

---

## Prohibited Patterns — Critical Halt on Detection

Seeing any of these = stop everything, report as Critical STRIDE finding:

```
SQL / NoSQL
  - [AUTO] String concatenation into SQL: f"SELECT * FROM users WHERE id={user_input}"
  - [AUTO] ORM raw() with format args: Model.objects.raw(f"... {val}")

Command / Code Execution
  - subprocess(shell=True, args=user_input)
  - os.system(user_input), eval(user_input), exec(user_input)
  - Function(user_input) in JavaScript

Session / Auth
  - Session token in LocalStorage or SessionStorage
  - Session cookie without HttpOnly flag
  - JWT with algorithm "none"
  - JWT HS256 shared secret used across service boundaries

File Handling
  - File upload stored inside web root with execute permissions retained
  - Download path built from user input without normalization + allowlist

Transport
  - HTTP endpoint that accepts plaintext where HTTPS is expected
  - No HSTS header on HTTPS endpoints

Access Control
  - Admin endpoint reachable from public internet without IP restriction
  - CORS: Access-Control-Allow-Origin: * with Access-Control-Allow-Credentials: true
  - OAuth redirect_uri validated by prefix match (startsWith) not exact match

Cryptography
  - Passwords hashed with MD5, SHA-1, or unsalted SHA-256/SHA-512
  - AES-ECB mode for any encryption
  - Hard-coded secrets / API keys / passwords in source code

Error Handling
  - Stack traces, internal file paths, or version strings in production responses
  - XML parser with external entity processing enabled (XXE)

Deserialization
  - Java ObjectInputStream / Python pickle.loads from untrusted source
  - YAML.load() (PyYAML) instead of YAML.safe_load()
```

---

## Quick Decision Matrix

Before writing any security-sensitive code, check applicable rows:

| Feature | Required checks (IDs) | Auto-covered |
|---------|-----------------------|--------------|
| Any endpoint that reads/writes a resource by ID | W-001, W-011, W-015, W-037 |
| Login / logout / password reset / MFA | W-007, W-012, W-033, W-034, W-038, W-039, W-040 |
| Any form or user input field | W-005, W-023, W-024, W-025, W-027, W-031 |
| File upload / download | W-042, W-043, W-045 |
| REST API design | W-011–W-020 |
| GraphQL endpoint | W-053 (+ W-011, W-014) |
| WebSocket endpoint | W-054 (+ W-007, W-035) |
| Third-party dependency addition | W-003, W-008, W-020 |
| Cryptography / token / password storage | W-004, W-032, W-036 |
| Error handling / exception paths | W-010, W-029 |
| JavaScript / Node.js specific code | W-049, W-050, W-051 |
| Deployment / environment config | W-002, W-009, W-044, W-046 |
| AI / LLM integrated feature | W-057 |
| Cookie / session management | W-035, W-038, W-039, W-048 |
| Redirect or URL handling | W-001 (SSRF/open redirect) |

---

## Severity → Action Protocol

| Severity | Required action |
|----------|----------------|
| **Critical** | Halt. Log THREAT_MODEL_ERROR. Run STRIDE 7-step. No merge until resolved. |
| **High** | Report at end of current analysis pass. Block PR merge until resolved or risk explicitly accepted in plan.md. |
| **Medium** | Batch-report. Log in plan.md Security Debt. Resolve before next sprint. |
| **Low** | Log in plan.md Security Baseline Checklist. |

---

## Reference Files

- `references/vuln-catalog.md` — Full exploit description, attack example, remediation code, and test payload for all 57 items. **Read only the sections you need.**
- `references/checklist.md` — Flat audit checklist used during directive 100-pass analysis (passes 31–90).
