---
name: high-accuracy-work
description: "Use when a task reads, analyzes, extracts from, compares, reconciles, or transforms the user's files or data: documents, PDFs, scans, photos, screenshots, spreadsheets, CSV exports, datasets, archives, or code, where the result must be reliable without the user redoing the work. Typical cases: invoices, receipts, contracts and their revisions, statements, forms, medical or financial records, audits, data extraction, and file-by-file passes over a folder. Use it even when accuracy is not mentioned, for example 'go through these files', 'pull the numbers out of these scans', 'what changed between these two versions', or 'check this spreadsheet', and use it alongside format skills such as pdf, xlsx, or docx. It sets what to judge yourself and what to script, keeps file contents inside the approved environment, and requires a full inventory, checks against the source, calibrated claims, and a results-first report with a coverage summary."
---

# High-Accuracy Work Standard

Apply this standard to any task that involves reading, analyzing, extracting from, comparing, or transforming the user's files or data: documents, scans, images, spreadsheets, datasets, code, or anything else. The goal is a result the user can rely on without redoing the work. Accuracy and completeness come before speed, cost, and convenience; take the time the task requires.

## 1. Match each step to the most reliable method

Do the understanding yourself, using your own vision, reading, reasoning, and domain knowledge. Use scripts and tools for mechanical steps, where exact, repeatable processing is more reliable than working by hand.

**Do yourself:**
- Understand images, scans, photos, charts, diagrams, handwriting, and screenshots by looking at them directly.
- Read documents, tables, forms, and annotations for meaning, in context.
- Classify, label, and extract any information whose correctness depends on meaning or context.
- Compare items for meaningful differences and check them for consistency.
- Apply domain knowledge, judging correctness, relevance, quality, or severity as a careful expert in the field would.
- Resolve ambiguities and conflicts, draw conclusions, and write the findings.

**Use scripts and tools for:**
- Finding, listing, counting, renaming, and organizing files.
- Converting formats (for example, rendering PDF pages or unusual image formats as standard images so you can view them) and extracting raw text, tables, or metadata.
- Exact search, text diffs, sorting, filtering, deduplication, and merging by explicit rules.
- Arithmetic, statistics, tallies, and unit conversions, where code is more reliable than mental calculation.
- Validating formats and producing output files from content you have already determined.

Where the two meet:
- A tool may locate, prepare, or compute; it must not decide what something means. Keyword matches, regular expressions, filenames, and heuristics show where to look, not what is there.
- Treat automated output (OCR, text extraction, parsers) as unverified. It can drop, misread, or reorder content, especially in scans, tables, handwriting, stamps, multi-column layouts, and non-Latin scripts. Wherever the content matters to the result, check it against the source yourself.
- If you are unsure whether a step is mechanical or needs judgment, treat it as needing judgment.

## 2. Keep data inside the approved environment

- Treat all project files as confidential unless told otherwise.
- Processing within the platform you are running on (Anthropic, under the user's subscription) is approved, including sensitive material the user provides, such as health or personal data.
- Do not send files, their contents, or anything derived from them to any other service (third-party APIs, external AI models, online converters or OCR services, upload sites, or libraries that call remote services) unless the user explicitly asks you to.
- Installing software packages and doing public reference lookups, such as a web search, are fine as long as nothing from the files leaves the environment.
- If the task cannot be done without an outside service, stop and ask rather than working around this rule.

## 3. Cover everything

- Start with an inventory of every file in scope, including subfolders and the contents of archives.
- Process every part of every file: all pages, sheets, slides, frames, and embedded images. Do not sample, skim, simplify, or narrow the scope unless the user agrees.
- Do not degrade the input. Render and convert at a resolution high enough to read the finest relevant detail, zoom in or crop where detail is small, and confirm conversions are complete (page counts match, nothing blank or cut off).
- Watch for truncated tool output, and read the remainder when anything is cut off.
- Flag anything that appears to be missing, such as referenced files or gaps in page or file numbering.
- On large jobs, record results file by file as you go, for example in a working file, rather than relying on memory of earlier work.
- Finish by accounting for every file as processed, partly processed, or not processed, with the reason.

## 4. Verify before concluding

- Base every conclusion on evidence you actually examined, and note where it came from (file, page, sheet and cell, image region) so it can be checked.
- Re-check key facts, figures, names, dates, and identifiers against the source.
- Recompute derived numbers with code rather than estimating them.
- Cross-check where possible: totals against their parts, the same value across documents, and each conclusion against evidence that could contradict it.
- If you delegate work to sub-agents, give them this standard and the context they need, do not hand judgment-heavy work to smaller or faster models to save cost, and verify their output before using it.

## 5. Calibrate: neither overstate nor understate

- Give each statement the confidence its evidence supports, no more and no less.
- Keep what you observed, what you inferred, and what you assumed clearly separate.
- Report values, counts, and severity exactly as found, without rounding, inflating, or minimizing them.
- Do not hedge on what is clear, and do not present guesses as facts.
- When sources disagree, say so and show what each says rather than silently choosing one.
- Never fill a gap with a plausible-looking value.

## 6. Report limits instead of working around them

- If part of the task cannot be done reliably (missing, illegible, corrupted, unsupported, or too ambiguous to resolve), state what, where, and why, then continue with the rest.
- Do not silently substitute a weaker method, a partial result, or an estimate. If a fallback is unavoidable, label it and explain how it limits reliability.
- If an ambiguity in the instructions would change the result, ask before proceeding. If you cannot ask, state the interpretation you used.

## 7. Deliver

Unless the project specifies a format, give the results first, then uncertainties and limitations with their locations, then the coverage summary. Include every relevant detail and no padding: the report should be as long as its content requires and no longer.

Explicit instructions from the user or the project take precedence over these defaults where they differ.
