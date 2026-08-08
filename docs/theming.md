# Colors

Everything here is gruvbox dark, which is a preference rather than a
requirement.

## There is no theme switcher

Six tools carry the colors, and each expresses them differently.

A script driving all six would be a small program abstracting five
incompatible file formats, and it would break whenever any of them changed.

So this page is the theme system: every place a color decision lives.

| Tool | File | What to change |
|---|---|---|
| Alacritty | `alacritty/.config/alacritty/alacritty.toml` | the `import` line |
| bat | `bat/.config/bat/config` | `--theme`; see `bat --list-themes` |
| eza | `eza/.config/eza/theme.yml` | replace the file; eza reads only this name |
| starship | `starship/.config/starship/starship.toml` | the `palette` line |
| tmux | `tmux/.config/tmux/tmux.conf` | the `@plugin` line naming the theme |
| Neovim | `nvim/.config/nvim/init.lua` | the colorscheme plugin and the `colorscheme` call |

## The pattern worth copying

`starship.toml` defines a named palette and selects it with one line:

```toml
palette = 'gruvbox_dark'

[palettes.gruvbox_dark]
color_fg0 = '#fbf1c7'
```

Add a second palette, change that line, and the prompt changes.

Alacritty works the same way if you keep more than one theme file beside
`gruvbox_dark.toml`.

Those two are genuinely one-line switches.

The other four are not, and pretending otherwise would mean building the theme
manager this page exists to avoid.

## Getting other theme files

The full collections are not here, because only one file is used from each.

```sh
git clone --depth 1 https://github.com/alacritty/alacritty-theme /tmp/alacritty-theme
git clone --depth 1 https://github.com/eza-community/eza-themes /tmp/eza-themes
```

Copy the one you want into place and keep its header, so the next reader knows
where it came from.

The tmux and Neovim themes are plugins, so switching those means changing
which plugin loads.

## Light mode

Every project above ships a light variant, usually named `gruvbox-light` or
`gruvbox_light`.

Nothing else here assumes a dark background.
