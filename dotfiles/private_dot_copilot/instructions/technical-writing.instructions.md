---
description: "Use when writing or revising design documents, HLDs, ADRs, RFCs, requirements, runbooks, or other technical prose in markdown. Covers scope discipline, repetition, level of detail, and not referencing prior drafts or chat history."
applyTo: "**/*.md"
---

# Writing technical design documents

## Write for someone who has only this document

- Never reference earlier drafts or our conversation. Phrases like "previously",
  "no longer", "an earlier revision assumed", "the reason it mattered" send the
  reader looking for context that does not exist.
- Do not argue against a position the document never states. "X, not Y" works
  only when Y appears somewhere in the document. Otherwise just state X.
- Rejected options belong in an Alternatives section, not as asides in the body.

## Say it once

- Each concept gets one section that explains it. Every other mention is a
  clause and a link, not a restatement of the argument.
- If two sections cover the same ground, merge them rather than cross-referencing
  back and forth.

## Match the document's altitude

- A high-level design needs enough detail to be confident the feature can be
  built. It is not the place for third-party implementation internals,
  environment variable names and their defaults, or step-by-step operational
  procedure. Those belong in a runbook or are settled at implementation time.

## In desgin documents or other proposals, be explicit about what is new

- At first mention or at the start of a section, identify whether behavior is
  current ("currently", "today", or "the existing..."), delivered by this work
  ("this feature adds/changes..."), or owned elsewhere ("#123 owns...").
- After a section is framed as the proposed design, use present tense to describe
  its final state: "the chart installs..." does not imply that the chart already
  exists.
- Do not rely on `will` or other future-tense wording to distinguish unimplemented
  work from existing behavior. The status must remain clear if the proposed
  final state is written in present tense.
- If a section moves between current and proposed behavior, establish the status
  again at the transition instead of expecting tense to carry it.
- In configuration tables, separate new settings from upstream or pre-existing
  ones, or add a column that says which is which.

## Do not editorialize

- No self-congratulation: "guaranteed by construction rather than by convention",
  "impossible rather than merely discouraged", "eliminates the class of bug
  instead of handling it". Describe the mechanism and let the reader judge.
- Do not assert a property in order to justify a choice unless the property has
  been verified.

## Stay inside the ask

- Make the requested change and nothing else. When compressing or relocating
  text, do not add a sentence justifying the compression.
- If something looks missing or wrong, raise it separately instead of adding it
  silently.
- Check that an example actually holds for the scope it is claimed for.
