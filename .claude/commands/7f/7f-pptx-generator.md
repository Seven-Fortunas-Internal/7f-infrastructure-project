# 7f-pptx-generator

**Seven Fortunas Custom Skill** - Generate PowerPoint presentations from markdown

---

## Metadata

```yaml
source_bmad_skill: bmad-bmm-document-project
adapted_by: Seven Fortunas Infrastructure Team
version: 1.0.0
created: 2026-02-17
integration: Second Brain (Outputs/)
```

---

## Purpose

Convert markdown documents or structured content into professional PowerPoint presentations following Seven Fortunas design templates.

---

## Usage

```bash
/7f-pptx-generator <input-file.md> [--template <template-name>] [--output <filename>]
```

**Arguments:**
- `<input-file.md>`: Path to markdown file (required)
- `--template`: Design template (default: seven-fortunas-standard)
- `--output`: Output filename (default: derived from input)

---

## Workflow

### 1. Parse Input Markdown

- Read markdown file
- Extract frontmatter (title, author, date)
- Parse heading hierarchy (# = slide title, ## = section, content = bullets)
- Identify images, tables, code blocks

### 2. Apply Template

**Available Templates:**
- `seven-fortunas-standard`: Default corporate template
- `seven-fortunas-technical`: Technical documentation template
- `seven-fortunas-executive`: Executive summary template

**Template Elements:**
- Title slide with branding
- Section dividers
- Content slides (bullet points, images, tables)
- Footer with Seven Fortunas logo

### 3. Generate PPTX

- Use python-pptx library
- Convert markdown headings to slides
- Format bullet points and lists
- Insert images and tables
- Apply consistent styling

### 4. Save Output

Save to:
```
~/seven-fortunas-workspace/seven-fortunas-brain/Outputs/Presentations/[filename].pptx
```

### 5. Verification

- Validate PPTX file created
- Check file size (warn if >50MB)
- Verify all content sections converted
- Display slide count

---

## Conversion Rules

**Markdown to PPTX Mapping:**
```
# Heading 1         → Title Slide
## Heading 2        → Section Divider
### Heading 3       → Content Slide Title
- Bullet           → Bullet Point
![image]()         → Embedded Image
| table |          → Formatted Table
```python        → Code Block (monospace)
> Quote            → Callout Box
```

---

## Error Handling

**Input Errors:**
- File not found: Display error, suggest correct path
- Invalid markdown: Attempt to parse, warn about issues
- Missing frontmatter: Use filename as title

**Processing Errors:**
- Image not found: Skip image, log warning
- Table too wide: Scale to fit or split across slides
- Code block too long: Truncate with "..." indicator

**Output Errors:**
- Directory doesn't exist: Create automatically
- File already exists: Prompt for overwrite confirmation
- Disk space low: Warn before generation

---

## Integration Points

- **Second Brain:** Sources content from any Brain section
- **BMAD Library:** Follows documentation patterns
- **Templates:** Uses Seven Fortunas design system

---

## Example Usage

```bash
# Basic usage
/7f-pptx-generator ~/docs/architecture-overview.md

# With template selection
/7f-pptx-generator ~/docs/security-audit.md --template seven-fortunas-technical

# Custom output name
/7f-pptx-generator ~/docs/roadmap.md --output Q1-2026-Roadmap
```

---

## Dependencies

- BMAD Library (FR-3.1) ✅
- Second Brain Structure (FR-2.1) ✅
- python-pptx library
- Seven Fortunas design templates

---

## Notes

This skill automates presentation creation from markdown, maintaining Seven Fortunas branding and design standards. It's particularly useful for converting documentation, PRDs, and technical specs into stakeholder presentations.
