#!/bin/bash
# Autonomous Implementation - Environment Setup
# Generated: 2026-02-26 | Project: 7F_github
set -e

echo "========================================="
echo "  7F_github Environment Setup"
echo "========================================="

export PROJECT_ROOT="/home/ladmin/dev/GDF/7F_github"
export APP_SPEC_FILE="${PROJECT_ROOT}/app_spec.txt"
export FEATURE_LIST_FILE="${PROJECT_ROOT}/feature_list.json"
export PROGRESS_FILE="${PROJECT_ROOT}/claude-progress.txt"
export BUILD_LOG_FILE="${PROJECT_ROOT}/autonomous_build_log.md"
export OUTPUT_DIR="${PROJECT_ROOT}/outputs"
export LOGS_DIR="${PROJECT_ROOT}/logs"
export SCRIPTS_DIR="${PROJECT_ROOT}/scripts"

echo "Project Root: $PROJECT_ROOT"
echo ""
echo "Checking environment..."

[[ ! -f "$APP_SPEC_FILE" ]]    && echo "❌ app_spec.txt not found"    && exit 1
[[ ! -f "$FEATURE_LIST_FILE" ]] && echo "❌ feature_list.json not found" && exit 1
[[ ! -d "${PROJECT_ROOT}/.git" ]] && echo "❌ Not a Git repository"    && exit 1
! command -v gh  &>/dev/null   && echo "❌ GitHub CLI not found"        && exit 1
! gh auth status &>/dev/null   && echo "❌ GitHub CLI not authenticated" && exit 1
! command -v jq  &>/dev/null   && echo "❌ jq not found"                && exit 1
! command -v python3 &>/dev/null && echo "❌ Python 3 not found"        && exit 1

echo "✓ All prerequisite checks passed"
echo ""

mkdir -p "$OUTPUT_DIR" "$LOGS_DIR" "$SCRIPTS_DIR"
echo "✓ Directories: outputs/ logs/ scripts/"

echo ""
echo "Technology Stack:"
command -v python3 &>/dev/null && echo "✓ Python: $(python3 --version)"
command -v node    &>/dev/null && echo "✓ Node.js: $(node --version)" || echo "⚠️  Node.js not found"
command -v gh      &>/dev/null && echo "✓ GitHub CLI: $(gh --version | head -1)"
command -v jq      &>/dev/null && echo "✓ jq: $(jq --version)"

echo ""
echo "Feature progress:"
jq '[.features[] | .status] | group_by(.) | map({status: .[0], count: length})' "$FEATURE_LIST_FILE"

echo ""
echo "========================================="
echo "  Setup Complete - Ready for Build"
echo "========================================="
