# Updating

Nothing here updates itself, with one exception: `tealdeer` refreshes its `tldr`
page cache daily, which is documentation rather than a dependency.

Every command below is the tool's own, not a wrapper.

## What is available

```sh
./bin/outdated
```

Checks every ecosystem, applies nothing.

## The one update that changes this repository

Neovim plugin updates rewrite `lazy-lock.json`, which is how accepted versions
are recorded.

```sh
:Lazy update
git diff nvim/.config/nvim/lazy-lock.json
```

Use Neovim for a while, then commit the lockfile if everything still works.

If it does not, `:Lazy restore` puts every plugin back and discarding the diff
undoes the update.

This is the only reversible update here, which is a good reason to look at the
diff.

## Everything else

None of these change a file in this repository.

Ordered the way things are installed, since Homebrew provides the managers
below it.

| What | Command |
|---|---|
| Homebrew itself | `brew update && brew upgrade` |
| Check tools still match `Brewfile` | `brew bundle check --file=Brewfile` |
| zsh plugins | `zi update --all` |
| tmux plugins | `prefix + U` inside tmux |
| Neovim tooling | `:Mason`, then `U` |
| uv tools | `uv tool upgrade --all` |
| Rust toolchain | `rustup update` |

`uv` and `go` are themselves Homebrew packages, so `brew upgrade` covers them.

`Brewfile` names tools, not versions, so upgrading never makes it stale.

`zi update --all` is the only thing that fetches a new Go completion
definition.

Opening a shell never does.

Mason updates language servers and formatters; Lazy updates plugins.

They are unrelated, and Mason has no lockfile.

Completions for `uv` tools and for Rust refresh by themselves after those
updates, without network access.

Afterwards, `./bin/doctor` reports anything that drifted.

## Comparing against newer kickstart

The Neovim configuration began as kickstart.nvim and no longer tracks it.

```sh
git clone --depth 50 https://github.com/nvim-lua/kickstart.nvim /tmp/kickstart
diff -u /tmp/kickstart/init.lua nvim/.config/nvim/init.lua | less
```

Take what you want by hand.

This is deliberately rare.
