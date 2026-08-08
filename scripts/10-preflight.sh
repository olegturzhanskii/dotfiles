#!/bin/sh
#
# NOTE:
# Check that this machine can be set up, and that setting it up would not disturb anything already here.
#
# Changes nothing.
#
# If this fails, no later stage has run.

set -eu

REPOSITORY="${REPOSITORY:-$(cd "$(dirname "$0")/.." && pwd)}"

. "$REPOSITORY/scripts/common.sh"

problems=0

if [ "$(uname -s)" = "Darwin" ]; then
    ok "macOS $(sw_vers -productVersion)"
else
    fail "this repository supports macOS only; this is $(uname -s)"

    problems=$((problems + 1))
fi

if [ "$(uname -m)" = "arm64" ]; then
    ok "Apple Silicon"
else
    fail "this repository supports Apple Silicon only; this is $(uname -m)"

    problems=$((problems + 1))
fi

if xcode-select --print-path >/dev/null 2>&1; then
    ok "Xcode Command Line Tools"
else
    fail "Xcode Command Line Tools are missing; install them and run this again:"

    printf '        xcode-select --install\n'

    problems=$((problems + 1))
fi

# NOTE:
# Homebrew is not installed for you: it asks for your password and changes directories outside this repository.
if command -v brew >/dev/null 2>&1; then
    ok "Homebrew at $(brew --prefix)"
else
    fail "Homebrew is missing; install it from https://brew.sh and run this again"

    problems=$((problems + 1))
fi

if command -v stow >/dev/null 2>&1; then
    ok "GNU Stow $(stow --version | head -n 1 | awk '{print $NF}')"

    # NOTE:
    # Simulating the deployment is the only reliable way to learn whether a file is in the way before anything is
    # written.
    conflicts="$(
        stow --dir="$REPOSITORY" --no-folding --simulate --target="$HOME" $PACKAGES 2>&1 |
            grep -i 'conflict\|not owned' || true
    )"

    if [ -z "$conflicts" ]; then
        ok "no conflicts with existing files in $HOME"
    else
        fail "linking the configuration would conflict with files you already have:"

        printf '%s\n' "$conflicts" | sed 's/^/        /'

        printf '        Move or remove them first. Nothing here overwrites your files.\n'

        problems=$((problems + 1))
    fi
else
    note "GNU Stow is missing; it is in Brewfile and installs in the next stage"
fi

printf '\n'

if [ "$problems" -ne 0 ]; then
    printf 'Preflight failed. Nothing was changed.\n'

    exit 1
fi

printf 'Preflight passed.\n'
