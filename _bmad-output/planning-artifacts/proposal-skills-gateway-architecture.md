---
title: "Proposal: Seven Fortunas Skills Gateway Architecture"
type: proposal
status: draft
version: 1.0.0
date: 2026-03-02
author: Jorge (VP AI-SecOps) with Claude Code
related-masters:
  - master-requirements.md
  - master-architecture.md
adoption-track: BMAD planning process → new FRs/NFRs + ADR
---

# Proposal: Seven Fortunas Skills Gateway Architecture

## Executive Summary

This proposal defines how the **Seven Fortunas Brain repo becomes the enterprise skills
gateway** — a vetted, governed hub through which all AI agent skills (BMAD, Claude skills,
skills.sh, custom 7F skills) flow before reaching any project repo. It also introduces an
**automated skill vetting workflow** that makes the governance role scaleable without
requiring deep manual review for every skill.

The proposal was developed during a working session (2026-03-02) triggered by integrating
the `coleam00/excalidraw-diagram-skill` (a Claude Code skill with built-in visual
validation). Excalidraw serves as the **test case** for the entire system.

**Scope of change:** Brain repo structure, `skills-registry.yaml` schema, a new interactive
installer, a new `7f-skill-vetter` skill, and a thin addition to all 7F project repos.

**What does NOT change:** BMAD's `_bmad/` structure, existing skill stubs, the CLAUDE.md
inheritance chain.

---

## Problem Statement

### Current state

1. **Skills are siloed** — each project installs skills independently, with no consistent
   process, no vetting, and no enterprise-wide propagation mechanism.

2. **`skills-registry.yaml` is incomplete** — it catalogs 7 custom stubs but has no concept
   of skill type (BMAD vs. Claude vs. community), source location, configuration schema,
   or vetting status.

3. **`create-bmad-symlinks.sh` is directionally wrong** — it copies stubs *from*
   `7F_github` *into* the Brain. The Brain should be the source, not a destination.

4. **Custom skill stubs are monolithic** — implementation logic lives inside the stub
   itself (e.g., `7f-excalidraw-generator.md` is 150+ lines of inline workflow). There is
   no separation between "how to invoke" and "how to do the work."

