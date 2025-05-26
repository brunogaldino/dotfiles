# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

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
autoload -Uz compinit promptinit

# Load And Initialize The Completion System Ignoring Insecure Directories With A
# Cache Time Of 20 Hours, So It Should Almost Always Regenerate The First Time A
# Shell Is Opened Each Day.
# See: https://gist.github.com/ctechols/ca1035271ad134841284
_comp_files=(${ZDOTDIR:-$HOME}/.zcompdump(Nm-20))
if (( $#_comp_files )); then
    compinit -i -C
else
    compinit -i
fi
unset _comp_files
promptinit
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

# - - - - - - - - - - - - - - - - - - - -
# Theme
# - - - - - - - - - - - - - - - - - - - -

# Most Themes Use This Option.
setopt promptsubst

# These plugins provide many aliases - atload''
zinit wait lucid for \
        OMZ::lib/git.zsh \
    atload"unalias grv" \
        OMZ::plugins/git/git.plugin.zsh

#### POWERLEVEL10K
# Provide A Simple Prompt Till The Theme Loads
# PS1="READY >"
# zinit ice wait'!' lucid
# zinit ice depth=1; zinit light romkatv/powerlevel10k


PS1="READY >"
zinit ice wait'!' lucid
zinit ice from"gh-r" as"command" atload'eval "$(starship init zsh)"'
zinit load starship/starship


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

# Recommended Be Loaded Last.
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

eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# CUSTOM VARS
export ANDROID_HOME=$HOME/Library/Android/sdk 
export ANDROID_HOME=$HOME/Library/Android/sdk 
export PATH=$PATH:$ANDROID_HOME/emulator 
export PATH=$PATH:$ANDROID_HOME/tools 
export PATH=$PATH:$ANDROID_HOME/tools/bin 
export PATH=$PATH:$ANDROID_HOME/platform-tools
export JAVA_HOME=$(/usr/libexec/java_home)

alias remove_node_modules="find . -type d -path './.*' -prune -o -path './Pictures*' -prune -o -path './Library*' -prune -o -path '*node_modules/*' -prune -o -type d -name 'node_modules' -exec touch '{}/.metadata_never_index' \; -print"

# SSH Alias
alias ll="ls -lah"
alias ssh="TERM=xterm-256color ssh"
alias vim="nvim"
# alias update-nvim-stable='asdf uninstall neovim stable && asdf install neovim stable'
# alias update-nvim-nightly='asdf uninstall neovim nightly && asdf install neovim nightly'
alias update-all='brew upgrade && zinit self-update && zinit update'
alias git-cleanup="git fetch -p && git branch --merged main | grep -v '^[ *]*main$' | xargs git branch -d"
alias ls="ls -G"


build_path_common() {
  local current_dir=`pwd`

  echo ${current_dir}
  cd /Users/bruno/Documents/Projects/$1/libraries/common
  {
    pnpm build &&
    rm -rf ${current_dir}/node_modules/$1/common/dist &&  cp -r dist ${current_dir}/node_modules/$1/common/dist  &&
    rm -rf ${current_dir}/node_modules/$1/common/package.json &&  cp -r ./package.json ${current_dir}/node_modules/$1/common/package.json &&
    cd -- $current_dir
  } || { 
    echo 'FAILED BUILDING COMMONS'
    cd -- $current_dir
  }
}

build_lib() {
  local current_dir=`pwd`

  echo ${current_dir}
  cd /Users/bruno/Documents/Projects/open-source/$1

  {
    pnpm build &&
    echo Moving $1 to ${current_dir}/node_modules/$2 &&
    rm -rf ${current_dir}/node_modules/$2/dist &&  cp -r dist ${current_dir}/node_modules/$2/dist &&
    cd -- $current_dir
  } || { 
    echo 'FAILED BUILDING COMMONS'
    cd -- $current_dir
  }
}

commit_dotfiles() { 
    local repo_path=`~/Documents/Projects/open-source/dotfiles`
    cp -r ~/.config/ghostty ~/Documents/Projects/open-source/dotfiles
    cp -r ~/.config/nvim ${repo_path}
    cp -r ~/.config/starship.toml ${repo_path}
    cp ~/.zshrc ${repo_path}
    
    cd ${repo_path}
    git add --all 
    git commit -m "updated dotfiles"
    git push
}

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="${HOME}/.pyenv/shims:${PATH}"
export PATH="/Users/bruno/.local/share/mise/shims:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$PATH:/Users/bruno/.dotnet/tools"
# setopt appendhistory
# setopt sharehistory
setopt HIST_IGNORE_SPACE 
setopt HIST_IGNORE_ALL_DUPS

# pnpm
export PNPM_HOME="/Users/bruno/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# tabtab source for packages
# uninstall by removing these lines
# [[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
