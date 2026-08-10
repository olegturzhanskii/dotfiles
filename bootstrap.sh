#!/bin/sh
#
# NOTE:
# Set this machine up from the configuration in this repository.
#
# Each stage is a separate script in scripts/ and can be run on its own.
#
# Nothing changes until every prerequisite has been checked and confirmed.
#
# Usage:
#   ./bootstrap.sh --dry-run   check and print the plan, change nothing
#   ./bootstrap.sh             check, print the plan, ask, then run it
#   ./bootstrap.sh --yes       the same without asking
#
# Installed software is never upgraded here; see docs/maintenance.md.

set -eu

REPOSITORY="$(cd "$(dirname "$0")" && pwd)"

export REPOSITORY

dry_run=0

assume_yes=0

for argument in "$@"; do
    case "$argument" in
    --dry-run)
        dry_run=1
        ;;

    --yes | -y)
        assume_yes=1
        ;;

    --help | -h)
        awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "$0"

        exit 0
        ;;

    *)
        printf 'bootstrap: unknown argument: %s\n' "$argument" >&2

        printf 'try: ./bootstrap.sh --help\n' >&2

        exit 2
        ;;
    esac
done

printf '==> Checking prerequisites\n'

"$REPOSITORY/scripts/10-preflight.sh"

printf '\n==> Plan\n'

printf '    1. install everything missing from Brewfile\n'

printf '    2. link this repository configuration into your home directory\n'

printf '    3. generate the state that configuration needs\n\n'

printf '    Not done: upgrading installed software, installing the optional\n'

printf '    Brewfiles, touching a file you already have, or any git operation.\n\n'

if [ "$dry_run" -eq 1 ]; then
    printf 'Dry run: nothing was changed.\n'

    exit 0
fi

if [ "$assume_yes" -eq 0 ]; then
    printf 'Proceed? [y/N] '

    read -r reply

    case "$reply" in
    [Yy]*) ;;

    *)
        printf 'Stopped. Nothing was changed.\n'

        exit 0
        ;;
    esac
fi

printf '\n==> Installing tools\n'

"$REPOSITORY/scripts/20-packages.sh"

printf '\n==> Linking configuration\n'

"$REPOSITORY/scripts/30-configuration.sh"

printf '\n==> Generating derived state\n'

"$REPOSITORY/scripts/40-derived-state.sh"

printf '\nDone.\n'

printf 'Open a new terminal, then run ./bin/doctor.\n'

printf 'A few steps still need you; see the README.\n'
