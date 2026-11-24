---
name: database-design
description: Database architecture, SQL migrations, indexing strategies, and query optimization. Use this skill when designing relational schemas (PostgreSQL / Supabase) or document stores (Firestore), writing zero-downtime migrations, optimizing slow queries with EXPLAIN ANALYZE, configuring Row Level Security (RLS) policies, and preventing concurrency deadlocks.
---

# Database Architecture, Migrations & Query Optimization

This skill provides an engineering guide for designing robust schemas, executing safe zero-downtime migrations, tuning indexes and queries, and enforcing database-level multi-tenant security.

---

## 1. Objectives & Scope

- **Schema Normalization & Integrity**: Architect clear Entity-Relationship models with primary keys, foreign keys, unique constraints, and check constraints.
- **Zero-Downtime Migrations**: Implement the Expand-and-Contract migration pattern to evolve schemas without locking tables or breaking active client versions.
- **Query Optimization & Indexing**: Eliminate costly sequential table scans using targeted B-Tree, composite, partial, and covering indexes analyzed via `EXPLAIN ANALYZE`.
- **Row Level Security (RLS)**: Enforce granular multi-tenant access control directly at the database engine level (e.g., Supabase / PostgreSQL).
- **Concurrency & Transactions**: Guard against race conditions and deadlocks using atomic transactions and optimistic locking.

---

## 2. Execution Instructions

### Step 1: Relational Schema Design
1. **Primary Keys**: Prefer UUIDv4 (`gen_random_uuid()`) for distributed/client-generated entities or `bigint generated always as identity` for high-throughput sequential logs.
2. **Foreign Keys**: Always define explicit referential actions:
   - `ON DELETE RESTRICT` (default for financial or audit records to prevent accidental cascading deletion).
   - `ON DELETE CASCADE` (only for tightly bound child records like booking items).
3. **Data Types**:
   - Use `timestamptz` (never naive `timestamp` without timezone).
   - Use `numeric(12, 2)` or integer cents for monetary amounts (never floating point `real` / `float`).
   - Use `text` or `varchar` with constraints; use `boolean` with `not null default false`.

### Step 2: Index Engineering & Optimization
1. **Foreign Key Indexing**: Always add indexes to foreign key columns (PostgreSQL does not index foreign keys automatically; missing indexes trigger slow sequential scans on parent deletions).
2. **Composite Indexes**: Align composite indexes to query equality and range filters following the **Equality, Sort, Range (ESR)** rule:
   ```sql
   -- Optimized for: WHERE user_id = $1 AND status = 'confirmed' ORDER BY created_at DESC
   CREATE INDEX idx_bookings_user_status_created 
   ON bookings (user_id, status, created_at DESC);
   ```
3. **Partial Indexes**: Index only active subsets of rows to save memory and write overhead:
   ```sql
   -- Only indexes active/pending bookings
   CREATE INDEX idx_active_bookings 
   ON bookings (status) 
   WHERE status IN ('pending', 'confirmed');
   ```

### Step 3: Zero-Downtime Migration Pattern (Expand & Contract)
1. **Step 1 (Expand)**: Add the new column as `NULLABLE`. Never add a `NOT NULL` column with a non-constant default on large tables without checking lock safety.
2. **Step 2 (Backfill)**: Run batch updates in transactions to backfill historical data.
3. **Step 3 (Dual-Write / Read)**: Deploy application code that writes to both columns or reads from the new column.
4. **Step 4 (Contract)**: Add the `NOT NULL` constraint with `NOT VALID` then validate asynchronously, and drop the legacy column in a subsequent release.

### Step 4: Row Level Security (RLS) Implementation
1. Enable RLS on every table without exception:
   ```sql
   ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
   ```
2. Write granular policies:
   - Separate `SELECT`, `INSERT`, `UPDATE`, and `DELETE` policies.
   - Use cached helper functions (`auth.uid()`) and ensure columns checked by RLS are indexed.

