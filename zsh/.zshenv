export XDG_CACHE_HOME="$HOME/.cache" \
       XDG_CONFIG_HOME="$HOME/.config" \
       XDG_DATA_HOME="$HOME/.local/share" \
       XDG_STATE_HOME="$HOME/.local/state"


export ZDOTDIR="$XDG_CONFIG_HOME/zsh"


export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"


export TERMINFO="$XDG_DATA_HOME/terminfo"

export GOMODCACHE="$XDG_CACHE_HOME/go/mod" \
       GOPATH="$XDG_DATA_HOME/go"

# NOTE:
# Two statements, because export expands all of its arguments before it assigns any of them: grouped with the line
# above, VISUAL="$EDITOR" would read the incoming environment and export an empty string.
export EDITOR="nvim"

export VISUAL="$EDITOR"

export CARGO_HOME="$XDG_DATA_HOME/cargo" \
       RUSTUP_HOME="$XDG_DATA_HOME/rustup"

