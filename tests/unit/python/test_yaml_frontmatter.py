"""
P2-001 — YAML Frontmatter Validation (FR-2.2)

Validates that every content .md file in second-brain-core/ (excluding README.md)
has the required frontmatter fields with valid values per:
  standards/yaml-frontmatter-schema.md

Required fields: title, type, description, version, last_updated, status

Type allowed values: index, domain-index, guide, reference, standard, runbook,
                     playbook, template, concept
Status allowed values: active, draft, deprecated, archived
Version format: semantic (X.Y.Z)
Last_updated format: ISO date (YYYY-MM-DD)
"""

import re
from pathlib import Path

import pytest
import yaml

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BRAIN_REPO = Path("/home/ladmin/seven-fortunas-workspace/seven-fortunas-brain")
CONTENT_DIR = BRAIN_REPO / "second-brain-core"

REQUIRED_FIELDS = ["title", "type", "description", "version", "last_updated", "status"]

VALID_TYPES = {
    "index", "domain-index", "guide", "reference", "standard",
    "runbook", "playbook", "template", "concept",
}

VALID_STATUS = {"active", "draft", "deprecated", "archived"}

SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")
ISO_DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def parse_frontmatter(path: Path):
    """
    Extract YAML frontmatter block from a markdown file.
    Returns parsed dict, or None if no valid frontmatter block found.
    """
    content = path.read_text(encoding="utf-8", errors="replace")
    if not content.startswith("---"):
        return None

    lines = content.split("\n")
    end_idx = None
    for i, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            end_idx = i
            break

    if end_idx is None:
        return None

    frontmatter_text = "\n".join(lines[1:end_idx])
    return yaml.safe_load(frontmatter_text)


def get_content_files():
    """Return all .md content files (exclude README.md) under second-brain-core/."""
    if not CONTENT_DIR.exists():
        return []
    return sorted(
        f for f in CONTENT_DIR.rglob("*.md")
        if f.name.lower() != "readme.md"
    )


# Discover files at collection time
_content_files = get_content_files()
_content_file_ids = [str(f.relative_to(BRAIN_REPO)) for f in _content_files]


# ---------------------------------------------------------------------------
# TestSchemaConstants
# ---------------------------------------------------------------------------

class TestSchemaConstants:

    def test_required_fields_list(self):
        assert set(REQUIRED_FIELDS) == {
            "title", "type", "description", "version", "last_updated", "status"
        }

    def test_valid_types_non_empty(self):
        assert len(VALID_TYPES) >= 6

    def test_valid_status_values(self):
        assert "active" in VALID_STATUS
        assert "draft" in VALID_STATUS
        assert "deprecated" in VALID_STATUS

    def test_semver_regex_matches_valid(self):
        assert SEMVER_RE.match("1.0.0")
        assert SEMVER_RE.match("2.3.14")
        assert not SEMVER_RE.match("1.0")
        assert not SEMVER_RE.match("v1.0.0")


# ---------------------------------------------------------------------------
# TestBrainRepo
# ---------------------------------------------------------------------------

@pytest.mark.skipif(not BRAIN_REPO.exists(), reason="brain repo not available (CI environment)")
class TestBrainRepo:

    def test_brain_repo_exists(self):
        assert BRAIN_REPO.exists(), f"Brain repo not found at {BRAIN_REPO}"

    def test_content_dir_exists(self):
        assert CONTENT_DIR.exists(), f"second-brain-core/ not found at {CONTENT_DIR}"

    def test_minimum_content_files_found(self):
        files = get_content_files()
        assert len(files) >= 10, (
            f"Expected at least 10 content files, found {len(files)}"
        )


# ---------------------------------------------------------------------------
# TestParseFrontmatter (unit tests for the helper itself)
# ---------------------------------------------------------------------------

class TestParseFrontmatter:

    def test_valid_frontmatter_parsed(self, tmp_path):
        md = tmp_path / "doc.md"
        md.write_text("---\ntitle: Test\nstatus: active\n---\n# Body\n")
        result = parse_frontmatter(md)
        assert result == {"title": "Test", "status": "active"}

    def test_no_frontmatter_returns_none(self, tmp_path):
        md = tmp_path / "doc.md"
        md.write_text("# Just a heading\nNo frontmatter here.\n")
        result = parse_frontmatter(md)
        assert result is None

    def test_unclosed_frontmatter_returns_none(self, tmp_path):
        md = tmp_path / "doc.md"
        md.write_text("---\ntitle: Test\n# No closing ---\n")
        result = parse_frontmatter(md)
        assert result is None


# ---------------------------------------------------------------------------
# TestPerFileValidation — parametrized over all discovered content files
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("file_path", _content_files, ids=_content_file_ids)
class TestPerFileValidation:

    def test_has_valid_frontmatter(self, file_path):
        """File must open with a valid YAML frontmatter block."""
        fm = parse_frontmatter(file_path)
        assert fm is not None, (
            f"{file_path.name}: no valid frontmatter block found (must start with ---)"
        )

    def test_all_required_fields_present(self, file_path):
        """All 6 required fields must be present."""
        fm = parse_frontmatter(file_path)
        assert fm is not None, f"{file_path.name}: no frontmatter"
        missing = [f for f in REQUIRED_FIELDS if f not in fm]
        assert not missing, (
            f"{file_path.name}: missing required fields: {missing}"
        )

    def test_all_required_fields_non_empty(self, file_path):
        """All required fields must have non-empty string values."""
        fm = parse_frontmatter(file_path)
        assert fm is not None, f"{file_path.name}: no frontmatter"
        empty = [f for f in REQUIRED_FIELDS if not str(fm.get(f, "")).strip()]
        assert not empty, (
            f"{file_path.name}: empty required fields: {empty}"
        )

    def test_type_is_valid(self, file_path):
        """type must be one of the allowed document type values."""
        fm = parse_frontmatter(file_path)
        assert fm is not None, f"{file_path.name}: no frontmatter"
        doc_type = fm.get("type", "")
        assert doc_type in VALID_TYPES, (
            f"{file_path.name}: type='{doc_type}' not in {sorted(VALID_TYPES)}"
        )

    def test_status_is_valid(self, file_path):
        """status must be one of: active, draft, deprecated, archived."""
        fm = parse_frontmatter(file_path)
        assert fm is not None, f"{file_path.name}: no frontmatter"
        status = fm.get("status", "")
        assert status in VALID_STATUS, (
            f"{file_path.name}: status='{status}' not in {sorted(VALID_STATUS)}"
        )

    def test_version_is_semver(self, file_path):
        """version must be semantic version format X.Y.Z."""
        fm = parse_frontmatter(file_path)
        assert fm is not None, f"{file_path.name}: no frontmatter"
        version = str(fm.get("version", ""))
        assert SEMVER_RE.match(version), (
            f"{file_path.name}: version='{version}' not in X.Y.Z format"
        )

    def test_last_updated_is_iso_date(self, file_path):
        """last_updated must be ISO date format YYYY-MM-DD."""
        fm = parse_frontmatter(file_path)
        assert fm is not None, f"{file_path.name}: no frontmatter"
        date = str(fm.get("last_updated", ""))
        assert ISO_DATE_RE.match(date), (
            f"{file_path.name}: last_updated='{date}' not in YYYY-MM-DD format"
        )