### Step 5: Query Diagnostics with `EXPLAIN ANALYZE`
1. Execute query plans with buffer usage:
   ```sql
   EXPLAIN (ANALYZE, BUFFERS, COSTS)
   SELECT * FROM bookings 
   WHERE user_id = 'c4b8b80b-...' AND status = 'confirmed';
   ```
2. Inspect output:
   - Look for `Seq Scan` (indicates missing index).
   - Verify `Index Scan` or `Bitmap Index Scan`.
   - Check `Buffers: shared hit` vs `read` (high read indicates disk I/O bottlenecks).

---

## 3. Practical Checklists

### Schema & Index Checklist
- [ ] Primary keys defined on every table.
- [ ] Foreign keys explicitly define `ON DELETE` behavior.
- [ ] Indexes added on foreign key columns and frequent filter/join columns.
- [ ] Currency/money values stored as `numeric(12, 2)` or integer cents.
- [ ] Check constraints added for valid status enums and positive price amounts.

### Migration Safety Checklist
- [ ] Migration is saved in sequential, timestamped file (e.g., `supabase/migrations/20261124120000_add_bookings.sql`).
- [ ] Migration is fully idempotent (`CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`).
- [ ] Tested against staging database containing representative volume.
- [ ] Rollback script written and tested.

### Security Checklist
- [ ] `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;` verified on all tables.
- [ ] RLS policies verified so users cannot view or mutate other users' records.
- [ ] Public anon role restricted; application uses authenticated JWT claims.

---

## 4. Error-Handling & Concurrency Troubleshooting

| Database Issue | Root Cause | Remediation Procedure |
| :--- | :--- | :--- |
| **Deadlock Detected (`40P01`)** | Multiple transactions updating rows in conflicting order | Enforce deterministic lock ordering across all queries (e.g., update parents before children). |
| **Lock Timeout During Migration** | Heavy table lock blocking active read/write traffic | Set statement timeouts (`SET lock_timeout = '2s'`); run index creation concurrently (`CREATE INDEX CONCURRENTLY`). |
| **Slow Query Spike (Sequential Scan)** | Query planner bypassed index due to type mismatch or function call | Ensure query arguments match column type exactly (e.g. don't compare string to uuid). |
| **Infinite RLS Policy Recursion** | Policy queries another table which queries back without bypass | Use `security definer` helper functions with explicit search paths to break recursive policy chains. |

---

## 5. Security Guardrails

- **Zero Superuser App Access**: Applications must connect with a restricted, least-privilege role, never `postgres` superuser or `service_role` in client apps.
- **Row Level Security Enforced**: Every table exposed to client APIs must have RLS active and verified.
- **SQL Injection Prevention**: Never concatenate raw strings into SQL statements; utilize parameterized queries and ORM query builders exclusively.

---

## 6. Examples & Migration Template

### Production-Grade Idempotent SQL Migration
```sql
-- Migration: 20261124120000_create_bookings_and_rls.sql

-- 1. Create Table
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    pnr VARCHAR(10) NOT NULL UNIQUE,
    booking_type VARCHAR(20) NOT NULL CHECK (booking_type IN ('flight', 'hotel')),
    base_fare NUMERIC(10, 2) NOT NULL CHECK (base_fare >= 0),
    taxes NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (taxes >= 0),
    service_fee NUMERIC(10, 2) NOT NULL DEFAULT 1.00 CHECK (service_fee >= 0),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2. Indexes
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_pnr ON public.bookings (pnr);
CREATE INDEX IF NOT EXISTS idx_bookings_status_created ON public.bookings (status, created_at DESC);

-- 3. Enable RLS
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- 4. Policies (Users can only read/manage their own bookings)
CREATE POLICY "Users can view their own bookings" 
ON public.bookings
FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own bookings" 
ON public.bookings
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own pending bookings" 
ON public.bookings
FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```
