# Backlog

## Triage

- [ ] Show my public IP using https://api.ipify.org
- [ ] Update/ensure latest fedora image beiing used
- [ ] Rework just commands:
  - [ ] need to override default command: start only zsh instead of zellij for instance
  - [ ] view current nvil machine running (--list)
  - [ ] connect using nvil machine identifier (same for delete/stop/start)
- [ ] Add `https://github.com/bug-ops/helix-trainer` as a feature. You will need to add sound lib to run it `sudo dnf install alsa-lib`
- [ ] Others tools to consider

  | Tool     | Lang | Replaces | Why              |
  | -------- | ---- | -------- | ---------------- |
  | `choose` | Rust | cut/awk  | Field selection  |
  | `ouch`   | Rust | tar/gzip | Compression tool |
  <!-- | `dust` | Rust | du | Visual disk usage (complements dua/duf) | -->
  <!-- | `bottom`/`btm` | Rust | top/htop | System monitor | -->

- [ ] Convert `core/init/feats/required.install.sh` as real feats
- [ ] Support Docker instead of podman only.

## Bugs

- [ ] ...

## Tools

- [ ] Add QRcode tui tool to generate qrcode

## Languages (+ formatter + debuggers)

- [ ] Web
  - [ ] React
  - [ ] Typescript:
    - [ ] dap missing
    - [ ] upgrade to typescript 7.1.x with angular ngserver lsp working in templates (only work with typescript 6 at the momentl)
- [ ] Rust
- [ ] java
- [ ] Python+uv
- [ ] dotfile
- [ ] clang

## System

- [ ] Add ssh server access with dropbear @P2 ? Others?

## Helix Editor

- [ ] Helix keyboard shortcut for :wqa!
- [ ] Spellcheck (https://www.reddit.com/r/HelixEditor/comments/10r5t56/spellcheck_in_helix/)

## Project and CI/CD

- [ ] Fix wrong time in container. map /etc/localtime volume by default in compose files
