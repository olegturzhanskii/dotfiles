#!/bin/sh
#
# NOTE:
# Generate the state the configuration needs but does not contain.
#
# These are things a machine builds for itself.
#
# They are neither secret nor configuration, so they are reproduced here rather than stored.
#
# Ordered the way the environment comes up: the terminal has to describe itself before anything drawn inside it works.
#
# Every step is safe to run again.

set -eu

REPOSITORY="${REPOSITORY:-$(cd "$(dirname "$0")/.." && pwd)}"

. "$REPOSITORY/scripts/common.sh"

# NOTE:
# macOS does not know what an "alacritty" terminal is, and Alacritty ships the answer inside its own bundle.
#
# .zshenv points TERMINFO at this directory, so linking the entries in is what makes TERM=alacritty resolve.
alacritty_resources="/Applications/Alacritty.app/Contents/Resources"

terminfo_directory="${XDG_DATA_HOME:-$HOME/.local/share}/terminfo"

if [ -d "$alacritty_resources" ]; then
    linked=0

    for source_directory in "$alacritty_resources"/[0-9a-f][0-9a-f]; do
        if [ ! -d "$source_directory" ]; then
            continue
        fi

        target_directory="$terminfo_directory/$(basename "$source_directory")"

        mkdir -p "$target_directory"

        for entry in "$source_directory"/*; do
            ln -fns "$entry" "$target_directory/$(basename "$entry")"

            linked=$((linked + 1))
        done
    done

    ok "linked $linked terminfo entries into $terminfo_directory"
else
    note "Alacritty is not installed; skipping terminfo"
fi

# NOTE:
# tpm comes from Homebrew, but the plugins tmux.conf asks for are cloned on first use.
#
# This does what prefix + I does, without needing you to be there.
tpm_install="$(brew --prefix)/opt/tpm/share/tpm/bin/install_plugins"

if [ -x "$tpm_install" ] && command -v tmux >/dev/null 2>&1; then
    if tmux new-session -d -s dotfiles-bootstrap 2>/dev/null; then
        if "$tpm_install" >/dev/null 2>&1; then
            ok "tmux plugins installed"
        else
            note "tpm could not install plugins; open tmux and press prefix + I"
        fi

        tmux kill-session -t dotfiles-bootstrap 2>/dev/null || true
    else
        note "could not start a temporary tmux server; use prefix + I instead"
    fi
else
    note "tpm or tmux is missing; skipping tmux plugins"
fi

# NOTE:
# tealdeer refreshes this cache on its own schedule.
#
# Priming it here only saves the first tldr command from waiting.
if command -v tldr >/dev/null 2>&1; then
    if tldr --update >/dev/null 2>&1; then
        ok "tldr page cache primed"
    else
        note "could not fetch tldr pages; tealdeer will retry on its own"
    fi
fi

printf '\n'

note "zsh plugins install on your first shell"

note "Neovim plugins install on your first nvim, at the lockfile versions"
