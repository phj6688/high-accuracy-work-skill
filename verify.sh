#!/usr/bin/env bash
# Repo verify gate. Every step prints one numbered PASS, FAIL or SKIP line, and
# the script exits non-zero when any step fails. Steps 1 to 4 and 6 mirror CI.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILED=0
LIST="$(mktemp "${TMPDIR:-/tmp}/verify-files-XXXXXX")"
trap 'rm -f "$LIST"' EXIT

# Tracked files plus new files that .gitignore does not exclude, so the gate
# sees the change you are about to commit. Before the first commit nothing is
# tracked, and outside a git work tree git lists nothing, so both cases fall
# back to the files on disk.
repo_files() {
  if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    && [ -n "$(git -C "$ROOT" ls-files)" ]; then
    git -C "$ROOT" -c core.quotePath=false ls-files --cached --others --exclude-standard
  else
    (cd "$ROOT" && find . -path ./.git -prune -o -type f -print | sed 's|^\./||')
  fi
}

# Runs one check, then prints its verdict line and the indented check output.
run_step() {
  local number="$1" label="$2" out
  shift 2
  if out="$("$@" 2>&1)"; then
    echo "[$number] PASS: $label"
  else
    echo "[$number] FAIL: $label"
    FAILED=$((FAILED + 1))
  fi
  if [ -n "$out" ]; then
    printf '%s\n' "$out" | sed 's/^/    /'
  fi
}

if ! repo_files >"$LIST" || [ ! -s "$LIST" ]; then
  echo "verify: FAILED: no files to check under $ROOT"
  exit 1
fi

run_step 1 "JSON files parse and plugin.json is complete" \
  python3 - "$ROOT" "$LIST" <<'PY'
import json, os, sys
root, listing = sys.argv[1], sys.argv[2]
files = [line.strip() for line in open(listing, encoding="utf-8") if line.strip()]
bad = parsed = 0
for rel in files:
    path = os.path.join(root, rel)
    if not rel.endswith(".json") or not os.path.isfile(path):
        continue
    try:
        with open(path, encoding="utf-8") as handle:
            json.load(handle)
        parsed += 1
    except Exception as exc:
        print(f"{rel}: invalid JSON: {exc}")
        bad += 1
print(f"{parsed} JSON file(s) parsed")
manifest = ".claude-plugin/plugin.json"
try:
    with open(os.path.join(root, manifest), encoding="utf-8") as handle:
        data = json.load(handle)
except FileNotFoundError:
    print(f"{manifest} is missing")
    sys.exit(1)
except Exception:
    sys.exit(1)  # the parse error is reported above
if not isinstance(data, dict):
    print(f"{manifest} is not a JSON object")
    sys.exit(1)
for key in ("name", "version", "description", "skills"):
    if not data.get(key):
        print(f"{manifest} has no '{key}'")
        bad += 1
skills = data.get("skills") or []
for entry in [skills] if isinstance(skills, str) else skills:
    if not os.path.exists(os.path.normpath(os.path.join(root, str(entry)))):
        print(f"{manifest}: skills path '{entry}' does not exist")
        bad += 1
sys.exit(1 if bad else 0)
PY

run_step 2 "SKILL.md frontmatter: name, description, naming and length rules" \
  python3 - "$ROOT" "$LIST" <<'PY'
import os, re, sys
root, listing = sys.argv[1], sys.argv[2]
try:
    import yaml

    def parse(text):
        return yaml.safe_load(text)
except ImportError:
    # Top level keys only, so the gate never depends on a pip install.
    def parse(text):
        data = {}
        for line in text.splitlines():
            if not line or line[0] in " \t#" or ":" not in line:
                continue
            key, _, value = line.partition(":")
            data[key.strip()] = value.strip().strip("'\"")
        return data
kebab = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
fence = re.compile(r"---\r?\n(.*?)\r?\n---[ \t]*(?:\r?\n|\Z)", re.S)
files = [line.strip() for line in open(listing, encoding="utf-8") if line.strip()]
skills = [rel for rel in files if os.path.basename(rel) == "SKILL.md"
          and os.path.isfile(os.path.join(root, rel))]
if not skills:
    print("no SKILL.md found")
    sys.exit(1)
