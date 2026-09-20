#!/usr/bin/env bash
# Cloud Agent install for the azure-docs content repository.
#
# This repo is published by Microsoft's hosted OpenPublishing / docfx_v3 build
# service, which cannot be run locally. The meaningful local development flow is
# Markdown authoring validation, driven by the repo's .markdownlint.json config
# (the same rules the Microsoft "Docs Authoring Pack" applies). This installs the
# markdownlint-cli2 linter used for that flow.
set -euo pipefail

MARKDOWNLINT_CLI2_VERSION="0.23.3"

# npm's global prefix is misconfigured to "/" in this base image, so derive the
# active (user-writable, already-on-PATH) Node prefix from the npm binary itself.
NPM_BIN="$(command -v npm)"
NODE_PREFIX="$(dirname "$(dirname "$NPM_BIN")")"

echo "Using Node prefix: $NODE_PREFIX"

if markdownlint-cli2 --version 2>/dev/null | grep -q "v${MARKDOWNLINT_CLI2_VERSION}"; then
  echo "markdownlint-cli2 v${MARKDOWNLINT_CLI2_VERSION} already installed; skipping."
else
  echo "Installing markdownlint-cli2@${MARKDOWNLINT_CLI2_VERSION}..."
  npm install -g --prefix "$NODE_PREFIX" "markdownlint-cli2@${MARKDOWNLINT_CLI2_VERSION}"
fi

echo "Installed: $(markdownlint-cli2 --version 2>/dev/null | head -1)"
