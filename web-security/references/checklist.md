# Web Security Audit Checklist
# Used during directive 100-pass analysis (passes 31–90)
# Status values: [ ] = not checked | [x] = pass | [!] = finding | [N/A] = not applicable

## TIER 1 — OWASP Top 10:2025

### A01 — Broken Access Control (W-001)
- [ ] Every resource endpoint verifies the caller owns/can-access the specific object (BOLA/IDOR).
- [ ] Deny-by-default is implemented at the framework level; access is explicitly granted.
- [ ] SSRF: all user-supplied URLs are validated against an allowlist before server-side fetch.
- [ ] Private RFC-1918 ranges and link-local addresses are blocked from SSRF fetch targets.
- [ ] CORS `Access-Control-Allow-Origin` uses an explicit allowlist; no wildcard with credentials.
- [ ] OAuth `redirect_uri` is validated by exact match, not prefix match.
- [ ] All admin and privileged endpoints are protected at both route AND function level.

### A02 — Security Misconfiguration (W-002)
- [ ] All 6 required security headers present: `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Content-Security-Policy`, `Permissions-Policy`.
- [ ] Default credentials removed from all deployed components.
- [ ] Directory listing disabled on web server.
- [ ] Verbose error pages disabled in production.
- [ ] Unnecessary HTTP verbs (TRACE, DEBUG) disabled.
- [ ] Server banner headers (`Server:`, `X-Powered-By:`) removed.

### A03 — Software Supply Chain Failures (W-003)
- [ ] All dependencies pinned to exact versions; lock files committed.
- [ ] SCA scan (npm audit / pip-audit / Snyk) runs in CI/CD on every PR.
- [ ] No dependency with a CVSS ≥ 9.0 unpatched CVE.
- [ ] SRI `integrity` attribute present on all CDN-loaded scripts and stylesheets.
- [ ] SBOM generated for this release.

### A04 — Cryptographic Failures (W-004)
- [ ] No MD5, SHA-1, DES, RC4, or AES-ECB anywhere in the codebase.
- [ ] Passwords hashed with Argon2id (m≥19456, t≥2, p=1) or bcrypt cost ≥ 12.
- [ ] Symmetric encryption uses AES-256-GCM with unique IV per operation.
- [ ] TLS 1.2 minimum enforced; SSLv3 / TLS 1.0 / TLS 1.1 disabled.
- [ ] Secrets / keys never present in source code, logs, or environment variable dumps.
- [ ] Constant-time comparison used for all secret/hash comparisons.

### A05 — Injection (W-005)
- [ ] All SQL uses parameterized queries or ORM with bound parameters; no string interpolation.
- [ ] All output HTML-encoded in context; `Content-Security-Policy` deployed.
- [ ] No `subprocess(shell=True)`, `os.system()`, `eval()`, `exec()` with external input.
- [ ] LDAP queries escape special characters before use in filter expressions.
- [ ] XPath queries use parameterized API; no user input concatenated.
- [ ] Template engines do not render user input as template code (SSTI prevention).
- [ ] XML parsers have external entity processing disabled (XXE prevention).

### A06 — Insecure Design (W-006)
- [ ] Threat model completed for all critical features before implementation.
- [ ] Business logic flows validated server-side; no client-side-only enforcement.
- [ ] Rate limiting applied to all account-creation, password-reset, and coupon flows.

### A07 — Authentication Failures (W-007)
- [ ] MFA available (required for admin/privileged operations).
- [ ] Progressive delay + CAPTCHA after repeated failed logins.
- [ ] JWT validates `alg`, `iss`, `aud`, `exp`, `nbf` on every request.
- [ ] JWT `alg: none` rejected; HS256 not used across service boundaries.
- [ ] Refresh tokens are single-use with rotation; JTI blacklist active.
- [ ] Session ID regenerated after successful authentication.
- [ ] Password hashing meets Tier-1 cryptographic requirements.

### A08 — Software or Data Integrity Failures (W-008)
- [ ] No untrusted deserialization (pickle, ObjectInputStream, unserialize from external source).
- [ ] `yaml.safe_load()` used everywhere YAML is parsed.
- [ ] Auto-update mechanisms verify digital signatures before installing updates.
- [ ] CI/CD pipeline actions pinned to commit SHA, not mutable tags.

### A09 — Security Logging & Alerting Failures (W-009)
- [ ] All authentication events logged (success, failure, lockout).
- [ ] All authorization denials logged with user ID hash and resource ID.
- [ ] Logs are structured JSON; no raw user input injected into log values.
- [ ] `request_id` and `correlation_id` present on every log entry.
- [ ] Alerts configured for: brute-force threshold, unusual data-export volumes.
- [ ] Security logs retained ≥ 1 year.

### A10 — Mishandling of Exceptional Conditions (W-010)
- [ ] All exception handlers fail closed (deny access on error).
- [ ] No silent exception swallowing; all errors logged internally.
- [ ] Production error responses contain only generic message + `request_id`; no internals.
- [ ] Failure paths tested explicitly (fault injection / chaos tests).

