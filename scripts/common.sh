#!/bin/sh
#
# NOTE:
# Shared definitions.
#
# Sourced by the other scripts, not run on its own.
#
# The packages this repository deploys, in load order: the terminal first, then the tools it hosts, then the shell
# that ties them together.
#
# This list is the single place that decides what gets linked into $HOME.
#
# shellcheck disable=SC2034  # read by every script that sources this file
PACKAGES="alacritty tmux nvim bat eza git htop mc starship task tealdeer zsh"

ok() {
    printf '  ok    %s\n' "$*"
}

note() {
    printf '  note  %s\n' "$*"
}

fail() {
    printf '  FAIL  %s\n' "$*"
}
