---
name: security-audit
description: Application security and vulnerability assessment for software projects. Use this skill when auditing source code, dependencies, configuration files, and APIs for security flaws, hardcoded credentials, OWASP vulnerabilities, authorization bypasses, insecure storage, and data leakage risks.
---

# Security Audit & Vulnerability Assessment

This skill provides a comprehensive methodology for analyzing software repositories, client applications, backend services, and cloud configurations to detect and remediate security vulnerabilities.

---

## 1. Objectives & Scope

- **Secret & Credential Leakage**: Identify committed private keys, JWTs, API tokens, passwords, and service account files.
- **OWASP Application Risks**: Audit against OWASP Top 10 (Web & API) and OWASP Mobile Top 10 (e.g., Insecure Data Storage, Broken Cryptography, Broken Access Control).
- **Authentication & Authorization**: Verify role-based access control (RBAC), token lifecycles, and session boundaries.
- **Software Composition Analysis (SCA)**: Scan transitive dependencies and third-party libraries for known CVEs.
- **Data Protection & Privacy**: Guard against plaintext PII logging, unencrypted caching, and improper data retention.

---

## 2. Execution Instructions

### Step 1: Threat Modeling & Attack Surface Mapping
1. Map trust boundaries: Client UI <-> API Gateway / Cloud Functions <-> Database / External Third-Party APIs.
2. Identify high-value assets:
   - Payment credentials, tokens, and billing records.
   - PII (passports, national IDs, email addresses, phone numbers).
   - Administrative endpoints, private storage buckets, and database credentials.
3. Determine external exposure points: public REST endpoints, webhooks, URL schemes, deep links.

### Step 2: Automated & Pattern-Based Secret Scanning
1. Search codebase for high-risk patterns and hardcoded secrets:
   ```bash
   # Scan for private keys, secret strings, and authorization tokens
   git grep -EI "(AKIA[0-9A-Z]{16}|bearer\s+[a-zA-Z0-9_\-\.]+|BEGIN PRIVATE KEY|sk_live_[0-9a-zA-Z]{24})"
   ```
2. Inspect configuration files and `.env` files:
   - Verify `.env` is listed in `.gitignore`.
   - Verify no production secret keys are committed to source control.
   - Ensure only `.env.example` templates with placeholder values are checked in.

### Step 3: Client & Mobile Security Review
1. **Local Storage Security**:
   - Check sensitive token storage: Must use platform secure storage (`flutter_secure_storage`, Android Keystore, iOS Keychain).
   - Ensure unencrypted shared preferences or SQLite databases do not store auth tokens or payment data.
2. **Reverse Engineering & Tampering**:
   - Verify code shrinking/obfuscation is configured for release builds (`minifyEnabled true`, `obfuscate: true`).
   - Check for SSL certificate pinning or platform network security configurations (NSAppTransportSecurity, Android networkSecurityConfig).
3. **Deep Links & URL Schemes**:
   - Verify incoming deep links validate scheme, host, and path parameters to prevent intent hijacking or open redirects.

### Step 4: Backend & API Authorization Review
1. **Broken Object Level Authorization (BOLA)**:
   - Verify that accessing `/users/:id/bookings` checks that the caller's verified `auth.uid` matches `:id` (or possesses admin role).
2. **Database Row Level Security (RLS)**:
   - If using Supabase/PostgreSQL, verify `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;` is enabled on all tables.
   - Check that policies enforce `auth.uid() = user_id`.
3. **Mass Assignment & Input Validation**:
   - Verify request schemas reject unexpected fields (e.g., user payloads attempting to set `role: "admin"`).
4. **Rate Limiting & Abuse Prevention**:
   - Confirm login, OTP, password reset, and AI chat endpoints have strict rate limits.

### Step 5: Dependency Vulnerability Audit
1. Run package vulnerability checks:
   ```bash
   # Flutter/Dart
   dart pub outdated
   # Node.js/Backend
   npm audit --audit-level=high
   ```