bad = 0
for rel in sorted(skills):
    problems = []
    text = open(os.path.join(root, rel), encoding="utf-8").read()
    match = fence.match(text)
    data = None
    if not match:
        problems.append("missing or unclosed YAML frontmatter")
    else:
        try:
            data = parse(match.group(1))
        except Exception as exc:
            problems.append(f"invalid frontmatter YAML: {exc}")
        else:
            if not isinstance(data, dict):
                problems.append("frontmatter is empty or not a mapping")
                data = None
    if data is not None:
        name, desc = data.get("name"), data.get("description")
        for key, value in (("name", name), ("description", desc)):
            if not isinstance(value, str) or not value.strip():
                problems.append(f"frontmatter has no '{key}'")
        folder = os.path.basename(os.path.dirname(os.path.join(root, rel)))
        if isinstance(name, str) and name.strip():
            if not kebab.match(name) or len(name) > 64:
                problems.append(f"name '{name}' is not kebab-case of 64 characters or fewer")
            if name != folder:
                problems.append(f"name '{name}' does not match its directory '{folder}'")
        if isinstance(desc, str):
            if len(desc) > 1024:
                problems.append(f"description has {len(desc)} characters, the limit is 1024")
            if "<" in desc or ">" in desc:
                problems.append("description contains an angle bracket")
    for problem in problems:
        print(f"{rel}: {problem}")
    if problems:
        bad += 1
    else:
        print(f"{rel}: OK, description {len(desc)} characters")
sys.exit(1 if bad else 0)
PY

run_step 3 "dash ban: no em dash or en dash in md, sh, json, yml, yaml" \
  python3 - "$ROOT" "$LIST" <<'PY'
import os, sys
root, listing = sys.argv[1], sys.argv[2]
files = [line.strip() for line in open(listing, encoding="utf-8") if line.strip()]
bad = scanned = 0
for rel in files:
    path = os.path.join(root, rel)
    if not rel.endswith((".md", ".sh", ".json", ".yml", ".yaml")) or not os.path.isfile(path):
        continue
    scanned += 1
    with open(path, encoding="utf-8", errors="replace") as handle:
        for number, line in enumerate(handle, 1):
            for char, name in ((chr(0x2014), "em dash"), (chr(0x2013), "en dash")):
                if char in line:
                    print(f"{rel}:{number}: {name}")
                    bad += 1
print(f"{scanned} file(s) scanned, {bad} offending line(s)")
sys.exit(1 if bad or not scanned else 0)
PY

run_step 4 "CHANGELOG.md has an entry for the plugin.json version" \
  python3 - "$ROOT" <<'PY'
import json, os, re, sys
root = sys.argv[1]
try:
    with open(os.path.join(root, ".claude-plugin", "plugin.json"), encoding="utf-8") as handle:
        version = json.load(handle)["version"]
    with open(os.path.join(root, "CHANGELOG.md"), encoding="utf-8") as handle:
        changelog = handle.read()
except Exception as exc:
    print(f"cannot read the version or the changelog: {exc}")
    sys.exit(1)
if not re.search(rf"^## \[{re.escape(str(version))}\]", changelog, re.M):
    print(f"CHANGELOG.md has no '## [{version}]' entry")
    sys.exit(1)
print(f"CHANGELOG.md documents {version}")
PY

validate_plugin() {
  (cd "$ROOT" && claude plugin validate --strict . </dev/null)
}
if command -v claude >/dev/null 2>&1; then
  run_step 5 "claude plugin validate --strict ." validate_plugin
else
  echo "[5] SKIP: claude plugin validate (the claude CLI is not on PATH)"
fi

run_shellcheck() {
  local scripts=()
  mapfile -t scripts < <(grep -E '\.sh$' "$LIST" || true)
  if [ "${#scripts[@]}" -eq 0 ]; then
    echo "no shell scripts found"
    return 0
  fi
  (cd "$ROOT" && shellcheck "${scripts[@]}") || return 1
  echo "${#scripts[@]} script(s) clean: ${scripts[*]}"
}
if command -v shellcheck >/dev/null 2>&1; then
  run_step 6 "shellcheck" run_shellcheck
else
  echo "[6] SKIP: shellcheck (not installed)"
fi

if [ "$FAILED" -gt 0 ]; then
  echo "verify: FAILED ($FAILED step(s))"
  exit 1
fi
echo "verify: OK"
