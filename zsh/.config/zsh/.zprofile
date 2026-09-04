typeset _brew="/opt/homebrew/bin/brew"

if [[ -x "$_brew" ]]; then
    eval "$($_brew shellenv)"
fi

unset _brew


typeset -U PATH path

path=(
    "$HOMEBREW_PREFIX/opt/llvm/bin"(N-/)


    "$GOPATH/bin"(N-/)

    "$HOME/.local/bin"(N-/)

    "$CARGO_HOME/bin"(N-/)


    "${path[@]}"
)

