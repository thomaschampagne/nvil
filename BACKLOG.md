# Backlog

## Triage

- [ ] Control Lifecycle Commands with `just` command runner ?
- [ ] Helix keyboard shortcut / action to yamk/clipboard relative file path (<https://www.reddit.com/r/HelixEditor/comments/1cbqouk/copy_a_current_buffer_path_to_a_clipboard/>)
- [ ] Spellcheck (https://www.reddit.com/r/HelixEditor/comments/10r5t56/spellcheck_in_helix/)
- [ ] Helix keyboard shortcut for :wqa!
- [ ] Others tools to consider

  | Tool | Lang | Replaces | Why |
  |------|------|----------|-----|
  | `dust` | Rust | du | Visual disk usage (complements dua/duf) |
  | `bottom`/`btm` | Rust | top/htop | System monitor |
  | `choose` | Rust | cut/awk | Field selection |
  | `ouch` | Rust | tar/gzip | Compression tool |
  | `grex` | Rust | — | Regex from examples |
  | `????` | rustgo | — | Tool to generate qrcode |

- [ ] Convert `core/init/feats/required.install.sh` as real feats

## Bugs

- [ ] Lazygit hunk cpy (ctlr-o) trigger error tried "sudo dnf install xclip wl-clipboard xsel" but still fails

## Languages (+ formatter + debuggers)
 f
- [ ] typescript (dap missing) @P1
- [ ] Kubernetes => yaml schemas support @P1 (same for compose)
- [ ] java
- [ ] Python+uv
- [ ] clang
- [ ] Rust
- [ ] dotfile

## System

- [ ] Add ssh server access with dropbear @P2
- [ ] Add brew to the toolchain

## CLI and Shell

- [ ] Install usefull tools from: <https://github.com/Lissy93/Brewfile/blob/master/Brewfile>
- [ ] Add starship support feature

## Helix Editor

- [ ] Integrate `yazi` file manager with Helix => Open Yazi when opening helix file explorer

## Project and CI/CD

- [ ] Fix wrong time in container. map /etc/localtime volume by default in compose files
