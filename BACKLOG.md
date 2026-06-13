# Backlog

## Triage

- [ ] Add `https://github.com/bug-ops/helix-trainer` as a feature. You will need to add sound lib to run it `sudo dnf install alsa-lib`
- [ ] OpenCode: add default generic skills & agents (inc. dev, reviewer, doc writer) to the feature
- [ ] Rework just commands:
  - [x] just list => just help
  - [x] Add back start command
  - [ ] Avoid to start podman machine if already running.
  - [ ] need to override default command: start only zsh instead of zellij for instance
  - [ ] view current nvil machine running (--list)
  - [ ] connect using nvil machine identifier (same for delete/stop/start)
- [ ] Support Docker instead of podman only.
- [ ] Others tools to consider

  | Tool | Lang | Replaces | Why |
  |------|------|----------|-----|
  | `dust` | Rust | du | Visual disk usage (complements dua/duf) |
  | `bottom`/`btm` | Rust | top/htop | System monitor |
  | `choose` | Rust | cut/awk | Field selection |
  | `ouch` | Rust | tar/gzip | Compression tool |
  | `????` | rustgo | — | Tool to generate qrcode |

- [ ] Convert `core/init/feats/required.install.sh` as real feats

## Bugs

- [ ] Helix keyboard shortcut / action to yamk/clipboard relative file path (<https://www.reddit.com/r/HelixEditor/comments/1cbqouk/copy_a_current_buffer_path_to_a_clipboard/>) @P1
- [ ] Lazygit hunk cpy (ctlr-o) trigger error tried "sudo dnf install xclip wl-clipboard xsel" but still fails

## Languages (+ formatter + debuggers)

- [ ] typescript (dap missing) @P1
  - [ ] angular
  - [ ] react
- [ ] java
- [ ] Python+uv
- [ ] Rust
- [ ] clang
- [ ] dotfile

## System

- [ ] Add ssh server access with dropbear @P2

## Helix Editor

- [x] Integrate `yazi` file manager with Helix => Open Yazi when opening helix file explorer @P1
- [ ] Helix keyboard shortcut for :wqa!
- [ ] Spellcheck (https://www.reddit.com/r/HelixEditor/comments/10r5t56/spellcheck_in_helix/)

## Project and CI/CD

- [ ] Fix wrong time in container. map /etc/localtime volume by default in compose files
