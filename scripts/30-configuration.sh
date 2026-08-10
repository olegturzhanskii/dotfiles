#!/bin/sh
#
# NOTE:
# Link this repository configuration into your home directory.
#
# --no-folding is the flag that matters.
#
# Without it Stow links whole directories, so ~/.config/zsh would be this repository and every cache or session file a
# tool writes there would land in the working tree.
#
# With it the directories are real and only files are linked, so generated state has nowhere to land here.
#
# The cost is that a newly added file needs this script run again.
#
# Stow refuses to overwrite, so an existing file stops this rather than being replaced.

set -eu

REPOSITORY="${REPOSITORY:-$(cd "$(dirname "$0")/.." && pwd)}"

. "$REPOSITORY/scripts/common.sh"

printf '  linking: %s\n\n' "$PACKAGES"

# shellcheck disable=SC2086  # word splitting is intended: one argument per package
stow --dir="$REPOSITORY" --no-folding --target="$HOME" --verbose $PACKAGES

printf '\n'

ok "configuration linked into $HOME"

note "to undo: stow --delete --dir=$REPOSITORY --target=$HOME $PACKAGES"
