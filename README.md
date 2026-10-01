# high-accuracy-work

This plugin adds one Claude Code skill that sets a standard for work on the
user's files and data. The skill applies when a task reads, analyzes, extracts
from, compares, or transforms documents, scans, images, spreadsheets, datasets,
or code. Its goal is a result that the user can rely on, with no need to do the
work again.

## What the skill requires

- **Method:** The agent judges meaning itself, and it uses scripts for
  mechanical steps such as file counts, format conversion, and arithmetic.
- **Confidentiality:** File contents stay inside the approved environment, and
  nothing from the files goes to another service unless the user asks for it.
- **Coverage:** The agent lists every file in scope, processes every page and
  sheet, and accounts for each file at the end.
- **Verification:** The agent checks key facts against the source, computes
  derived numbers with code, and cross-checks totals against their parts.
- **Calibration:** Each claim carries the confidence that its evidence supports,
  and the agent never fills a gap with a plausible value.
- **Limits:** The agent states what it cannot do reliably, with the location
  and the reason, and it labels every fallback.
- **Delivery:** The report gives the results first, then the limits with their
  locations, then the coverage summary.

Explicit instructions from the user or the project take precedence over these
defaults.

## What is in the plugin

| Path | What it does |
| --- | --- |
| `skills/high-accuracy-work/SKILL.md` | It holds the standard. |
| `verify.sh` | It runs the main CI checks locally. |

The skill has no scripts and no references.

## Install

1. Add the marketplace:

   ```text
   /plugin marketplace add phj6688/claude-marketplace
   ```

2. Install the plugin:

   ```text
   /plugin install high-accuracy-work@phj
   ```

3. Start a new session. The skill loads when a task works on your files or
   data.

## Usage

Ask for the work in plain words. The skill loads by itself for file and data
work. For example, it loads for these requests:

- "Pull the totals out of these scanned invoices."
- "What changed between these two contract versions?"

To load the skill by name, type this command:

```text
/high-accuracy-work:high-accuracy-work
```

## The verify gate

`./verify.sh` runs six checks. Each check prints one PASS, FAIL or SKIP line,
and the script exits non-zero when a check fails.

1. Every JSON file parses, and `.claude-plugin/plugin.json` has a name, a
   version, a description and a skills path that exists.
2. Every `SKILL.md` has frontmatter with a name and a description. The name is
   kebab-case, has 64 characters or fewer, and matches its directory name. The
   description has 1024 characters or fewer and no angle brackets.
3. No `.md`, `.sh`, `.json`, `.yml` or `.yaml` file in the repo contains an em
   dash or an en dash.
4. `CHANGELOG.md` has an entry for the version in `plugin.json`.
5. When the `claude` CLI is on the PATH, `claude plugin validate --strict .`
   passes.
6. When shellcheck is installed, `shellcheck` passes on every shell script.

CI runs checks 1 to 4 and check 6. CI also fails on an empty Markdown file, and
it runs markdownlint as a warning only. On a release tag, CI also checks that
the tag matches the version in `plugin.json`.

## Licence

This repo uses the MIT licence. See `LICENSE`.
