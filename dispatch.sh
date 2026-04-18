#!/usr/bin/env bash
set -euo pipefail

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || {
  echo "error: not a GitHub repo or gh is not authenticated" >&2
  exit 1
}

LAST_TAG=$(git tag --sort=-version:refname | head -n1)

if [[ -z "$LAST_TAG" ]]; then
  echo "No existing tags found. Enter the first version to release:"
else
  echo "Last released tag: $LAST_TAG"
  echo "Enter new version tag (must be higher than $LAST_TAG):"
fi

read -rp "> " VERSION

if [[ -z "$VERSION" ]]; then
  echo "error: version cannot be empty" >&2
  exit 1
fi

if [[ -n "$LAST_TAG" ]]; then
  SORTED=$(printf '%s\n%s\n' "$LAST_TAG" "$VERSION" | sort -V | head -n1)
  if [[ "$SORTED" != "$LAST_TAG" || "$VERSION" == "$LAST_TAG" ]]; then
    echo "error: $VERSION must be greater than the current tag $LAST_TAG" >&2
    exit 1
  fi
fi

echo ""
echo "Triggering release workflow for $VERSION on $REPO..."
gh workflow run release.yml \
  --repo "$REPO" \
  --field version="$VERSION"

echo "Done. Check progress at: https://github.com/$REPO/actions"
