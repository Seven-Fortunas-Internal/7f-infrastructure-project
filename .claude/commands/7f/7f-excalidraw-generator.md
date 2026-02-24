# 7f-excalidraw-generator

**Seven Fortunas Custom Skill** - Generate Excalidraw diagrams from text descriptions

---

## Metadata

```yaml
source_bmad_skill: bmad-bmm-architecture
adapted_by: Seven Fortunas Infrastructure Team
version: 1.0.0
created: 2026-02-17
integration: Second Brain (Concepts/Diagrams/)
```

---

## Purpose

Convert text descriptions or structured data into Excalidraw diagram files (.excalidraw) for architecture diagrams, flowcharts, system designs, and concept visualizations.

---

## Usage

```bash
/7f-excalidraw-generator <diagram-type> [--description "text"] [--file <input.md>]
```

**Arguments:**
- `<diagram-type>`: Type of diagram (architecture, flowchart, sequence, entity-relationship, network)
- `--description`: Inline text description
- `--file`: Path to markdown file with diagram description

**Diagram Types:**
- `architecture`: System architecture diagrams
- `flowchart`: Process and decision flow diagrams
- `sequence`: Sequence diagrams for interactions
- `entity-relationship`: Database ERD diagrams
- `network`: Network topology diagrams

---

## Workflow

### 1. Parse Input Description

**Text Input:**
```
/7f-excalidraw-generator architecture --description "
API Gateway connects to:
- Auth Service (port 8080)
- User Service (port 8081)
- Data Service (port 8082)
All services connect to PostgreSQL database
"
```

**File Input:**
```markdown
# System Architecture

## Components
- API Gateway (entry point)
- Auth Service (authentication/authorization)
- User Service (user management)
- Data Service (data access layer)

## Connections
- API Gateway → Auth Service
- API Gateway → User Service
- API Gateway → Data Service
- All services → PostgreSQL
```

### 2. Generate Excalidraw Elements

Create JSON structure with:
- **Rectangles** for components/services
- **Arrows** for connections/data flow
- **Text labels** for annotations
- **Grouping** for logical sections
- **Color coding** by layer (green=frontend, blue=backend, red=database)

### 3. Apply Seven Fortunas Style

**Visual Standards:**
- Font: Virgil (handwritten style)
- Colors: Seven Fortunas palette
- Stroke width: 2px for primary, 1px for secondary
- Spacing: 100px between components
- Alignment: Grid-based layout

### 4. Save Output

Save to:
```
~/seven-fortunas-workspace/seven-fortunas-brain/Concepts/Diagrams/[diagram-name].excalidraw
```

Also save PNG export:
```
~/seven-fortunas-workspace/seven-fortunas-brain/Concepts/Diagrams/[diagram-name].png
```

### 5. Verification

- Validate Excalidraw JSON structure
- Check all elements have valid coordinates
- Ensure arrows connect properly
- Verify file saved successfully

---

## Diagram Templates

**Architecture Template:**
```
[Load Balancer]
     ↓
[API Gateway]
     ↓
[Service Layer] ← [Cache]
     ↓
[Database]
```

**Flowchart Template:**
```
[Start] → [Decision] → [Process] → [End]
              ↓
           [Alt Path]
```

**Sequence Template:**
```
Client → API → Service → Database
  ←─────────────────────────────
```

---

## Error Handling

**Input Errors:**
- Invalid diagram type: Show available types
- No description provided: Prompt for input
- File not found: Display error with path

**Processing Errors:**
- Too many components (>50): Warn about complexity
- Circular dependencies: Detect and highlight
- Invalid connections: Skip and log warning

**Output Errors:**
- Directory doesn't exist: Create automatically
- File already exists: Append timestamp to filename
- PNG export fails: Save .excalidraw only, log warning

---

## Integration Points

- **Second Brain:** Saves to Concepts/Diagrams/
- **BMAD Library:** Follows architecture documentation patterns
- **Excalidraw:** Generates native .excalidraw format

---

## Example Usage

```bash
# Simple architecture diagram
/7f-excalidraw-generator architecture --description "3-tier web app: frontend, API, database"

# From markdown file
/7f-excalidraw-generator flowchart --file ~/docs/deployment-process.md

# Network topology
/7f-excalidraw-generator network --description "VPC with public/private subnets, NAT gateway, internet gateway"
```

---

## Dependencies

- BMAD Library (FR-3.1) ✅
- Second Brain Structure (FR-2.1) ✅
- Excalidraw CLI (for PNG export)
- Node.js (for Excalidraw processing)

---

## Notes

This skill bridges the gap between text-based architecture documentation and visual diagrams. It follows Excalidraw's hand-drawn aesthetic while maintaining Seven Fortunas branding standards. Particularly useful for rapid prototyping and iteration on system designs.
