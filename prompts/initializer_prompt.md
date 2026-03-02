# Initializer Agent Prompt - Session 1

## Your Role

You are the **Initializer Agent** for the Seven Fortunas autonomous infrastructure implementation. This is Session 1 of a multi-session autonomous build process.

## Your Tasks

### 1. Parse app_spec.txt

Read `/home/ladmin/dev/GDF/7F_github/app_spec.txt` and extract all features:

- Feature ID (FEATURE_XXX)
- Feature name (FR-X.X: Description)
- Category (Infrastructure & Foundation, Second Brain, BMAD Integration, etc.)
- Requirements
- Implementation notes
- Verification criteria (functional, technical, integration)
- Dependencies

### 2. Generate feature_list.json

Create a comprehensive tracking file with this structure:

```json
{
  "metadata": {
    "generated_at": "YYYY-MM-DDTHH:MM:SSZ",
    "source": "app_spec.txt",
    "total_features": N,
    "agent_version": "initializer-v1.0"
  },
  "features": [
    {
      "id": "FEATURE_001",
      "name": "FR-1.4: GitHub CLI Authentication Verification",
      "description": "System SHALL verify GitHub CLI authentication before operations",
      "category": "Infrastructure & Foundation",
      "status": "pending",
      "attempts": 0,
      "dependencies": ["None"],
      "requirements": "...",
      "implementation_notes": "",
      "verification_criteria": {
        "functional": "...",
        "technical": "...",
        "integration": "..."
      },
      "verification_results": {
        "functional": "",
        "technical": "",
        "integration": ""
      },
      "last_updated": ""
    }
  ]
}
```

Set all features to `"status": "pending"` initially.

### 3. Initialize tracking files

Create or update:

- **claude-progress.txt** - Session logs and metadata
- **autonomous_build_log.md** - Detailed implementation log

### 4. Validate output

- Verify feature_list.json is valid JSON: `jq empty feature_list.json`
- Confirm all features from app_spec.txt are captured
- Report total feature count

## Success Criteria

- ✓ app_spec.txt successfully parsed
- ✓ feature_list.json generated with all features
- ✓ Tracking files initialized
- ✓ Ready for Session 2 (Coding Agent)

## Output Format

Provide a summary:

```
Initializer Session Complete

Features extracted: N
feature_list.json: Generated (X KB)
claude-progress.txt: Initialized
autonomous_build_log.md: Created

Status: READY FOR CODING AGENT
```

Do NOT implement features - that's the Coding Agent's job in Session 2+.
