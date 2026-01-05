# - - - - - - - - - - - - - - - - - - - -
# Homebrew Configuration
# - - - - - - - - - - - - - - - - - - - -

# If You Come From Bash You Might Have To Change Your $PATH.
#   export PATH=:/usr/local/bin:/usr/local/sbin:$HOME/bin:$PATH
export PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

# Homebrew Requires This.
export PATH="/usr/local/sbin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# - - - - - - - - - - - - - - - - - - - -
# Zsh Core Configuration
# - - - - - - - - - - - - - - - - - - - -

# Load The Prompt System And Completion System And Initilize Them.
() {
  setopt local_options

  local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  local zcomp_ttl=1  # how many days to let the zcompdump file live before it must be recompiled
  local lock_timeout=1  # register an error if lock-timeout exceeded
  local lockfile="${zcompdump}.lock"

  autoload -Uz compinit

  # check for lockfile — if the lockfile exists, we cannot run a compinit
  #   if no lockfile, then we will create one, and set a trap on EXIT to remove it;
  #   the trap will trigger after the rest of the function has run.
  if [ -f "${lockfile}" ]
  then 

    # error log if the lockfile outlived its timeout
    if [ "$( find "${lockfile}" -mmin $lock_timeout )" ]
    then
      (
        echo "${lockfile} has been held by $(< ${lockfile}) for longer than ${lock_timeout} minute(s)."
        echo "This may indicate a problem with compinit"
      ) >&2
    fi

    # since the zcompdump is still locked, run compinit without generating a new dump
    compinit -D -d "$zcompdump"

    # Exit if there's a lockfile; another process is handling things
    return 1

  else

    # Create the lockfile with this shell's PID for debugging
    echo $$ > "${lockfile}"

    # Ensure the lockfile is removed on exit
    trap "rm -f '${lockfile}'" EXIT

  fi


  # refresh the zcompdump file if needed
  if [ ! -f "$zcompdump" -o "$( find "$zcompdump" -mtime "+${zcomp_ttl}" )" ]
  then
    # if the zcompdump is expired (past its ttl) or absent, we rebuild it
    compinit -d "$zcompdump"

  else

    # load the zcompdump without updating
    compinit -CD -d "$zcompdump"

    # asynchronously rebuild the zcompdump file
    (autoload -Uz compinit; compinit -d "$zcompdump" &);

  fi
}
setopt prompt_subst

# Zstyle.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zcompcache"
zstyle ':completion:*' list-colors $LS_COLORS
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':completion:*' rehash true

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/history-search-multi-word \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl 
    # zdharma-continuum/zinit-annex-as-monitor \
    # zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Most Themes Use This Option.
setopt promptsubst

# These plugins provide many aliases - atload''
zinit wait lucid for \
        OMZ::lib/git.zsh \
    atload"unalias grv" \
        OMZ::plugins/git/git.plugin.zsh


PS1="READY >"
zinit ice wait'!' lucid
# zinit ice from"gh-r" as"command" atload'eval "$(starship init zsh)"'
# zinit load starship/starship


# - - - - - - - - - - - - - - - - - - - -
# Plugins
# - - - - - - - - - - - - - - - - - - - -
zinit ice atclone"dircolors -b LS_COLORS > clrs.zsh" \
    atpull'%atclone' pick"clrs.zsh" nocompile'!' \
    atload'zstyle ":completion:*" list-colors “${(s.:.)LS_COLORS}”'

zinit wait lucid light-mode for \
    trapd00r/LS_COLORS \
    Aloxaf/fzf-tab \
  as"completion" \
    OMZ::plugins/node/node.plugin.zsh \
    OMZ::plugins/kubectl/kubectl.plugin.zsh \
    OMZ::plugins/brew/brew.plugin.zsh

# Don't bind these keys until ready
bindkey -r '^[[A'
bindkey -r '^[[B'
function __bind_history_keys() {
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}
# History substring searching
zinit ice wait lucid atload'__bind_history_keys'
zinit light zsh-users/zsh-history-substring-search

zinit wait lucid light-mode for \
  atinit'zicdreplay' atload'FAST_HIGHLIGHT[chroma-man]=' \
  atclone'(){local f;cd -q →*;for f (*~*.zwc){zcompile -Uz -- ${f}};}' \
  compile'.*fast*~*.zwc' nocompletions atpull'%atclone' \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
  blockf lucid atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

# - - - - - - - - - - - - - - - - - - - -
# Custom Configs
# - - - - - - - - - - - - - - - - - - - -

alias remove_node_modules="find . -type d -path './.*' -prune -o -path './Pictures*' -prune -o -path './Library*' -prune -o -path '*node_modules/*' -prune -o -type d -name 'node_modules' -exec touch '{}/.metadata_never_index' \; -print"

# SSH Alias
alias ll="ls -lah"
alias ssh="TERM=xterm-256color ssh"
alias vim="nvim"
alias update-all='brew upgrade && zinit self-update && zinit update'
alias git-cleanup="git fetch -p && git branch --merged main | grep -v '^[ *]*main$' | xargs git branch -d"
alias ls="ls -G"

# export PATH="/Users/bruno/.local/share/mise/shims:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/Users/bruno.galdino/.local/bin:$PATH"
export LDFLAGS="-L$(brew --prefix openssl)/lib" 
export CPPFLAGS="-I$(brew --prefix openssl)/include"

# setopt appendhistory
# setopt sharehistory
setopt HIST_IGNORE_SPACE 
setopt HIST_IGNORE_ALL_DUPS

# pnpm
export PNPM_HOME="/opt/homebrew/bin/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# tabtab source for packages
# uninstall by removing these lines
# [[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# bun completions

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(mise activate zsh)"
e
