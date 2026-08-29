#!/usr/bin/env bash
# reserve-npm-packages.sh
#
# Reserves npm package names under the @rescript-tauri/ scope by publishing a
# placeholder version (0.0.0-reserved) for each. This is a prerequisite for
# configuring npm Trusted Publishing: the npm registry only allows trusted
# publisher configuration on existing packages (see issue npm/cli#8544).
#
# Usage:
#   bash tools/reserve-npm-packages.sh
#
# Prerequisites:
#   - You are logged in to npm (`npm login`) with 2FA configured.
#   - You own the @rescript-tauri organization on npm.
#   - The 2FA OTP code will be prompted for each publish (9 times total).
#
# Behavior:
#   - For each target package, checks if it already exists on npm. If so,
#     skips it (idempotent re-run safe).
#   - Otherwise, creates a minimal package.json + README.md in a temporary
#     directory and runs `npm publish --tag reserved`.
#   - @rescript-tauri/core is intentionally excluded (already reserved on
#     2026-05-08, see steering 20260508-007).
#
# Reference:
#   - .steering/archive/20260508-007-npm-scope-reservation/report.md
#   - .steering/archive/20260512-003-bulk-package-reservation-tooling/

set -euo pipefail

SCOPE="@rescript-tauri"
PACKAGES=(
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

WORKDIR="$(mktemp -d -t rt-reserve-XXXXXX)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "Working directory: $WORKDIR"
echo "Logged in as: $(npm whoami)"
echo

for pkg in "${PACKAGES[@]}"; do
  full_name="${SCOPE}/${pkg}"
  echo "=== ${full_name} ==="

  if npm view "$full_name" version >/dev/null 2>&1; then
    existing_version="$(npm view "$full_name" version 2>/dev/null || echo unknown)"
    echo "  ⚠ already exists (version=${existing_version}) — skipping"
    continue
  fi

  pkg_dir="${WORKDIR}/${pkg}"
  mkdir -p "$pkg_dir"

  cat > "${pkg_dir}/package.json" <<JSON
{
  "name": "${full_name}",
  "version": "0.0.0-reserved",
  "description": "Reserved name. The actual package will be published at the Phase 2 release. See https://github.com/Nagatatz/rescript-tauri",
  "license": "MIT",
  "homepage": "https://github.com/Nagatatz/rescript-tauri",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/Nagatatz/rescript-tauri.git"
  },
  "publishConfig": {
    "access": "public"
  }
}
JSON

  cat > "${pkg_dir}/README.md" <<MD
# ${full_name} (reserved)

This is a name reservation. The actual package will be published at the Phase 2
release of [rescript-tauri](https://github.com/Nagatatz/rescript-tauri).
MD

  (
    cd "$pkg_dir"
    npm publish --tag reserved
  )
  echo "  ✓ published ${full_name}@0.0.0-reserved"
done

echo
echo "All target packages processed. Verification:"
for pkg in "${PACKAGES[@]}"; do
  full_name="${SCOPE}/${pkg}"
  version="$(npm view "$full_name" version 2>/dev/null || echo MISSING)"
  printf "  %-44s %s\n" "$full_name" "$version"
done

echo
echo "Next step: configure Trusted Publishers with tools/setup-trusted-publishers.sh"
