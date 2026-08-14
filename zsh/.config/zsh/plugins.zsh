typeset _zinit="$HOMEBREW_PREFIX/opt/zinit/zinit.zsh"

if [[ -f "$_zinit" ]]; then
    source "$_zinit"

    typeset _zsh_cache_directory="$XDG_CACHE_HOME/zsh"

    mkdir -p "$_zsh_cache_directory"

    ZINIT[COMPINIT_OPTS]="-C -d $_zsh_cache_directory/zcompdump"

    unset _zsh_cache_directory

    autoload -Uz _zinit

    if [[ -v _comps ]]; then
        _comps[zinit]=_zinit
    fi

    zinit \
        depth"1" \
        light-mode \
        lucid for \
            cloneonly \
            nocompile \
            nocompletions \
            wait"0a" \
                zsh-users/zsh-completions \
            atinit'
                zicompinit

                zicdreplay
            ' \
            atload'zstyle ":fzf-tab:*" fzf-command ftb-tmux-popup' \
            has"fzf" \
            wait"0a" \
                Aloxaf/fzf-tab \
            wait"0b" \
                hlissner/zsh-autopair \
            wait"0c" \
                zdharma-continuum/fast-syntax-highlighting \
            atload"_zsh_autosuggest_start" \
            wait"0c" \
                zsh-users/zsh-autosuggestions

    typeset _go_completion_file="${ZINIT[PLUGINS_DIR]}/zsh-users---zsh-completions/src/_golang" 

    zinit \
        as"null" \
        light-mode \
        lucid \
        run-atpull for \
            atclone'
                cp -f "${ZINIT[PLUGINS_DIR]}/zsh-users---zsh-completions/src/_golang" _golang

                zi creinstall .
            ' \
            atinit'
                typeset -Agr _GO_COMPLETION_PLUGIN=(
                    COMPLETION_FILE "${ZINIT[PLUGINS_DIR]}/zsh-users---zsh-completions/src/_golang"
                    DIRECTORY       "$PWD"
                )

                _retrieve_go_completions() {
                    local -r completion_file="${_GO_COMPLETION_PLUGIN[COMPLETION_FILE]}"

                    local -r installed_completion_file="${_GO_COMPLETION_PLUGIN[DIRECTORY]}/_golang"

                    if [[
                          ! -f "$installed_completion_file" ||
                          "$completion_file" -nt "$installed_completion_file"
                       ]]; then
                        cp -f "$completion_file" "$installed_completion_file"
                    fi
                }

                _update_go_completions() {
                    zi update zsh-users/zsh-completions

                    _retrieve_go_completions

                    zi creinstall "${_GO_COMPLETION_PLUGIN[DIRECTORY]}"
                }
            ' \
            atload"_retrieve_go_completions" \
            atpull"_update_go_completions" \
            has"go" \
            id-as"olegturzhanskii/go-completions" \
            if"[[ -d \"${_go_completion_file:h:h}\" ]]" \
            subscribe"$_go_completion_file" \
            trigger-load"!go" \
                zdharma-continuum/null \
            atclone'
                rustup completions zsh >! _rustup

                rustup completions zsh cargo >! _cargo

                zi creinstall .
            ' \
            atinit'
                typeset -Agr _RUSTUP_COMPLETION_PLUGIN=(
                    DIRECTORY "$PWD"
                )

                _generate_rustup_completions() {
                    local -r plugin_directory="${_RUSTUP_COMPLETION_PLUGIN[DIRECTORY]}"

                    rustup completions zsh >! "$plugin_directory/_rustup"

                    rustup completions zsh cargo >! "$plugin_directory/_cargo"
                }

                _update_rustup_completions() {
                    _generate_rustup_completions

                    zi creinstall "${_RUSTUP_COMPLETION_PLUGIN[DIRECTORY]}"
                }
            ' \
            atload'
                rustup() {
                    command rustup "$@"

                    local -ir rustup_exit_code=$?

                    if [[ $1 == "update" ]] && (( $rustup_exit_code == 0 )); then
                        _update_rustup_completions
                    fi

                    return $rustup_exit_code
                }
            ' \
            atpull"_update_rustup_completions" \
            has"rustup" \
            id-as"olegturzhanskii/rustup-completions" \
            trigger-load"!rustup" \
                zdharma-continuum/null \
            atinit'
                typeset -Agr _UV_TOOL_COMPLETION_PLUGIN=(
                    DIRECTORY "$PWD"
                )

                # NOTE:
                # Bring the installed completions into agreement with the tools uv actually has.
                #
                # Idempotent: when nothing changed, nothing is regenerated and nothing is written.
                _reconcile_uv_tool_completions() {
                    emulate -L zsh

                    setopt EXTENDED_GLOB

                    local -r plugin_directory="${_UV_TOOL_COMPLETION_PLUGIN[DIRECTORY]}"

                    local -A receipt_of

                    local entrypoint \
                          receipt

                    while read -r entrypoint receipt; do
                        receipt_of[$entrypoint]="$receipt"
                    done < <(_uv_tool_entrypoint_receipts)

                    local -a installed=( "$plugin_directory"/_*(N:t) )

                    installed=( "${installed[@]#_}" )

                    local -i changed=0

                    local completion_file \
                          temporary_file

                    for entrypoint in "${(@k)receipt_of}"; do
                        completion_file="$plugin_directory/_$entrypoint"

                        if [[ -f "$completion_file" && ! "${receipt_of[$entrypoint]}" -nt "$completion_file" ]]; then
                            continue
                        fi

                        temporary_file="$plugin_directory/$entrypoint.tmp"

                        "$entrypoint" generate-shell-completion zsh >! "$temporary_file" 2>/dev/null

                        if [[ -s "$temporary_file" ]]; then
                            mv "$temporary_file" "$completion_file"

                            changed=1
                        else
                            rm -f "$temporary_file"
                        fi
                    done

                    for entrypoint in "${installed[@]}"; do
                        if [[ -n "${receipt_of[$entrypoint]}" ]]; then
                            continue
                        fi

                        rm -f "$plugin_directory/_$entrypoint" "${ZINIT[COMPLETIONS_DIR]}/_$entrypoint"

                        if [[ -v _comps ]]; then
                            unset "_comps[$entrypoint]"
                        fi

                        changed=1
                    done

                    if (( changed )); then
                        zi creinstall "$plugin_directory"
                    fi
                }

                # NOTE:
                # The executables that uv tools provide, read from the receipt files uv writes rather than from its
                # human-readable output.
                #
                # Those receipts are what uv itself reads to manage a tool, so they are far more stable than prose.
                _uv_tool_entrypoint_receipts() {
                    local -r tool_directory="$(command uv tool dir 2>/dev/null)"

                    if [[ ! -d "$tool_directory" ]]; then
                        return 0
                    fi

                    local receipt \
                          line

                    for receipt in "$tool_directory"/*/uv-receipt.toml(N); do
                        for line in ${(f)"$(<"$receipt")"}; do
                            if [[ $line == *install-path* ]]; then
                                print -r -- "${${line#*name = \"}%%\"*}" "$receipt"
                            fi
                        done
                    done
                }
            ' \
            atload'
                # NOTE:
                # uv itself is never wrapped in any observable way: its arguments, streams, colors and exit code pass
                # through untouched.
                #
                # Only the subcommands that can change the set of installed tools trigger a reconciliation afterwards,
                # and that reconciliation never touches the network.
                uv() {
                    emulate -L zsh

                    command uv "$@"

                    local -ir uv_exit_code=$?

                    if (( $uv_exit_code == 0 )) && [[ $1 == "tool" && $2 == ("install"|"uninstall"|"upgrade") ]]; then
                        _reconcile_uv_tool_completions
                    fi

                    return $uv_exit_code
                }

                _reconcile_uv_tool_completions
            ' \
            atpull"_reconcile_uv_tool_completions" \
            has"uv" \
            id-as"olegturzhanskii/uv-tool-completions" \
            trigger-load"!uv" \
                zdharma-continuum/null

    unset _go_completion_file
fi

unset _zinit


if (( ${+commands[fzf]} )); then
    export FZF_DEFAULT_OPTS="--style full --tmux" \
           FZF_CTRL_T_OPTS="--preview 'fzf-preview.sh {}' --preview-window '<80(down)'"

    if (( ${+commands[fd]} )); then
        typeset _fd_command="fd -E .git -H"

        export FZF_DEFAULT_COMMAND="$_fd_command -t f" \
               FZF_CTRL_T_COMMAND="$_fd_command" \
               FZF_ALT_C_COMMAND="$_fd_command -t d"

        unset _fd_command
    fi

    source <(fzf --zsh)
fi

if (( ${+commands[zoxide]} )); then
    eval "$(zoxide init zsh)"
fi

# NOTE:
# Per-project environment, and nothing more.
#
# An .envrc applies its exports when you enter the directory and removes them again when you leave, which is the part
# no global configuration can do.
#
# It is not here to choose toolchain versions: rustup reads rust-toolchain.toml and uv reads .python-version, and both
# already do that on their own.
if (( ${+commands[direnv]} )); then
    eval "$(direnv hook zsh)"
fi

if (( ${+commands[starship]} )); then
    typeset _starship_configuration_file="$XDG_CONFIG_HOME/starship/starship.toml"

    if [[ -f "$_starship_configuration_file" ]]; then
        export STARSHIP_CONFIG="$_starship_configuration_file"
    fi

    unset _starship_configuration_file

    eval "$(starship init zsh)"
fi

