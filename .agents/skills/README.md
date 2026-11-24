# Antigravity Custom Agent Skills Collection

This directory contains the professional collection of custom Agent Skills engineered for software development projects, adhering to Antigravity's Customization System specifications and Clean Architecture principles.

---

## 1. Directory Structure

```text
.agents/skills/
├── api-integration/
│   └── SKILL.md                 # REST API integration, DTOs & network debugging
├── automated-testing/
│   └── SKILL.md                 # Unit, widget & integration test engineering
├── code-review/
│   └── SKILL.md                 # Senior-level code review & architectural audit
├── database-design/
│   └── SKILL.md                 # SQL schema design, migrations, RLS & indexing
├── flutter-optimization/
│   └── SKILL.md                 # Frame-rate, memory leaks & rebuild optimization
├── github-workflow/
│   └── SKILL.md                 # Branches, conventional commits & safe rebase
├── ocr-document-processing/
│   └── SKILL.md                 # Document scanning, ICAO 9303 MRZ OCR & checksums
├── pdf-processing/
│   └── SKILL.md                 # Vector PDF vouchers, RTL/Arabic fonts & forms
├── production-deployment/
│   └── SKILL.md                 # Release builds, CI/CD, signing & smoke tests
├── security-audit/
│   └── SKILL.md                 # Vulnerability scanning, secret detection & OWASP
└── README.md                    # Skills catalog and invocation guide
```

---

## 2. Skills Catalog & Invocation Triggers

| # | Skill Name | Primary Responsibility | Example Invocation Triggers |
| :---: | :--- | :--- | :--- |
| **1** | `code-review` | Senior-level architectural & quality review | *"Review my changes against Clean Architecture"*, *"Perform a code review on this pull request"*, *"Check this controller for memory leaks"* |
| **2** | `security-audit` | Vulnerability assessment & secret detection | *"Audit our API endpoints for OWASP flaws"*, *"Scan the repository for leaked API keys"*, *"Check Row Level Security policies"* |
| **3** | `api-integration` | REST API integration, DTOs & debugging | *"Integrate the flight search REST endpoint"*, *"Debug this 401 token refresh issue"*, *"Write type-safe DTOs for this JSON response"* |
| **4** | `automated-testing` | Unit, widget & integration test engineering | *"Write unit tests for BookingSummaryNotifier"*, *"Create a widget test for the flight search screen"*, *"Fix flaky pumpAndSettle test"* |
| **5** | `github-workflow` | Git branches, commits & safe synchronization | *"Create a feature branch for hotel cancellations"*, *"Rebase cleanly onto origin/main"*, *"Resolve merge conflicts in pubspec.lock"* |
| **6** | `flutter-optimization` | Performance tuning, memory & rebuild optimization | *"Eliminate UI jank during list scrolling"*, *"Optimize Riverpod selectors to reduce rebuilds"*, *"Fix memory leak in flight detail screen"* |
| **7** | `ocr-document-processing`| Document capture, OCR extraction & validation | *"Implement passport MRZ scanning with ML Kit"*, *"Verify ICAO 9303 check digits on passport numbers"*, *"Validate extracted ID expiration date"* |
| **8** | `pdf-processing` | PDF generation, RTL fonts, forms & printing | *"Generate a flight booking confirmation voucher"*, *"Embed Arabic Cairo fonts and QR codes in PDF"*, *"Fill and flatten the boarding pass PDF form"* |
| **9** | `database-design` | Schema design, migrations, indexing & RLS | *"Design an idempotent migration for the bookings table"*, *"Optimize slow queries using EXPLAIN ANALYZE"*, *"Configure Supabase RLS policies for user data"* |
| **10**| `production-deployment`| Release builds, CI/CD & post-deploy checks | *"Build release Android App Bundle with obfuscation"*, *"Configure GitHub Actions CI/CD release workflow"*, *"Perform smoke testing on production deployment"* |

---

## 3. How Antigravity Discovers Workspace Skills

Antigravity uses hierarchical filesystem discovery to locate workspace customizations:
1. **Discovery Root**: The agent searches `.agents/skills/` (and `.agent/`, `_agents/`, `_agent/`) starting from the current working directory up to the repository root (the directory containing `.git`).
2. **Metadata Ingestion**: Antigravity parses the YAML frontmatter (`name` and `description`) of every `SKILL.md` file found in the workspace.
3. **Progressive Disclosure**: To protect context window efficiency, skill instructions are loaded on-demand. Only the skill name and description are held in the index; the full instructions are activated when the prompt matches the skill's domain.
4. **Precedence**: Workspace skills defined in `.agents/skills/` take highest priority over machine-global (`~/.gemini/config/`) and built-in bundled skills.

---

## 4. How to Invoke Each Skill

### Method A: Intent-Based Automatic Invocation (Recommended)
Because each skill has a well-defined `description` in its frontmatter, Antigravity automatically detects when your prompt requests a workflow matching that skill.
- Prompt: `"Please perform a senior code review on the latest commit in lib/features/flights"` $\rightarrow$ Triggers `code-review`.
- Prompt: `"Audit our storage service and API client for security vulnerabilities"` $\rightarrow$ Triggers `security-audit`.
- Prompt: `"Optimize our list rendering to eliminate dropped frames"` $\rightarrow$ Triggers `flutter-optimization`.

### Method B: Explicit Skill Naming
You can explicitly instruct the agent to use a specific skill by name:
- `"Using the database-design skill, write an idempotent migration to add hotel reservations."`
- `"Follow the automated-testing skill to implement unit tests for the auth repository."`
- `"Apply the github-workflow skill to prepare a clean rebase and PR description."`

---

## 5. Architectural Compliance & Guardrails

All skills comply with `AGENTS.md`:
- **Clean Architecture**: Domain layer remains pure Dart without Flutter UI or database dependencies.
- **Financial Integrity**: Prices, taxes, and service fees ($1.00 USD standard fee) are deterministically computed by domain services—never hallucinated or modified by LLMs.
- **Zero Client Secrets**: Third-party private keys and payment credentials are never committed or packaged into client binaries.
