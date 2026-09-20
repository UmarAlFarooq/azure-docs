#!/usr/bin/env bash
# Cloud Agent tooling bootstrap for the azure-docs content repository.
#
# This repo is published by Microsoft's hosted OpenPublishing / docfx_v3 build
# service, which cannot be run locally. The meaningful local development flow is
# Markdown authoring validation, driven by the repo's .markdownlint.json config
# (the same rules the Microsoft "Docs Authoring Pack" applies). This installs the
# markdownlint-cli2 linter used for that flow.
#
# It is invoked from BOTH `install` (bakes the tool for just-in-time agents) and
# `start` (guarantees the tool is present on every boot). The Cloud Agent disk
# snapshot does not reliably persist system-directory installs such as
# /usr/local, and prebuilt boots skip `install`, so running this idempotent
# script at start-time is what guarantees the linter is always available.
#
# The linter is installed into /usr/local (a stable system prefix that is always
# on PATH). npm's global prefix in the base image points at "/" and the Node
# toolchain lives under an nvm directory, so we install with an explicit
# --prefix using absolute node/npm paths via sudo.
set -euo pipefail

MARKDOWNLINT_CLI2_VERSION="0.23.3"
INSTALL_PREFIX="/usr/local"
BIN="${INSTALL_PREFIX}/bin/markdownlint-cli2"

if [ -x "$BIN" ] && "$BIN" --version 2>/dev/null | grep -q "v${MARKDOWNLINT_CLI2_VERSION}"; then
  echo "markdownlint-cli2 v${MARKDOWNLINT_CLI2_VERSION} already installed at ${BIN}; skipping."
  exit 0
fi

NODE_BIN="$(command -v node)"
NPM_CLI="$(readlink -f "$(command -v npm)")"
echo "Installing markdownlint-cli2@${MARKDOWNLINT_CLI2_VERSION} into ${INSTALL_PREFIX} ..."
echo "  node: ${NODE_BIN}"
echo "  npm : ${NPM_CLI}"

# Retry to tolerate transient registry/network hiccups during boot.
attempt=1
until sudo "$NODE_BIN" "$NPM_CLI" install -g --prefix "$INSTALL_PREFIX" \
    "markdownlint-cli2@${MARKDOWNLINT_CLI2_VERSION}"; do
  if [ "$attempt" -ge 3 ]; then
    echo "ERROR: failed to install markdownlint-cli2 after ${attempt} attempts." >&2
    exit 1
  fi
  echo "Install attempt ${attempt} failed; retrying..." >&2
  attempt=$((attempt + 1))
  sleep $((attempt * 4))
done

echo "Installed: $("$BIN" --version 2>/dev/null | head -1)"
