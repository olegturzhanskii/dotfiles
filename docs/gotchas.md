# When something looks broken

Six things in this environment fail in a way that does not point at the
cause.

Each one is a real trap rather than a mistake in the configuration, so each
one is written down here with the fix that is already in place.

They are in the order you meet them, from the terminal opening to the shell you
end up living in.

## `TERM=alacritty` does not resolve

**Symptom.**

tmux refuses to start with `missing or unsuitable terminal: alacritty`,
`infocmp alacritty` reports an unknown terminal, or a remote shell draws
garbage.

**Cause.**

macOS ships no terminfo entry for Alacritty, and Alacritty does not install
one.

It carries its own inside the application bundle, under
`/Applications/Alacritty.app/Contents/Resources/`.

`tmux-256color` and `xterm-256color` do resolve from the system database, which is
what makes the missing entry look like something else.

**Fix.**

`TERMINFO` points at `$XDG_DATA_HOME/terminfo` and the bundle's entries are linked
in there.

[`zsh/.zshenv`](../zsh/.zshenv) sets the variable and [`scripts/40-derived-state.sh`](../scripts/40-derived-state.sh) links the
entries.

Run that script again after an Alacritty upgrade replaces the bundle.

## `stow --no-folding` appears to do nothing

**Symptom.**

You add `--no-folding` to an existing deployment, Stow reports
`Skipping .config/alacritty as it already points to ...`, and `~/.config` is still
a set of links to directories in the repository.

`stow --simulate --no-folding` reports success against it, so the usual check
agrees that nothing is wrong.

**Cause.**

`--no-folding` governs how new links are made.

It does not unfold directories Stow already owns.

**Fix.**

Delete the deployment first, then make it again.

```sh
stow --delete --dir=~/dotfiles --target=~ \
  alacritty tmux nvim bat eza git htop mc starship tealdeer zsh

./scripts/30-configuration.sh
```

Because `--simulate` cannot see this, [`bin/doctor`](../bin/doctor) checks the shape of `~/.config`
directly instead.

## Terminal.app writes files into the repository

**Symptom.**

A `.zsh_sessions` directory appears inside the repository, and `git status` is
dirty after you have changed nothing.

**Cause.**

`/etc/zshrc_Apple_Terminal` sets
`SHELL_SESSION_DIR="${ZDOTDIR:-$HOME}/.zsh_sessions"` unconditionally, and
`ZDOTDIR` is `$XDG_CONFIG_HOME/zsh`.

With a folded deployment that directory is the repository, so Terminal.app
writes its session files straight into the working tree.

**Fix.**

This is the reason configuration is linked file by file rather than directory
by directory.

With `stow --no-folding`, `~/.config/zsh` is a real directory and only the
configuration files inside it are links, so there is nothing in the repository
for Terminal.app to write into.

The `.gitignore` rules for generated state remain as a safety net for a folded
deployment.

## Touch ID authorizes `sudo`, but not inside tmux

**Symptom.**

`sudo` accepts a fingerprint in a plain terminal window and asks for a typed
password inside tmux, with nothing said about the difference.

**Cause.**

The Touch ID PAM module has to reach the graphical login session to raise its
prompt, and a process started inside tmux is not attached to that session.

The attempt fails quietly, so PAM falls through to the password.

**Fix.**

`pam-reattach` reattaches the process first, which is the only reason it is in
`Brewfile` when nothing here configures it.

`/etc/pam.d/sudo` belongs to Apple and a system update can replace it, which is
why recent macOS ends that file with an `include` of `/etc/pam.d/sudo_local`.

The second file is the one meant for local additions and the one an update
leaves alone, so the two lines belong there, with the reattachment above Touch
ID:

```text
auth       optional       /opt/homebrew/lib/pam/pam_reattach.so ignore_ssh
auth       sufficient     pam_tid.so
```

Both details in the first line are local rather than universal: the path is
the Apple Silicon Homebrew prefix, and older systems have no `sudo_local` at
all, in which case the line goes in `/etc/pam.d/sudo` and an update will remove
it.

`ignore_ssh` matters more than it looks, because without it an SSH session
raises a fingerprint prompt on a machine nobody is sitting at.

Keep a second shell with a working `sudo` open while editing that file, since a
malformed line there stops `sudo` working at all.

## `brew bundle check` fails on software you already have

**Symptom.**

Everything in `Brewfile` is installed, `bootstrap.sh` reports success, and
`brew bundle check` still says the dependencies are not satisfied.

**Cause.**

`brew bundle check` treats an *outdated* formula as unmet, not only a missing one.

That disagrees with `brew bundle install --no-upgrade`, which setup uses, and
with the idea that `Brewfile` names tools rather than versions.

**Fix.**

Ask the question you actually meant.

```sh
brew bundle check --no-upgrade   # is everything installed?
./bin/outdated                   # is anything newer available?
```

[`bin/doctor`](../bin/doctor) passes `--no-upgrade` so that it agrees with bootstrap, and
`bin/outdated` is where the newer-version question belongs.

## A completion disappears but Tab still tries to use it

**Symptom.**

You run `uv tool uninstall something`, and in a different shell that was already
open, pressing Tab reports `_something: function definition file not found`.

**Cause.**

`compinit` records the completion in `_comps` and installs an autoload stub when
the shell starts.

Deleting the file afterwards cannot reach into a shell that has already read
it.

This is plain zsh behavior and has nothing to do with the plugin manager.

**Fix.**

Nothing is wrong, and the shell that ran the uninstall is already clean.

Any other shell that was open at the time keeps the stale binding until it
exits, because no mechanism in zsh can reach across running shells.

[`zsh/.config/zsh/plugins.zsh`](../zsh/.config/zsh/plugins.zsh) handles the two cases it can reach: it clears
the binding in the shell that ran the uninstall, and a new shell never learns
the completion at all.
