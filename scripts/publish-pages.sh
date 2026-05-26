#!/usr/bin/env bash

set -euo pipefail

if [[ "${1:-}" == "--" ]]; then
  shift
fi

builder="${1:-mkdocs}"
docs_base="${2:-/tech/}"
ref="${3:-$(git rev-parse --abbrev-ref HEAD)}"
workflow_file="${WORKFLOW_FILE:-pages.yml}"

usage() {
  echo "Usage: bash scripts/publish-pages.sh [mkdocs|vitepress|auto] [/tech/|/] [branch]"
  echo "Example: bash scripts/publish-pages.sh mkdocs /tech/ develop"
}

normalize_base() {
  local raw="${1:-}"
  raw="$(echo "$raw" | xargs)"
  if [[ -z "$raw" || "$raw" == "/" ]]; then
    echo "/"
    return
  fi
  raw="${raw#/}"
  raw="${raw%/}"
  echo "/${raw}/"
}

case "$builder" in
  mkdocs|vitepress|auto)
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    echo "Invalid builder: $builder" >&2
    usage
    exit 1
    ;;
esac

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install it first: https://cli.github.com/" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Please login first: gh auth login" >&2
  exit 1
fi

docs_base="$(normalize_base "$docs_base")"

echo "Triggering workflow..."
echo "  workflow: $workflow_file"
echo "  ref:      $ref"
echo "  builder:  $builder"
echo "  base:     $docs_base"

gh workflow run "$workflow_file" \
  --ref "$ref" \
  -f builder="$builder" \
  -f docs_base="$docs_base"

echo "Workflow triggered."
echo "Check latest runs: gh run list --workflow $workflow_file --limit 5"
