# Third-party material

This repository is MIT licensed; see [LICENSE](LICENSE).

That covers my own work.

Most of this repository is my own configuration.

This page lists what is not, so nobody has to guess.

Tools that Homebrew installs are not listed; Homebrew already records where
each one comes from, and `Brewfile` names them.

## Copied files

Each of these is a copy of one file from a much larger project, carrying a
header that names its source and license.

| File | From | License |
|---|---|---|
| `alacritty/.config/alacritty/gruvbox_dark.toml` | [alacritty-theme](https://github.com/alacritty/alacritty-theme) | Apache-2.0 |
| `eza/.config/eza/theme.yml` | [eza-themes](https://github.com/eza-community/eza-themes) | MIT |

They are copied rather than referenced because only that one file is used from
each project.

## Neovim configuration

`nvim/.config/nvim/` began as [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), MIT licensed, and has changed
substantially since.

Kickstart describes itself as a starting point rather than a distribution and
tells you to fork it and edit it, so this is my configuration with kickstart
as its origin.

Upstream's `LICENSE.md` is kept alongside it.

## Colors

The gruvbox palette originates with [gruvbox](https://github.com/morhetz/gruvbox) by Pavel Pertsev, MIT licensed.

The color values in `starship.toml` are that palette written out by hand.

The tmux and Neovim themes are plugins installed by their own managers and are
not part of this repository.
