# prompts

**Purpose:** Agent prompt templates for autonomous infrastructure implementation

## Contents

- `initializer_prompt.md` - Session 1 prompt (planning & feature extraction)
- `coding_prompt.md` - Sessions 2+ prompt (autonomous feature implementation)

## Usage

These prompts are loaded by the autonomous agent runner:

```bash
# Run initializer agent (Session 1)
cd scripts
python3 agent.py initializer

# Run coding agent (Sessions 2+)
python3 agent.py coding 10
```

The `prompts.py` module loads these files:
- `get_initializer_prompt()` - Returns initializer_prompt.md content
- `get_coding_prompt()` - Returns coding_prompt.md content

## Two-Agent Pattern

### Initializer Agent (Session 1)
- Parses app_spec.txt
- Generates feature_list.json
- Initializes tracking files
- Sets up infrastructure for coding sessions

### Coding Agent (Sessions 2+)
- Reads feature_list.json
- Implements features autonomously
- Updates tracking files
- Commits work to git
- Loops until all features complete

## Related Documentation

- [Project README](../README.md)
- [Autonomous Implementation Guide](../autonomous-workflow-guide-7f-infrastructure.md)
- [CLAUDE.md](../CLAUDE.md)

---

**Last Updated:** 2026-02-25
