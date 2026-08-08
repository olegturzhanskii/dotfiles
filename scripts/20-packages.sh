#!/bin/sh
#
# NOTE:
# Install the tools the required Brewfile declares.
#
# Homebrew does the work.
#
# The only thing added here is the choice of file: Brewfile.extras, Brewfile.toys and Brewfile.optional are
# deliberately not read, and --no-upgrade keeps installed software exactly as it is.

set -eu

REPOSITORY="${REPOSITORY:-$(cd "$(dirname "$0")/.." && pwd)}"

. "$REPOSITORY/scripts/common.sh"

brew bundle install --file="$REPOSITORY/Brewfile" --no-upgrade

printf '\n'

ok "everything in Brewfile is installed"

note "the optional Brewfiles were not installed; that is deliberate"