---

## TIER 2 — OWASP API Security Top 10:2023

- [ ] W-011 BOLA: Object-level authorization enforced at data layer for every resource ID lookup.
- [ ] W-012 Auth (API): JWT `exp` validated on every request; no expired token accepted.
- [ ] W-013 Mass Assignment: Request body fields explicitly whitelisted via DTO schema.
- [ ] W-014 Resource Consumption: Pagination `max_page_size` enforced server-side; request timeouts set.
- [ ] W-015 Function-Level Authz: Role check present inside every handler for privileged functions.
- [ ] W-016 Business Flow: Rate limits on purchase, coupon redemption, account creation flows.
- [ ] W-017 SSRF (API): All webhook/callback URLs validated against allowlist.
- [ ] W-018 Misconfig (API): GraphQL introspection disabled in production.
- [ ] W-019 Inventory: API version inventory maintained; deprecated versions sunset with headers.
- [ ] W-020 Unsafe API Consumption: Third-party API responses validated before use.

---

## TIER 3 — KISA/MOIS Standards

- [ ] W-021 Buffer Overflow: Input length validated server-side on all fields.
- [ ] W-022 Format String: No `printf(user_input)` or equivalent pattern.
- [ ] W-023 LDAP Injection: Special chars escaped before LDAP filter insertion.
- [ ] W-024 OS Command: No shell=True with external input anywhere.
- [ ] W-025 SQL Injection: All SQL parameterized; KISA-required test payloads pass.
- [ ] W-026 SSI Injection: SSI directives disabled in web server config.
- [ ] W-027 XPath Injection: Parameterized XPath used throughout.
- [ ] W-028 Directory Indexing: Web server returns 403 on directory URL, not listing.
- [ ] W-029 Info Disclosure: Error responses contain only `error_code`, `message`, `request_id`.
- [ ] W-030 Malicious Content: User-generated HTML sanitized server-side before storage.
- [ ] W-031 XSS: DOM and output XSS mitigated; CSP deployed; test payloads verified.
- [ ] W-032 Weak Password: Min 8 / max 64 chars; HaveIBeenPwned check active.
- [ ] W-033 Insufficient Auth: No endpoint returns sensitive data without authentication.
- [ ] W-034 Password Recovery: Reset token is CSPRNG, single-use, 15-minute TTL.
- [ ] W-035 CSRF: SameSite=Strict + CSRF token on all state-changing requests.
- [ ] W-036 Session Prediction: Session IDs generated with CSPRNG, ≥128 bits entropy.
- [ ] W-037 Insufficient Authz: Object ownership verified at data layer for all reads/writes.
- [ ] W-038 Session Expiry: Idle timeout ≤ 10 min; absolute timeout ≤ 8 hours; logout invalidates server session.
- [ ] W-039 Session Fixation: New session ID issued atomically after successful login.
- [ ] W-040 Brute Force: Progressive delay + lockout + IP rate limit active on auth endpoints.
- [ ] W-041 Process Validation: Multi-step workflows enforce step ordering server-side.
- [ ] W-042 File Upload: MIME + magic bytes checked; stored outside web root; execute permissions removed.
- [ ] W-043 Path Traversal (Download): `realpath()` normalization + base-dir prefix check before file open.
- [ ] W-044 Admin Exposure: Admin endpoints not reachable from public internet; MFA required.
- [ ] W-045 Directory Traversal: All file-system paths normalized and prefix-checked.
- [ ] W-046 Server Banner: `Server:`, `X-Powered-By:` headers absent from responses.
- [ ] W-047 Plaintext Transmission: HTTPS enforced; HSTS header with preload set.
- [ ] W-048 Insecure Cookie: Session cookies have `HttpOnly`, `Secure`, `SameSite=Strict`.

---

## TIER 4 — Emerging Threats 2024–2026

- [ ] W-049 Prototype Pollution: JSON input validated with strict schema (no `__proto__`, `constructor`, `prototype` keys).
- [ ] W-050 Cache Poisoning: `Cache-Control: private, no-store` on all authenticated responses.
- [ ] W-051 HTTP Smuggling: `Transfer-Encoding` / `Content-Length` conflicts handled at edge; HTTP/2 end-to-end preferred.
- [ ] W-052 Race Condition: Critical state transitions use DB-level locks or Redis SETNX; idempotency keys on all mutating APIs.
- [ ] W-053 GraphQL: Introspection off; depth ≤ 10; complexity ≤ 1000; resolver-level auth checks present.
- [ ] W-054 WebSocket: Origin header validated on upgrade; auth token required; message rate limited.
- [ ] W-055 Insecure Deserialization: No `pickle`, `ObjectInputStream`, `unserialize` from untrusted source.
- [ ] W-056 Subdomain Takeover: DNS CNAME records audited; no dangling records pointing to decommissioned services.
- [ ] W-057 LLM Prompt Injection: System and user content structurally separated; LLM output treated as untrusted before rendering.
