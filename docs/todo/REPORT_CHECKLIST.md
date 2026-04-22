# Report Checklist

Before reporting work as complete, run these commands and verify results:

## AGENTS.md Self-Check (Required Before and After Each Batch)

### Pre-plan check (before planning/execution)

1. Re-read `AGENTS.md` human rules.
2. State intended batch scope in one line.
3. Confirm scope does not violate:
   - no compatibility/fallback/workaround paths
   - naming must stay simple and intentional
   - no ideology drift outside terminal scope
   - no compounding/stale docs
   - engineer must not edit `//!` / `///` lines

### Post-execution check (after edits, before report)

Run:

```bash
zig build
zig build test
rg -n "compat[^ib]|fallback|workaround|shim|stub" --glob '*.zig' src
rg -n "^//!|^///" --glob '*.zig' src
git diff --name-only
```

Then explicitly verify:
1. Edited files and commit scope still match the planned batch intent.
2. No AGENTS.md rule was violated during the batch.
3. Any unavoidable scope drift is called out in report as a blocker, not hidden.

## Build & Test

```bash
zig build
zig build test
```

**Expected**: Both commands exit with code 0 (success).

## Commit Integrity

For each commit being reported, run:

```bash
git show --name-status <hash>
```

**Expected**: Output matches all files mentioned in the commit report.

## Code Quality Checks

### No ticket tags in Zig source:

```bash
rg -n "HT-[0-9]+|CZH-[0-9]+|JIRA|ticket" --glob '*.zig' src build.zig
```

**Expected**: Zero matches (no output).

### No forbidden imports in parser/tests:

```bash
rg "app_logger|session|publication|ffi|android|platform|editor|workspace" --glob '*.zig' src/parser src/event src/screen src/test src/root.zig
```

**Expected**: Zero matches or only intentional comments like "No session/app coupling".

### No legacy brand strings or compat code:

```bash
rg "zide|ZIDE|compat[^ib]|fallback|stub|shim|workaround" --glob '*.zig' src build.zig
```

**Expected**: Zero matches.

## Report Format

When reporting completion, include:
1. Commit hash and message
2. Files changed (from `git show --name-status`)
3. 1-line claim → file mapping
4. Build/test validation results

This ensures all claims match actual diffs and all validation passed.
