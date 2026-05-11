#!/usr/bin/env bash
# setup-trusted-publishers.sh
#
# Configures GitHub Actions Trusted Publishers for each @rescript-tauri/*
# package on the npm registry using the `npm trust` CLI (npm v11.10.0+).
# This must be run AFTER each package exists on npm — either as a real
# release or as a 0.0.0-reserved placeholder (see tools/reserve-npm-packages.sh).
#
# Usage:
#   bash tools/setup-trusted-publishers.sh
#
#   # Skip @rescript-tauri/core (if it was already configured via Web UI):
#   SKIP_CORE=true bash tools/setup-trusted-publishers.sh
#
# Prerequisites:
#   - npm CLI version 11.10.0 or higher (`npm --version`).
#   - You are logged in to npm with 2FA enabled.
#   - You have write permission on every target package.
#   - Each target package already exists on the npm registry.
#
# Behavior:
#   - Configures GitHub Actions as the trusted publisher for each package
#     with:
#       repo:     Nagatatz/rescript-tauri
#       workflow: release.yml
#       env:      (none)
#   - If a package already has trusted publisher configuration, the call may
#     fail with an "already configured" message; the script logs the message
#     and continues with the next package.
#
# Reference:
#   - https://docs.npmjs.com/cli/v11/commands/npm-trust
#   - .steering/20260512-002-npm-trusted-publishing/
#   - .steering/20260512-003-bulk-package-reservation-tooling/

set -euo pipefail

SCOPE="@rescript-tauri"
REPO="Nagatatz/rescript-tauri"
WORKFLOW="release.yml"
SKIP_CORE="${SKIP_CORE:-false}"

ALL_PACKAGES=(
  "core"
  "schema"
  "plugin-fs"
  "plugin-dialog"
  "plugin-shell"
  "plugin-notification"
  "plugin-log"
  "plugin-os"
  "plugin-clipboard-manager"
  "plugin-http"
)

# Sanity check: must be logged in to npm.
if ! npm whoami >/dev/null 2>&1; then
  echo "ERROR: not logged in to npm. Run 'npm login' first." >&2
  exit 1
fi

# npm CLI version gate. `npm trust` was introduced in 11.10.0.
npm_version="$(npm --version)"
required_major=11
required_minor=10
current_major="${npm_version%%.*}"
remainder="${npm_version#*.}"
current_minor="${remainder%%.*}"
if [ "$current_major" -lt "$required_major" ] \
   || { [ "$current_major" -eq "$required_major" ] && [ "$current_minor" -lt "$required_minor" ]; }; then
  echo "ERROR: npm ${npm_version} is too old. Required: ${required_major}.${required_minor}.0+" >&2
  echo "Upgrade with: npm install -g npm@latest" >&2
  exit 1
fi

echo "npm version: ${npm_version} (OK)"
echo "Logged in as: $(npm whoami)"
echo "Repository:   ${REPO}"
echo "Workflow:     ${WORKFLOW}"
echo "Skip core:    ${SKIP_CORE}"
echo

for pkg in "${ALL_PACKAGES[@]}"; do
  if [ "$pkg" = "core" ] && [ "$SKIP_CORE" = "true" ]; then
    echo "=== ${SCOPE}/${pkg} (skipped via SKIP_CORE=true) ==="
    continue
  fi

  full_name="${SCOPE}/${pkg}"
  echo "=== ${full_name} ==="

  if ! npm view "$full_name" version >/dev/null 2>&1; then
    echo "  ⚠ package not found on npm — run tools/reserve-npm-packages.sh first" >&2
    continue
  fi

  if npm trust github "$full_name" \
       --file "$WORKFLOW" \
       --repo "$REPO" \
       --yes; then
    echo "  ✓ trusted publisher configured for ${full_name}"
  else
    echo "  (already configured or update rejected — re-run 'npm trust list ${full_name}' to inspect)"
  fi
done

echo
echo "Verification — per-package trusted publisher configuration:"
# `npm trust list` (no args) reads the current directory's package.json, which
# in this repo is the unpublished `rescript-tauri-monorepo` root and would 404.
# List each target package explicitly instead.
for pkg in "${ALL_PACKAGES[@]}"; do
  if [ "$pkg" = "core" ] && [ "$SKIP_CORE" = "true" ]; then
    continue
  fi
  full_name="${SCOPE}/${pkg}"
  echo "--- ${full_name} ---"
  npm trust list "$full_name" || echo "  (no trusted publisher configured)"
done
