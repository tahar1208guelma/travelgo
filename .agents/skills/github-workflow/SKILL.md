---
name: github-workflow
description: Git branches, commits, pull requests, and safe repository synchronization. Use this skill when managing git feature branches, creating conventional commits, safely synchronizing with upstream repositories, resolving merge conflicts, preparing pull requests, and maintaining git safety.
---

# Git & GitHub Workflow: Branches, Commits & Safe Synchronization

This skill defines standard Git workflows, branching strategies, commit conventions, safe synchronization practices, and pull request lifecycles to maintain repository health and prevent regressions.

---

## 1. Objectives & Scope

- **Branch Isolation**: Keep `main` / `master` and `develop` stable; isolate all changes in dedicated feature/fix branches.
- **Conventional Commits**: Ensure commit messages are structured, descriptive, and atomic.
- **Safe Synchronization**: Rebase cleanly against upstream branches without destructive history rewrites on shared branches.
- **Conflict Resolution**: Safely resolve merge conflicts while preserving working functionality and test suites.
- **PR Hygiene**: Produce clean, review-ready pull requests with linked issues and automated verification.

---

## 2. Execution Instructions

### Step 1: Branch Creation & Hygiene
1. Ensure your local base branch (`main` or `develop`) is completely up-to-date:
   ```bash
   git checkout main
   git pull --ff-only origin main
   ```
2. Create and switch to a dedicated topic branch using strict naming conventions:
   - `feature/<feature-name>` (e.g., `feature/flight-filter-chips`)
   - `fix/<bug-name>` (e.g., `fix/currency-conversion-rounding`)
   - `refactor/<scope>` (e.g., `refactor/commission-service`)
   - `test/<scope>` (e.g., `test/booking-summary-coverage`)
   ```bash
   git checkout -b feature/flight-filter-chips
   ```
3. Never develop directly on `main` or `master`.

### Step 2: Atomic Staging & Conventional Commits
1. Stage changes logically in atomic units:
   ```bash
   git add <specific-files>
   git status --short
   ```
2. Formulate commit messages following **Conventional Commits 1.0.0**:
   - Format: `<type>(<scope>): <short description in imperative mood>`
   - Types:
     - `feat`: New user-facing or architectural capability.
     - `fix`: Bug fix.
     - `refactor`: Code change that neither fixes a bug nor adds a feature.
     - `test`: Adding or correcting tests.
     - `docs`: Documentation updates.
     - `chore`: Build scripts, dependencies, or tooling tweaks.
   - Example:
     ```bash
     git commit -m "feat(flights): add non-stop filter chip to search bar"
     ```

### Step 3: Safe Synchronization & Rebasing
1. Before publishing or creating a PR, synchronize with recent upstream changes:
   ```bash
   git fetch origin
   git rebase origin/main
   ```
2. If working on a private feature branch that was rebased, push safely using `--force-with-lease`:
   ```bash
   git push --force-with-lease origin feature/flight-filter-chips
   ```
3. **NEVER** use `--force` or `--force-with-lease` on shared or protected branches (`main`, `master`, `develop`).

### Step 4: Resolving Conflicts Safely
1. When a conflict occurs during rebase:
   ```bash
   git status # Inspect conflicted files (both modified)
   ```
2. Open each conflicted file, locate the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`), and resolve the differences.
3. Verify that the resolution does not break existing functionality or remove concurrent team fixes.
4. Mark resolved files and continue rebase:
   ```bash
   git add <resolved-file>
   git rebase --continue
   ```
5. If the rebase goes wrong or gets confused:
   ```bash
   git rebase --abort # Safely returns repository to pre-rebase state
   ```

### Step 5: Pull Request Preparation
1. Run local test suite and static analysis before pushing:
   ```bash
   flutter analyze
   flutter test
   ```
2. Push branch to remote:
   ```bash
   git push -u origin feature/flight-filter-chips
   ```
3. Open PR with clear title, problem statement, solution summary, and testing evidence.

---

## 3. Practical Checklists

### Pre-Commit Checklist
- [ ] Working tree clean of unintentional files (`.env`, `.DS_Store`, build artifacts).
- [ ] Diff inspected (`git diff --staged`) to ensure only relevant changes are staged.
- [ ] Commit message adheres to Conventional Commits format.

### Pre-Sync & Rebase Checklist
- [ ] Current working tree is committed or safely stashed (`git stash`).
- [ ] Target branch fetched from origin (`git fetch origin`).
- [ ] Rebase command executed against the intended base branch.

### Pull Request Checklist
- [ ] PR targets the correct base branch (`develop` or `main`).
- [ ] Description links to corresponding ticket/issue (e.g., `Closes #42`).
- [ ] Breaking changes (if any) are highlighted with migration instructions.
- [ ] All CI automated tests, linters, and build checks pass cleanly.
- [ ] No un-merged rebase markers or conflict remnants.

---

## 4. Error-Handling & Disaster Recovery Matrix

| Emergency Scenario | Cause | Safe Recovery Procedure |
| :--- | :--- | :--- |
| **Accidental Commit on `main`** | Forgot to checkout feature branch before committing | `git branch feature/my-work` (saves current state to new branch), then `git reset --hard origin/main` (resets local main). |
| **Lost Commits After Rebase** | Rebase misstep or bad reset | Run `git reflog`, identify the commit hash prior to rebase, and restore via `git reset --hard <hash>`. |
| **Dirty Working Tree Blocking Checkout** | Uncommitted changes collide with target branch | Run `git stash save "wip-work"`, checkout target branch, then restore with `git stash pop`. |
| **Failed Pre-Commit Hook** | Linter or formatter failed | Fix formatting violations identified by the hook; never use `--no-verify` unless approved by tech lead. |

---

## 5. Security Guardrails

- **Zero Secret Commits**: Verify `.gitignore` ignores `.env`, keystores (`*.jks`, `*.keystore`), and credentials (`google-services.json`).
- **Never Force-Push to Protected Branches**: Restrict force push permissions on GitHub repository settings for `main` and `develop`.
- **Signed Commits**: Enable GPG/SSH commit signing (`git config commit.gpgsign true`) for cryptographic verification of author identity.
- **Dependency Integrity**: Always commit lockfiles (`pubspec.lock`, `package-lock.json`) alongside package manifest changes.

---

## 6. Examples & Command Sequences

### Creating a Clean Feature Branch & Submitting PR
```bash
# 1. Update main
git checkout main
git pull --ff-only origin main

# 2. Branch
git checkout -b feature/hotel-booking-cancellation

# 3. Make changes and commit
git add lib/features/hotels/domain/usecases/cancel_hotel_booking.dart
git commit -m "feat(hotels): implement hotel booking cancellation usecase"

git add test/unit/features/hotels/cancel_hotel_booking_test.dart
git commit -m "test(hotels): add unit tests for booking cancellation failure states"

# 4. Synchronize with latest main
git fetch origin
git rebase origin/main

# 5. Push branch
git push -u origin feature/hotel-booking-cancellation
```
