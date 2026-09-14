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
alacritty_application="/Applications/Alacritty.app"

alacritty_resources="$alacritty_application/Contents/Resources"

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
# The app also carries its own command and manual pages, and nothing outside it points at them.
#
# .zprofile already puts ~/.local/bin on PATH, and man searches the share/man beside every bin directory on PATH, so
# linking into those two is all `alacritty` and `man alacritty` need.
#
# Links rather than copies, so replacing the app with a newer one updates both.
alacritty_executable="$alacritty_application/Contents/MacOS/alacritty"

if [ -x "$alacritty_executable" ]; then
    mkdir -p "$HOME/.local/bin"

    ln -fns "$alacritty_executable" "$HOME/.local/bin/alacritty"

    pages=0

    for page in "$alacritty_resources"/*.[1-9].gz; do
        if [ ! -f "$page" ]; then
            continue
        fi

        name="$(basename "$page")"

        section="${name%.gz}"

        section_directory="$HOME/.local/share/man/man${section##*.}"

        mkdir -p "$section_directory"

        ln -fns "$page" "$section_directory/$name"

        pages=$((pages + 1))
    done

    ok "linked the alacritty command into ~/.local/bin and $pages manual pages into ~/.local/share/man"
else
    note "Alacritty is not installed; skipping its command and manual pages"
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
