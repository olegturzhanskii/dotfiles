# NOTE:
# Tools required by the configuration in this repository.
#
# The rule is narrow on purpose: a tool belongs here only if removing it would break or degrade something this 
# repository actually configures.
#
# That keeps `brew bundle check --file=Brewfile` a real test.
#
# Tools I use but do not configure here are in Brewfile.extras, and fun ones are in Brewfile.toys.
#
# Neither is installed by bootstrap.
#
# Not listed: git, which comes from the Xcode Command Line Tools and is a prerequisite rather than a dependency.
#
# Ordered the way you meet them: the terminal, then what runs inside it.


# NOTE:
# alacritty.toml names this font, so the two belong together.
cask "alacritty"

cask "font-jetbrains-mono-nerd-font"


# NOTE:
# Puts this repository configuration where each tool looks for it.
brew "stow"


# NOTE:
# tmux.conf runs tpm from the Homebrew prefix rather than cloning it.
brew "tmux"

brew "tpm"


# NOTE:
# Lets Touch ID authenticate sudo inside tmux, once you add the PAM line described in the README.
brew "pam-reattach"


# NOTE:
# plugins.zsh does nothing without zinit.
brew "zinit"

brew "starship"

brew "zoxide"

brew "fzf"


# NOTE:
# plugins.zsh points every fzf widget at fd, because fzf's own walker does not read .gitignore.
brew "fd"


# NOTE:
# EDITOR, VISUAL and MANPAGER all point at nvim.
#
# Its health check requires ripgrep, and its fuzzy finder greps with it.
brew "neovim"

brew "ripgrep"


# NOTE:
# Configured by name in .zshrc.
brew "bat"

brew "eza"

brew "tealdeer"


# NOTE:
# mc/.config/mc/ini skins it and points F3 and F4 at bat and nvim.
brew "midnight-commander"


# NOTE:
# htop/.config/htop/htoprc adds its TRANSLATED column, which is the only thing here that reports whether a running
# process is native or under Rosetta.
brew "htop"


# NOTE:
# Wired up as the pager in git/.config/git/config.
brew "git-delta"


# NOTE:
# .zprofile puts llvm on PATH; .zshrc aliases clang, clang-format and gcc.
brew "llvm"

brew "gcc"


# NOTE:
# plugins.zsh generates or installs shell completions for each of these.
brew "rustup"

brew "uv"

brew "go"

