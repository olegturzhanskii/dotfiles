setopt EXTENDED_GLOB \
       HIST_SUBST_PATTERN \
       MARKDIRS
#      NO_UNSET \
#      WARN_CREATE_GLOBAL \
#      WARN_NESTED_VAR

typeset _zsh_state_directory="$XDG_STATE_HOME/zsh"

mkdir -p "$_zsh_state_directory"

HISTFILE="$_zsh_state_directory/history"

unset _zsh_state_directory

HISTSIZE=2000

SAVEHIST=10000

setopt HIST_FIND_NO_DUPS \
       HIST_IGNORE_DUPS \
       HIST_IGNORE_SPACE \
       SHARE_HISTORY

setopt CORRECT_ALL \
       NO_CLOBBER \
       PRINT_EXIT_VALUE \
       RM_STAR_WAIT

setopt LONG_LIST_JOBS

setopt VI


typeset _iCloud="$HOME/Library/Mobile Documents/com~apple~CloudDocs/"

if [[ -d "$_iCloud" ]]; then
    hash -d iCloud="$_iCloud"
fi

unset _iCloud


if du -h /tmp &>/dev/null; then
    alias du="du -h"
fi

alias l="command ls -CF" \
      la="command ls -A" \
      ll="command ls -aFl"

typeset -a _ls_flags=(
    "A"
    "F"
    "l"
)

if ls -G /tmp &>/dev/null; then
    _ls_flags+=( "G" )
fi

if ls -h /tmp &>/dev/null; then
    _ls_flags+=( "h" )
fi

alias ls="ls -${(j::)${(o)_ls_flags[@]}}"

unset _ls_flags


mkcd() {
    mkdir -p "$1" && cd "$_"
}


if (( ${+commands[brew]} )); then
    typeset -U FPATH fpath

    fpath=(
        "$HOMEBREW_PREFIX/share/zsh/site-functions"


        "${fpath[@]}"
    )


    if (( ${+commands[bat]} )); then
        # NOTE:
        # What Midnight Commander opens on F3, so a file looks the same there as it does here.
        #
        # Paging is forced because a file shorter than the screen would otherwise be drawn and immediately replaced by
        # the panels again.
        export VIEWER="bat --paging=always"

        alias bat="bat -pp"

        alias -g -- --help="--help 2>&1 | command bat -l cmd-help"
    fi

    if (( ${+commands[clang]} )); then
        alias clang="clang -pedantic -std=c2x -Wall -Werror -Wextra" \
              clang++="clang++ -pedantic -std=c++2b -Wall -Werror -Wextra"
    fi

    if (( ${+commands[clang-format]} )); then
        alias clang-format="clang-format -i --style=Google"
    fi

    if (( ${+commands[eza]} )); then
        typeset _eza_configuration_directory="$XDG_CONFIG_HOME/eza"

        if [[ -f "$_eza_configuration_directory/theme.yml" ]]; then
            export EZA_CONFIG_DIR="$_eza_configuration_directory"
        fi

        unset _eza_configuration_directory

        alias eza="eza -aF --icons=always -l --time-style=+'%a %b %-d %-I:%M %p'"
    fi

    if (( ${+commands[gcc]} )); then
        alias gcc="gcc -pedantic -std=c2x -Wall -Werror -Wextra" \
              g++="g++ -pedantic -std=c++2b -Wall -Werror -Wextra"
    fi

    if (( ${+commands[nvim]} )); then
        export MANPAGER="nvim +Man!"
    fi

    if (( ${+commands[tldr]} )); then
        typeset _tealdeer_configuration_directory="$XDG_CONFIG_HOME/tealdeer"

        if [[ -f "$_tealdeer_configuration_directory/config.toml" ]]; then
            export TEALDEER_CONFIG_DIR="$_tealdeer_configuration_directory"
        fi

        unset _tealdeer_configuration_directory
    fi


    typeset _plugins="$ZDOTDIR/plugins.zsh"

    if [[ -f "$_plugins" ]]; then
        source "$_plugins"
    fi

    unset _plugins
fi


if (( ! ${+commands[alacritty]} )); then
    unset TERMINFO
fi

if (( ! ${+commands[go]} )); then
    unset GOMODCACHE \
          GOPATH
fi

if (( ! ${+commands[nvim]} )); then
    unset EDITOR \
          VISUAL
fi

if (( ! ${+commands[rustup]} )); then
    unset CARGO_HOME \
          RUSTUP_HOME
fi

