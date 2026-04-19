# Backlog

## Triage

- [ ] Move workspace under /home/smith/workspace (host mapped) + /home/smith as volumes.
- [ ] OpenCode: add default skills & agents (inc. dev, reviewer, doc writer,)
- [ ] Rework just commands:
  - [ ] just list => just help
  - [ ] Add back start command
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

- [ ] Lazygit hunk cpy (ctlr-o) trigger error tried "sudo dnf install xclip wl-clipboard xsel" but still fails

## Languages (+ formatter + debuggers)

- [ ] Kubernetes => yaml schemas support @P1 (same for compose)
- [ ] typescript (dap missing) @P1
- [ ] java
- [ ] Python+uv
- [ ] clang
- [ ] Rust
- [ ] dotfile

## System

- [ ] Add ssh server access with dropbear @P2
- [ ] Add brew to the toolchain

## CLI and Shell

- [ ] Add starship support feature

## Helix Editor

- [ ] Integrate `yazi` file manager with Helix => Open Yazi when opening helix file explorer @P1
- [ ] Helix keyboard shortcut / action to yamk/clipboard relative file path (<https://www.reddit.com/r/HelixEditor/comments/1cbqouk/copy_a_current_buffer_path_to_a_clipboard/>) @P1
- [ ] Helix keyboard shortcut for :wqa!
- [ ] Spellcheck (https://www.reddit.com/r/HelixEditor/comments/10r5t56/spellcheck_in_helix/)

## Project and CI/CD

- [ ] Fix wrong time in container. map /etc/localtime volume by default in compose files
