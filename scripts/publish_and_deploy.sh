#!/usr/bin/env bash
set -euo pipefail

COMMIT_MESSAGE="${*:-}"
BRANCH="${BRANCH:-$(git branch --show-current)}"

if [ -z "$COMMIT_MESSAGE" ]; then
    echo "Usage: scripts/publish_and_deploy.sh \"Commit message\"" >&2
    exit 1
fi

if [ -z "$BRANCH" ]; then
    BRANCH="main"
fi

if [ -f ".env" ] && ! git check-ignore -q ".env"; then
    echo ".env exists but is not ignored by Git. Refusing to continue." >&2
    exit 1
fi

if [ -d "scripts" ]; then
    while IFS= read -r -d "" script; do
        bash -n "$script"
    done < <(find scripts -type f -name "*.sh" -print0)
fi

git add -A

if git diff --cached --quiet; then
    echo "No local changes to commit."
else
    git commit -m "$COMMIT_MESSAGE"
fi

git push origin "$BRANCH"
BRANCH="$BRANCH" scripts/deploy_to_vps.sh