5. **No support for Claude skills** — the ecosystem around Claude Code skills is growing
   (skills.sh has 82,000+ skills, individual repos like coleam00's excalidraw skill). The
   current architecture only supports BMAD-pattern skills.

6. **Configuration is not portable** — skills like excalidraw require project-specific
   settings (color palette, output directory). There is no mechanism for projects to
   express overrides that travel with the repo.

### The gap this creates

A new team member clones a Seven Fortunas project repo and has no guided path to set up the
skills the project depends on. A project lead who wants to adopt a new community skill has
no standardized evaluation or deployment path. When a skill is updated or improved, there is
no propagation mechanism — projects fall out of sync silently.

---

## Proposed Architecture

### Principle: Brain as skills gateway, not skills warehouse

The Brain hosts **only what is unique to Seven Fortunas** (custom skills). For all other
skills (BMAD, skills.sh, GitHub repos), the Brain acts as a **vetting and cataloging
layer** — it records what has been approved, from which source, at which version, and why
it was approved. The installer reads the Brain's registry and knows exactly how to obtain
and configure each skill.

```
External Sources                    Brain (Gateway)               Projects
─────────────────                   ────────────────              ────────
BMAD Library       ──vet+catalog──▶  skills-registry.yaml   ──▶  .claude/
skills.sh (82K+)   ──vet+catalog──▶  (authoritative catalog)      required-skills.yaml
GitHub repos       ──vet+catalog──▶                               setup.sh
                                                                  skills-config/
Custom 7F skills   ────hosted──────▶ _sf-skills/
(7F-specific only)                   (implementations)
```

### Three skill categories

| Category | Hosted in Brain? | Registry entry | Installer action |
|----------|-----------------|----------------|-----------------|
| **Custom (7F)** | Yes (`_sf-skills/`) | Full entry w/ config schema | Copy from Brain `_sf-skills/` |
| **BMAD Library** | Yes (`_bmad/`) | Entry pointing to `_bmad/` path | Copy from Brain `_bmad/` |
| **Community** (skills.sh, GitHub) | No | Entry w/ source URL + vetting notes | `npx skillsadd` or `git clone` |

### The propagation model

```
1. Team identifies a useful community skill (skills.sh, GitHub, etc.)
         │
2. 7f-skill-vetter runs automated + interactive review
         │
3. Vetting report generated → Jorge approves → registry entry added to Brain
         │                         ← propagation gate (nothing passes without this)
4. Projects run: setup.sh --update
         │
5. Installer reads updated registry → new skill available to install
         │
6. User prompted: machine level or project level? + config parameters
         │
7. Skill installed, config written, project ready to use skill
```

The Brain registry is the gate. The installer refuses to install any skill not present in
the registry. All updates to community skills must pass through re-vetting before propagating.

### Configuration layering (project overrides)

Skills with configurable parameters (colors, output directories, API endpoints) use a
three-layer override chain:

```
Priority 1 (highest): {project}/.claude/skills-config/{skill}/config.toml  ← committed to git
Priority 2:           ~/.claude/skills-config/{skill}/config.toml           ← user-level (rare)
Priority 3 (lowest):  {skill_dir}/config-defaults.toml                     ← skill defaults
```

Each skill ships a `config-defaults.toml` that defines the schema (what is configurable,
default values, human-readable prompts). The project override file contains only the values
that differ. This file is small, committed to git, and travels with the repo — so every
team member who installs the skill gets the correct project configuration automatically.

**Excalidraw example:**

`_sf-skills/excalidraw-diagram/config-defaults.toml`:
```toml
[skill]
name = "excalidraw-diagram"
version = "1.0.0"
description = "Generate professional Excalidraw diagrams with visual validation"

[setup]
commands = [
  "cd {skill_dir}/references && uv sync",
  "cd {skill_dir}/references && uv run playwright install chromium"
]

[[config]]
key = "color_primary"
description = "Primary brand color (hex)"
default = "#3b82f6"
prompt = "Primary color"

[[config]]
key = "color_success"
description = "Success/completion state color (hex)"
default = "#a7f3d0"
prompt = "Success color"

[[config]]
key = "color_accent"
description = "Accent/decision color (hex)"
default = "#fef3c7"
prompt = "Accent color"

[[config]]
key = "color_ai"
description = "AI/LLM component color (hex)"
default = "#ddd6fe"
prompt = "AI component color"

[[config]]
key = "output_dir"
description = "Default output directory for generated diagrams"
default = "docs/diagrams"
prompt = "Diagram output directory"
```

`7f-infrastructure-project/.claude/skills-config/excalidraw-diagram/config.toml`
(committed, only overrides):
```toml
color_primary = "#1E3A8A"
color_success = "#10B981"
color_accent  = "#F59E0B"
```

---

## Component Specifications

### 1. `_sf-skills/` directory (Brain repo)

New directory alongside `_bmad/`. Hosts full implementations of 7F custom skills — not
just stubs.

```
_sf-skills/
└── excalidraw-diagram/           ← First skill (test case)
    ├── SKILL.md                  ← Full methodology (migrated + expanded from current stub)
    ├── config-defaults.toml      ← Configuration schema
    └── references/
        ├── color-palette.md      ← 7F brand colors (default overrides of coleam00 defaults)
        ├── element-templates.md  ← Copy-paste JSON templates
        ├── json-schema.md        ← Excalidraw format reference
        ├── render_excalidraw.py  ← Playwright-based PNG renderer
        └── render_template.html  ← Headless render template
```

**Why this is separate from `_bmad/`:** `_bmad/` is a BMAD library copy — mixing 7F
custom content into it makes BMAD updates harder to manage. `_sf-skills/` follows the same
structural pattern as `_bmad/` but is owned entirely by Seven Fortunas.

### 2. `skills-registry.yaml` v2.0 (Brain repo)

The registry evolves from a flat skills list to a typed, governed catalog. Full schema:

```yaml
version: 2.0.0
last_updated: YYYY-MM-DD

skill_sources:
  - id: sf-custom
    type: custom
    description: "Skills hosted in Brain _sf-skills/ — 7F-specific implementations"
  - id: bmad
    type: library
    url: https://github.com/bmad-method/bmad-method
    description: "BMAD method library — managed in _bmad/"
  - id: skills-sh
    type: package-manager
    url: https://skills.sh
    install_template: "npx skillsadd {owner}/{repo}"
    description: "Open Agent Skills Ecosystem (82K+ skills)"
  - id: github
    type: git-repo
    install_template: "git clone {url} {target_dir}"
    description: "Individual GitHub skill repositories"

skills:
  - name: excalidraw-diagram
    display_name: "Excalidraw Diagram Generator"
    type: custom
    source: sf-custom
    path: _sf-skills/excalidraw-diagram
    config_schema: _sf-skills/excalidraw-diagram/config-defaults.toml
    stub_path: .claude/commands/7f/7f-excalidraw-generator.md
    adapted_from:
      source: github
      url: https://github.com/coleam00/excalidraw-diagram-skill
      upstream_version: "main"
    vetted: true
    vetted_by: "Jorge (VP AI-SecOps)"
    vetted_date: YYYY-MM-DD
    vetting_report: _sf-skills/excalidraw-diagram/vetting-report.md
    version: "1.0.0"
    requires:
      - uv >= 0.10.0
      - playwright >= 1.40.0
      - chromium (via playwright install chromium)

governance:
  gate: registry           # installer rejects skills not in this registry
  vetting_required: true
  vetter_role: "Jorge (VP AI-SecOps) or delegated reviewer"
  automated_pre_screen: 7f-skill-vetter  # skill that does initial analysis
  update_policy: "Re-vet required for major version bumps of community skills"
```

### 3. `scripts/install-skills.py` (Brain repo)

An interactive, self-bootstrapping Python installer. Uses PEP 723 inline dependencies
so it requires only `uv` to run — no pre-installed packages.

```python
#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml", "rich", "tomli"]
# ///
```

**Behavior:**

```
$ uv run install-skills.py /path/to/project

═══════════════════════════════════════════════════════════════
 Seven Fortunas Skills Installer  v1.0
 Project: 7f-infrastructure-project
═══════════════════════════════════════════════════════════════

 Reading .claude/required-skills.yaml...
 Found 2 required skills.
 Checking Brain registry (skills-registry.yaml)...

────────────────────────────────────────────────────────────────
 Skill 1/2: excalidraw-diagram  v1.0.0
 Generate professional Excalidraw diagrams with visual validation
 Source: 7F Custom (_sf-skills/excalidraw-diagram)
────────────────────────────────────────────────────────────────

 Not installed. Install at:
   [M] Machine level  ~/.claude/skills/excalidraw-diagram/
       Available across ALL projects on this machine (recommended)
   [P] Project level  .claude/skills/excalidraw-diagram/
       This project only

 Choice [M/p]: M

 Configure excalidraw-diagram?
 (Press Enter to accept defaults shown in brackets)

   Primary color    [#3b82f6]:  #1E3A8A
   Success color    [#a7f3d0]:  #10B981
   Accent color     [#fef3c7]:  #F59E0B
   AI color         [#ddd6fe]:  (Enter — keep default)
   Output directory [docs/diagrams]: (Enter — keep default)

 ✓ Config saved → .claude/skills-config/excalidraw-diagram/config.toml
 ✓ Copying skill from Brain...
 ✓ Running setup commands (uv sync, playwright install)...
 ✓ excalidraw-diagram installed at machine level

────────────────────────────────────────────────────────────────
 Skill 2/2: ...

═══════════════════════════════════════════════════════════════
 ✅  All skills installed. You're ready to work.
 Run: /7f-excalidraw-generator --description "..."
═══════════════════════════════════════════════════════════════
```

**Flags:**
- `install-skills.py {project}` — install all required skills
- `install-skills.py {project} --update` — re-run for already-installed skills (pick up
  new versions from updated Brain registry)
- `install-skills.py {project} --list` — show installed vs. available skills
- `install-skills.py {project} --skill excalidraw-diagram` — install a single skill

**Prerequisite checks** (pre-flight, before any install):
- `git` available
- `uv` available (with install hint if missing)
- `gh auth status` succeeds (needed to clone Brain)
- `required-skills.yaml` exists and is valid
- All required skill names exist in Brain registry (fail fast if unknown skill requested)

### 4. `.claude/setup.sh` — per-project bootstrap (each project repo)

A 10-line file committed to each project repo. It downloads the installer from the Brain
and runs it. The installer logic lives only in Brain — the bootstrap is intentionally thin.

```bash
#!/bin/bash
set -e

BRAIN_REPO="Seven-Fortunas-Internal/seven-fortunas-brain"
INSTALLER_PATH="scripts/install-skills.py"
INSTALLER_CACHE="/tmp/sf-brain-installer"

echo "Fetching Seven Fortunas Skills Installer from Brain..."
rm -rf "$INSTALLER_CACHE"
gh repo clone "$BRAIN_REPO" "$INSTALLER_CACHE" -- --depth=1 --quiet

uv run "$INSTALLER_CACHE/$INSTALLER_PATH" "$(pwd)" "$@"
```

Usage after cloning any 7F project:
```bash
git clone Seven-Fortunas-Internal/some-project
cd some-project
.claude/setup.sh             # fresh install
.claude/setup.sh --update    # update installed skills
.claude/setup.sh --list      # inspect state
```

### 5. `.claude/required-skills.yaml` — per-project skill manifest

Committed to each project repo. Declares which skills the project depends on, and
optionally pins versions.

```yaml
# .claude/required-skills.yaml
version: "1.0"
brain_repo: Seven-Fortunas-Internal/seven-fortunas-brain

required_skills:
  - name: excalidraw-diagram
    version: ">=1.0.0"    # semver constraint; "latest" also valid
    install_level: machine # machine | project | prompt (default: prompt)
    notes: "Used for architecture and workflow diagrams"
```

The `install_level` key allows the project maintainer to express a preference, while
`prompt` (the default) always asks the user. This gives teams control without removing
user agency.

### 6. `7f-skill-vetter` — automated vetting skill (new custom skill)

This directly addresses the scalability concern: Jorge reviews initially, but an
automated/interactive skill handles pre-screening so the human review is faster and
more consistent.

**Purpose:** Analyze a candidate skill (any source) and produce a structured vetting report
that feeds directly into the registry.

**Inputs:**
- Skill URL or GitHub repo path
- Intended use case (what project/problem it would solve)

**Process:**
1. Clone/fetch the skill repository
2. Enumerate all files (Python, shell, JS, config)
3. Analyze with Claude across four dimensions:
   - **Security:** Network calls (what, when, to where?), file system writes (scope?),
     secrets handling (any access to credentials?), supply chain (dependency risk)
   - **Applicability:** Does this skill fit 7F's tech stack and use cases?
   - **Quality:** Is behavior documented? Is there a test/render validation loop?
   - **Compatibility:** Claude Code version, dependency versions, OS requirements
4. Present interactive review — show findings category by category, allow reviewer to
   add notes, override assessments, or flag concerns
5. Output a `vetting-report.md` and a proposed registry entry (ready to paste into
   `skills-registry.yaml`)

**Output format:**
```markdown
# Vetting Report: excalidraw-diagram-skill

**Source:** https://github.com/coleam00/excalidraw-diagram-skill
**Vetted:** 2026-03-02
**Vetted by:** Jorge (assisted by 7f-skill-vetter)
**Recommendation:** APPROVE

## Security Assessment
- Network calls: Excalidraw CDN only (esm.sh), used during headless render only
- File system: Writes only to user-specified output path; no temp file persistence
- Secrets handling: None — no API keys, no credentials
- Dependencies: playwright (Microsoft, MIT license), uv (Astral, MIT license)
- Risk level: LOW

## Applicability
- Fits 7F use cases: Architecture diagrams, workflow documentation, planning artifacts
- Tech stack compatible: Python 3.11+, runs on Ubuntu Linux and macOS
- Claude Code integration: Native SKILL.md pattern

## Quality Assessment
- Documentation: Comprehensive (554-line SKILL.md with methodology)
- Visual validation: Built-in Playwright renderer with mandatory review loop
- Customization: Color palette as single override file

## Proposed Registry Entry
[... ready-to-paste YAML ...]
```

**Skill location:** `_sf-skills/skill-vetter/` (it is itself a custom 7F skill)

---

## Impact on Existing Components

### `create-bmad-symlinks.sh` — refactor

**Current behavior:** Copies stubs *from* `7F_github` into Brain (wrong direction).

**Proposed behavior:** Becomes `setup-bmad.sh`, runs at Brain initialization time to
create the skill stubs in `.claude/commands/` from the `_bmad/` definitions. Direction:
`_bmad/` → `.claude/commands/` within the Brain itself. The installer (`install-skills.py`)
handles the project-to-project propagation separately.

This keeps BMAD setup as a one-time Brain initialization step while the new installer
handles skill propagation to other projects.

### `7f-excalidraw-generator.md` stub — refactor

**Current:** 150+ lines of inline workflow logic, hardcodes output path to non-existent
`Concepts/Diagrams/` directory.

**Proposed:** Becomes a ~10-line thin wrapper:

```markdown
# 7f-excalidraw-generator

IT IS CRITICAL THAT YOU READ the full skill implementation at:
@{project-root}/_sf-skills/excalidraw-diagram/SKILL.md
(or if installed at machine level: ~/.claude/skills/excalidraw-diagram/SKILL.md)

Then load the project config overrides from:
@{project-root}/.claude/skills-config/excalidraw-diagram/config.toml (if exists)

Apply those color values when generating diagrams.
Output diagrams to the configured output_dir (default: docs/diagrams/).
```

The skill logic, color references, rendering instructions, and templates all live in
`SKILL.md` and `references/`. The stub is just an entry point.

### `skills-registry.yaml` — schema upgrade

The v1.0 registry (flat list, 7 custom skills) is replaced by the v2.0 schema defined
in the Component Specifications section above. The 7 existing skill entries are migrated
to the new format with vetting status added.

---

## New Requirements to Add to Master Documents

### Proposed new Functional Requirements

**FR-10.x: Skills Gateway (Brain as enterprise skills registry)**

- FR-10.1: Skills Registry — Brain SHALL maintain a typed, governed catalog of all
  approved skills (custom, BMAD, and community) in `skills-registry.yaml` v2.0 format
- FR-10.2: Interactive Skills Installer — Brain SHALL provide an interactive installer
  (`scripts/install-skills.py`) that walks operators through skill installation, including
  machine vs. project level and configuration parameters
- FR-10.3: Per-Project Skill Manifest — Each 7F project repo SHALL include
  `.claude/required-skills.yaml` declaring its skill dependencies and `.claude/setup.sh`
  as the installation entry point
- FR-10.4: Configuration Layering — Skills with configurable parameters SHALL support
  a three-layer override chain (skill defaults → user overrides → project overrides)
  so project-specific settings travel with the repo
- FR-10.5: Skill Propagation — The installer SHALL support `--update` mode that checks
  the Brain registry for newer vetted versions and re-installs changed skills
- FR-10.6: Automated Skill Vetting — Brain SHALL include a `7f-skill-vetter` custom
  skill that analyzes candidate skills across security, applicability, quality, and
  compatibility dimensions and produces a structured vetting report

**FR-10.7: Custom Skills Directory** — Brain SHALL maintain `_sf-skills/` alongside
`_bmad/` as the hosting location for 7F custom skill implementations. Stubs in
`.claude/commands/7f/` SHALL be thin wrappers pointing into `_sf-skills/`.

### Proposed new Non-Functional Requirements

**NFR-11.1: Installer Bootstrap Speed**
- Requirement: `setup.sh` SHALL complete fresh skill installation within 5 minutes per
  skill (excluding one-time dependency installs like chromium)
- Measurement: Time from `setup.sh` invocation to "ready to use" confirmation

**NFR-11.2: Skill Registry Integrity**
- Requirement: The installer SHALL refuse to install any skill not present in the Brain
  registry with `vetted: true`. Unknown skills MUST fail with a clear error directing
  the operator to the vetting process.
- Measurement: Zero non-registry skills installable via the standard process

**NFR-11.3: Configuration Portability**
- Requirement: A project's `.claude/skills-config/` directory, when committed to git,
  SHALL be sufficient for any operator to reproduce the exact skill configuration by
  running `setup.sh`
- Measurement: Two operators on different machines achieve identical skill behavior after
  running `setup.sh` on the same repo

### Proposed new Architecture Decision Record

**ADR-007: Brain as Skills Gateway**
- Decision: The Brain repo is the single authority for which AI agent skills are approved
  for use across Seven Fortunas projects. It hosts custom skills in `_sf-skills/` and
  maintains a vetted catalog of community skills in `skills-registry.yaml`. It does not
  host community skills directly — it records vetted metadata and source references.
- Alternatives considered: (a) Separate `sf-skills` repo — split authority, extra
  maintenance; (b) Per-project skill installation — inconsistent, no vetting gate;
  (c) Full BMAD-only skills — excludes growing Claude skills ecosystem (skills.sh, GitHub)
- Rationale: Brain is already the knowledge and governance hub. Centralizing skills
  governance here aligns with its mission. The gateway model supports any skill source
  without hosting it all.
- Consequences: All new skills must be registered before use; Jorge (or delegated
  reviewer, assisted by `7f-skill-vetter`) reviews all community skills; Brain repo
  gains new responsibilities and must be treated as a critical infrastructure dependency.

---

## Implementation Plan

### Phase 1 — Brain repo foundations (test with excalidraw)

| Task | Description | Owner |
|------|-------------|-------|
| 1.1 | Create `_sf-skills/excalidraw-diagram/` with SKILL.md, config-defaults.toml, references/ | Engineer |
| 1.2 | Upgrade `skills-registry.yaml` to v2.0 schema | Engineer |
| 1.3 | Refactor `7f-excalidraw-generator.md` stub → thin wrapper | Engineer |
| 1.4 | Refactor `create-bmad-symlinks.sh` → `setup-bmad.sh` (correct direction) | Engineer |
| 1.5 | Build `scripts/install-skills.py` (PEP 723, uv-based) | Engineer |
| 1.6 | Add `.claude/setup.sh` bootstrap to Brain repo | Engineer |
| 1.7 | Add `second-brain-core/skills/skills-gateway.md` with proper frontmatter | Engineer |
| 1.8 | Add vetting report for excalidraw to `_sf-skills/excalidraw-diagram/` | Jorge |

### Phase 2 — Test propagation

| Task | Description | Owner |
|------|-------------|-------|
| 2.1 | Add `.claude/required-skills.yaml` to `7F_github` | Engineer |
| 2.2 | Add `.claude/setup.sh` to `7F_github` | Engineer |
| 2.3 | End-to-end test on this machine (clone → setup.sh → verify render works) | Jorge |
| 2.4 | Test `--update` flag with a simulated registry change | Jorge |
| 2.5 | Document any gaps found during testing | Jorge |

### Phase 3 — Vetting skill

| Task | Description | Owner |
|------|-------------|-------|
| 3.1 | Design `7f-skill-vetter` SKILL.md (analysis prompts, output format) | Jorge + Engineer |
| 3.2 | Implement as `_sf-skills/skill-vetter/` | Engineer |
| 3.3 | Register it in `skills-registry.yaml` (it is itself a custom skill) | Engineer |
| 3.4 | Pilot test: run vetter on 2-3 skills.sh candidates | Jorge |

### Phase 4 — Template it

| Task | Description | Owner |
|------|-------------|-------|
| 4.1 | Update `7f-repo-template` skill to include `setup.sh` + `required-skills.yaml` | Engineer |
| 4.2 | Update repo template README: "After cloning, run `.claude/setup.sh`" | Engineer |
| 4.3 | Migrate `7f-excalidraw-generator` stubs in other repos to new pattern | Engineer |
| 4.4 | Backfill `required-skills.yaml` to existing repos that use skills | Jorge + Engineer |

---

## Open Questions for Adoption Process

1. **Vetting delegation** — Should `7f-skill-vetter` output be sufficient for junior
   team members to approve community skills, or does Jorge always do final approval?
   Recommendation: automated pre-screen handles WHAT to look at; human approves.

2. **Skills.sh scope** — The Brain registry is opt-in (team evaluates and registers only
   the skills they need). Should there be a formal process for requesting that a skills.sh
   skill be added to the registry? Or is it informal (use it → vet it → register it)?

3. **Version pinning policy** — Should `required-skills.yaml` pin to a specific registry
   snapshot (commit SHA) or always pull latest-approved from Brain? Pinning is safer;
   latest-approved is more current. Recommend: default to latest-approved, with opt-in
   pinning for stability-critical projects.

4. **`_bmad/` update cadence** — BMAD is a full copy (not a submodule) in Brain. The same
   governance question applies: when does `_bmad/` get updated, and does that update
   propagate through the installer? Recommend: treat `_bmad/` updates as a separate
   process from `_sf-skills/` updates — BMAD has its own release notes.

5. **Skill conflict resolution** — If a project's `required-skills.yaml` requests a skill
   version that conflicts with an already-installed version at machine level, what happens?
   Recommend: project-level install wins for that project; machine-level unchanged.

---

## Success Criteria

The proposal is successfully implemented when:

- [ ] A new team member can clone any 7F project repo and run `.claude/setup.sh` to get
      all required skills installed with correct project configuration in under 10 minutes
- [ ] A new community skill can be adopted by updating Brain's `skills-registry.yaml`
      alone — no per-project changes required (projects get it on next `--update`)
- [ ] The `7f-skill-vetter` skill produces a complete vetting report in under 5 minutes
      for any GitHub-hosted Claude skill
- [ ] `7f-excalidraw-generator` produces a rendered PNG diagram with 7F brand colors
      using the new `_sf-skills/` implementation (not the current inline stub)
- [ ] Zero existing functionality is broken: all current BMAD skill stubs, custom 7F skill
      stubs, and Second Brain search continue to work

---

## Appendix: Technology Notes

### Why uv (PEP 723) for the installer

The installer uses `uv run` with inline PEP 723 script metadata. This means:
- Only `uv` needs to be pre-installed (single binary, no sudo, installs in ~1 second)
- The installer's Python dependencies (`rich`, `pyyaml`, `tomli`) are fetched and cached
  automatically on first run — no manual `pip install`, no virtual environment setup
- Cross-platform: works on macOS, Linux, and Windows (where `uv` is available)
- The installer file is self-contained and readable — no build step

`uv` was installed on this machine at: `/home/ladmin/.local/bin/uv` (v0.10.7)

### Why TOML for config-defaults

Python 3.11+ includes `tomllib` as a standard library module — no installation required.
TOML is well-typed, human-readable, and simpler than YAML for flat configuration.
The installer reads `config-defaults.toml` using only the Python standard library.

### skills.sh integration

skills.sh is "The Open Agent Skills Ecosystem" — a package manager/marketplace with
82,000+ Claude Code compatible skills. Install command: `npx skillsadd <owner>/<repo>`.
Supports 20+ AI coding tools. The Brain registry records skills.sh entries with their
`owner/repo` reference; the installer calls `npx skillsadd` for those entries rather
than cloning directly.

---

**Document version:** 1.0.0
**Status:** Draft — pending adoption process review
**Next step:** Process through BMAD planning workflow → add approved FRs/NFRs to
`master-requirements.md` and ADR to `master-architecture.md` → create implementation
stories
