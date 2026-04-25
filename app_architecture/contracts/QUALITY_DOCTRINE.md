# M10 Quality Doctrine Contract

`QUALITY_DOCTRINE_CONTRACT` — introduced for `M10`.

Authority for long-horizon quality claims in `howl-vt-core` after frozen
`M1-M9` baselines.

## Purpose

Define quality dimensions, priority ordering, and acceptance vocabulary so
improvements stay contract-driven and reproducible.

This doctrine does not change runtime semantics. It defines how quality claims
must be justified and reviewed.

## Quality Priority Order

When tradeoffs conflict, this order applies:

1. correctness and determinism preservation
2. contract clarity and ownership simplicity
3. reproducible operational evidence
4. sustained performance/memory discipline
5. implementation convenience

## Quality Dimensions

A change may claim M10 quality value only if it improves one or more dimensions:

- deterministic behavior under mixed operation sequences
- regression resistance across fixture/evidence matrices
- diagnosability of contract-visible failures
- bounded memory/performance behavior under representative pressure
- maintainability of ownership boundaries and public surfaces

## Required Evidence Classes

Every M10 quality claim must provide at least one explicit class:

- `Q1` correctness-preservation evidence
- `Q2` reproducibility evidence (repeatable procedure)
- `Q3` operational pressure evidence (stress/soak/drift)
- `Q4` maintainability evidence (surface simplification without semantic drift)

## Disallowed Quality Claims

Not allowed as primary M10 justification:

- benchmark-only speedups without contract-visible product impact
- host-specific behavior presented as universal quality truth
- “cleanup” claims without measurable or contract-traceable effect

## Breaking Change Rule

A change is breaking if it:

1. reorders quality priority without authority update,
2. redefines required evidence classes,
3. allows convenience/perf to outrank correctness.

## Required References

- `app_architecture/authorities/M10_FOUNDATION.md`
- `app_architecture/contracts/HOST_CONFORMANCE.md`
- `app_architecture/contracts/RUNTIME_API.md`
- `app_architecture/contracts/SNAPSHOT_REPLAY.md`
