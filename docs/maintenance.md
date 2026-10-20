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

## The hooks that hold the lockfile to what runs

`.githooks` holds two Git hooks that check the one update recorded here, and Git
runs them only in a clone that opts in:

```sh
git config core.hooksPath .githooks
```

`./bin/doctor` says whether the clone in front of you has opted in.

`pre-commit` checks the Neovim files a commit records, and only when the commit
touches `nvim/.config/nvim`: a staged `lazy-lock.json` has to be valid JSON with a
branch and a full commit hash for every plugin, and a staged Lua file has to
compile.

`pre-push` refuses a push while `lazy-lock.json` has changes that are not
committed, or while the plugins installed here are at commits the pushed
lockfile does not record.

`./bin/doctor` makes the same comparison on demand, against the lockfile in the
working tree, and `:Lazy restore` is the fix it names.

Neither hook changes a file here, touches the network, or installs or updates
anything, and each runs its check on cases with a known answer before it
reports.

While trying an update before committing it, push with `git push --no-verify`,
which is also how to override either hook on purpose.

Mason is left out, because it has no lockfile: nothing records which versions
should be installed, so a hook would have nothing to compare.

Whether anything newer exists is left out as well, because the answer needs
the network and changes with the day rather than with the commit, so
`./bin/outdated` stays the place to ask it.

## Everything else

None of these change a file in this repository.

Ordered the way things are installed, since Homebrew provides the managers
below it.

| What | Command |
|---|---|
| Homebrew itself | `brew update && brew upgrade` |
| Alacritty | the new `.dmg`, installed as in the [README](../README.md#before-you-start), then `./scripts/40-derived-state.sh` |
| Check tools still match `Brewfile` | `brew bundle check --file=Brewfile` |
| zsh plugins | `zinit update --all` |
| tmux plugins | `prefix + U` inside tmux |
| Neovim tooling | `:Mason`, then `U` |
| uv tools | `uv tool upgrade --all` |
| Rust toolchain | `rustup update` |

`uv` and `go` are themselves Homebrew packages, so `brew upgrade` covers them.

`Brewfile` names tools, not versions, so upgrading never makes it stale.

zinit is spelled in full because its `zi` alias is turned off in [`plugins.zsh`](../zsh/.config/zsh/plugins.zsh),
so that `zi` still means zoxide's interactive jump.

`zinit update --all` is the only thing that fetches a new Go completion
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
