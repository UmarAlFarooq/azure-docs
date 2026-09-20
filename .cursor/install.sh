#!/usr/bin/env bash
# Cloud Agent install for the azure-docs content repository.
#
# This repo is published by Microsoft's hosted OpenPublishing / docfx_v3 build
# service, which cannot be run locally. The meaningful local development flow is
# Markdown authoring validation, driven by the repo's .markdownlint.json config
# (the same rules the Microsoft "Docs Authoring Pack" applies). This installs the
# markdownlint-cli2 linter used for that flow.
#
# The linter is installed into /usr/local (a stable system prefix that is always
# on PATH and captured by the environment snapshot). npm's global prefix in the
# base image points at "/" and the Node toolchain lives under an nvm directory,
# so we install with an explicit --prefix using absolute node/npm paths via sudo.
set -euo pipefail

MARKDOWNLINT_CLI2_VERSION="0.23.3"
INSTALL_PREFIX="/usr/local"
BIN="${INSTALL_PREFIX}/bin/markdownlint-cli2"

if [ -x "$BIN" ] && "$BIN" --version 2>/dev/null | grep -q "v${MARKDOWNLINT_CLI2_VERSION}"; then
  echo "markdownlint-cli2 v${MARKDOWNLINT_CLI2_VERSION} already installed at ${BIN}; skipping."
else
  NODE_BIN="$(command -v node)"
  NPM_CLI="$(readlink -f "$(command -v npm)")"
  echo "Installing markdownlint-cli2@${MARKDOWNLINT_CLI2_VERSION} into ${INSTALL_PREFIX} ..."
  echo "  node: ${NODE_BIN}"
  echo "  npm : ${NPM_CLI}"
  sudo "$NODE_BIN" "$NPM_CLI" install -g --prefix "$INSTALL_PREFIX" \
    "markdownlint-cli2@${MARKDOWNLINT_CLI2_VERSION}"
fi

echo "Installed: $("$BIN" --version 2>/dev/null | head -1)"