2. Verify lockfiles are committed (`pubspec.lock`, `package-lock.json`) to prevent untracked upstream dependency tampering.

### Step 6: Log Sanitization & PII Protection
1. Inspect logging utilities to ensure sensitive fields are scrubbed:
   - Redact passwords, tokens, full credit card numbers, CVVs, and auth headers.
2. Confirm debug logging is stripped in release builds (`kReleaseMode` or environment flag).

---

## 3. Practical Checklists

### Pre-Audit Checklist
- [ ] Codebase is indexed and repository branch is up-to-date.
- [ ] List of external integrations (payment processors, travel APIs, AI gateways) is documented.
- [ ] Target environment (Production vs Staging vs Local) is specified.

### Security Audit Checklist
- [ ] **No Hardcoded Secrets**: Zero private keys, API secrets, or database passwords in code or commit history.
- [ ] **Secure Communication**: All API communication enforces HTTPS/TLS 1.3 with certificate validation.
- [ ] **Data at Rest**: Sensitive offline data is encrypted via secure platform hardware enclaves.
- [ ] **Authentication**: Tokens have strict expiry; refresh tokens are stored securely and invalidated on logout.
- [ ] **Authorization**: Every read/write operation verifies user ownership or appropriate roles.
- [ ] **Input Sanitization**: All user-supplied strings and parameters are validated and escaped against SQL injection and XSS.
- [ ] **AI Guardrails**: AI endpoints strictly proxy through backend gateways with zero third-party keys exposed on client.
- [ ] **Financial Integrity**: Prices, taxes, commissions, and booking totals are strictly verified server-side.

### Post-Audit & Remediation Checklist
- [ ] Vulnerabilities triaged by CVSS / severity (Critical, High, Medium, Low).
- [ ] Immediate revocation/rotation performed for any exposed secrets.
- [ ] Regression tests added to prevent vulnerability reintroduction.

---

## 4. Error-Handling & Vulnerability Triage

| Finding Severity | CVSS Score | Maximum SLA | Required Action |
| :--- | :--- | :--- | :--- |
| **Critical** | 9.0 – 10.0 | < 24 Hours | Immediate hotfix. Rotate compromised keys/secrets instantly. Block release. |
| **High** | 7.0 – 8.9 | < 72 Hours | Patch in current sprint. Add integration regression tests. |
| **Medium** | 4.0 – 6.9 | Next Release | Prioritize in regular backlog. Enforce defensive checks. |
| **Low / Info** | 0.1 – 3.9 | Backlog | Address during regular maintenance or refactoring. |

---

## 5. Security Guardrails

- **Zero Client Secrets**: Third-party private keys, secret tokens, and payment provider credentials must **never** be packaged into client binaries.
- **Fail-Secure Defaults**: Security checks must fail closed (e.g., if authorization check throws an exception, deny access by default).
- **Principle of Least Privilege**: Service accounts and database connections must only have the minimum permissions needed to perform their task.

---

## 6. Examples & Findings Templates

### Vulnerability Report Template
```markdown
### [VULN-001] Insecure Storage of Authentication Tokens (High - CVSS 7.5)

**Component**: `lib/core/services/storage_service.dart`
**Vulnerability Type**: Insecure Local Data Storage (CWE-312)

#### Description
The application stores the user's JWT access and refresh tokens in plaintext `SharedPreferences` rather than platform-encrypted keychains. On rooted/jailbroken devices or backup extraction, an attacker can extract these tokens.

#### Vulnerable Code
```dart
// INSECURE
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);
```

#### Remediation
Migrate token storage to encrypted hardware-backed storage using `FlutterSecureStorage`:
```dart
// SECURE
const secureStorage = FlutterSecureStorage();
await secureStorage.write(
  key: 'auth_token', 
  value: token,
  aOptions: const AndroidOptions(encryptedSharedPreferences: true),
  iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);
```
```
