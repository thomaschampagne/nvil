echo "                    "
echo " |\ | \  / | |      "
echo " | \|  \/  | |___   "
echo "                    "

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt appendhistory      # Append to history instead of overwriting
setopt sharehistory       # Share history across multiple open terminals
setopt histignorealldups  # Ignore duplicated commands

# -----------------------------------------------------------------------------
# Vim Terminal key bindings
# -----------------------------------------------------------------------------
# bindkey -v
# bindkey 'jj' vi-cmd-mode
# bindkey '^[[3~' delete-char
# bindkey '^R' history-incremental-search-backward
# bindkey '^?' backward-delete-char

# -----------------------------------------------------------------------------
# Emacs Terminal key bindings for arrows (Bash-like behavior)
# -----------------------------------------------------------------------------
bindkey -e
bindkey '^[[3~' delete-char # Delete key
bindkey '^[[H' beginning-of-line # Home key
bindkey '^[[F' end-of-line # End key
bindkey '^[[1;5D' backward-word # Ctrl + Left Arrow  (^[[1;5D) → jump backward one word
bindkey '^[[1;5C' forward-word # Ctrl + Right Arrow (^[[1;5C) → jump forward one word
bindkey '^[[1;3D' backward-word # Alt + Left Arrow  (^[[1;3D) → jump backward one word
bindkey '^[[1;3C' forward-word # Alt + Right Arrow (^[[1;3C) → jump forward one word

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "/home/${USERNAME}/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Loading Fedora Native Plugins
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Aliases
alias ll="ls -lFh"
alias la="ls -lAFh"
alias vim="nvim"
alias h="hx"
alias lg="lazygit"
alias yz="yazi"
alias y="yazi"
alias zj="zellij"
alias neofetch="fastfetch"
alias nf="clear && neofetch && echo -e \"\n\""

# - Git default username & email
git config --global user.name "${NVIL_GIT_USER_NAME}"
git config --global user.email "${NVIL_GIT_USER_EMAIL}"

# Control default PATH variable
# Set default editor for lazygit, yazy, and system...
eval "export EDITOR=${NVIL_DEFAULT_EDITOR}"
# - Add cli tools
export PATH="$PATH:/nvil/core/cmd"
# - Add mise (below export PATH)
eval "$(~/.local/bin/mise activate zsh)"
# - Add PNPM
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
export PATH="$PNPM_HOME:$PATH"