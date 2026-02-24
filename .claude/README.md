# Claude Code Configuration

## Purpose

Claude Code agent configuration, skills, and commands.

## Contents

### Commands (Skills)
- `commands/7f-dashboard-curator.md` - Dashboard data source configurator
- `commands/bmad-*.md` - BMAD workflow skills (80+ skills)

### Skills

Skills are invoked in Claude Code with `/skill-name` syntax.

#### Custom Seven Fortunas Skills

**Dashboard Curator** (`/7f-dashboard-curator`)
- Add/remove RSS feeds
- Add/remove Reddit subreddits
- Add/remove YouTube channels
- Configure update frequency
- View audit log

#### BMAD Skills

80+ BMAD (Business Method Architecture for Developers) skills for planning, architecture, and development workflows.

See: `.claude/commands/bmad-*.md` for full list

## Configuration Files

- `.claude_settings.json` - Claude Code settings
- `keybindings.json` - Custom keyboard shortcuts (if configured)

## Usage

### Invoke a Skill

In Claude Code, type:
```
/7f-dashboard-curator
```

### List Available Skills

In Claude Code:
```
/help
```

Or list files:
```bash
ls .claude/commands/
```

## Adding New Skills

1. Create skill file: `.claude/commands/skill-name.md`
2. Follow skill template structure (see existing skills)
3. Document usage and examples
4. Skill automatically available after creation

## Skill Template

```markdown
# Skill Name

**Purpose:** [Brief description]

## Usage

[How to invoke and use the skill]

## Implementation

[What the skill does step-by-step]
```

---

**Owner:** Seven Fortunas Development Team
**Related:** [docs/readme-templates.md](../docs/readme-templates.md)
