alias python='python3.11'
alias pip='pip3.11'

# Basic environment settings
export EDITOR='vim'
export GREP_COLOR='1;36'
export HISTSIZE=5000
export SAVEHIST=5000
export HISTFILE=~/.zsh_history
export PAGER='less'
export TZ='Europe/London'
export VISUAL='vim'

# Support colors in less
export LESS_TERMCAP_mb=$(tput bold; tput setaf 1)
export LESS_TERMCAP_md=$(tput bold; tput setaf 1)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_se=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
export LESS_TERMCAP_ue=$(tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 2)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

# ZSH specific settings
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt AUTO_CD
setopt COMPLETE_ALIASES

# Define colors
autoload -U colors && colors

# Path
# export PATH="$HOME/bin:$PATH"

# Aliases
alias ..='cd ..'
alias ag='rg'
alias chomd='chmod'
alias gerp='grep'
alias hl='rg --passthru'
alias l='ls'
alias ll='ls -lha'
alias suod='sudo'
alias ls='ls -pG'
alias grep='grep --color=auto'

# Git Aliases
alias nb='git checkout -b "$USER-$(date +%s)"'
alias ga='git add . --all'
alias gb='git branch'
alias gc='git clone'
alias gci='git commit -a'
alias gco='git checkout'
alias gd="git diff ':!*lock'"
alias gdf='git diff'
alias gi='git init'
alias gl='git log'
alias gp='git push origin HEAD'
alias gr='git rev-parse --show-toplevel'
alias gs='git status'
alias gt='git tag'
alias gu='git pull'

# Git functions
function gmb() {
    local main
    main=$(git symbolic-ref --short refs/remotes/origin/HEAD)
    main=${main#origin/}
    [[ -n $main ]] || return 1
    echo "$main"
}

function gbd() {
    local mb=$(gmb) || return 1
    git diff "$mb..HEAD"
}

function gcm() {
    local mb=$(gmb) || return 1
    git checkout "$mb" && git pull
}

function gmm() {
    local mb=$(gmb) || return 1
    git merge "$mb"
}

# Utility functions
function colordiff() {
    local red=$(tput setaf 1 2>/dev/null)
    local green=$(tput setaf 2 2>/dev/null)
    local cyan=$(tput setaf 6 2>/dev/null)
    local reset=$(tput sgr0 2>/dev/null)

    diff -u "$@" | awk "
    /^\-/ { printf(\"%s\", \"$red\"); }
    /^\+/ { printf(\"%s\", \"$green\"); }
    /^@/ { printf(\"%s\", \"$cyan\"); }
    { print \$0 \"$reset\"; }"

    return "${pipestatus[1]}"
}

function colors() {
    local i
    for i in {0..255}; do
        printf "\x1b[38;5;${i}mcolor %d\n" "$i"
    done
    tput sgr0
}

function copy() {
    pbcopy
}

function epoch() {
    local num=${1:--1}
    strftime '%B %d, %Y %I:%M:%S %p %Z' "$num"
}

function interfaces() {
    networksetup -listallhardwareports | awk '
        /Hardware Port/{ port=$3 }
        /Device/{ device=$2 }
        /Ethernet Address/{ 
            "ipconfig getifaddr " device | getline ip
            if (ip != "") printf "%s: %s\n", device, ip 
        }'
}

function load() {
    sysctl -n vm.loadavg | awk '{printf "%.2f %.2f %.2f\n", $2/'"$(sysctl -n hw.ncpu)"', $3/'"$(sysctl -n hw.ncpu)"', $4/'"$(sysctl -n hw.ncpu)"'}'
}

function meminfo() {
    vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^0-9]+(\d+)/ and printf("%s: %d MB\n", "$1", $2 * $size / 1048576);'
}

# Git info in prompt
# Git info in prompt setup
autoload -Uz vcs_info
precmd() { 
    vcs_info
}
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '(git:%b)'

# Set up the prompt
setopt PROMPT_SUBST
PROMPT='%F{blue}%n%f at %F{magenta}%m%f in %F{green}%~%f %F{yellow}${vcs_info_msg_0_}%f$ '

# Set terminal title
function set_terminal_title() {
    local user=$USER
    local host=${HOST%%.*}
    local pwd=${PWD/#$HOME/\~}
    local ssh=
    [[ -n $SSH_CLIENT ]] && ssh='[ssh] '
    print -Pn "\e]0;${ssh}${user}@${host}:${pwd}\a"
}
precmd_functions+=(set_terminal_title)



# Load local configurations
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load homebrew completions
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi

# Enable syntax highlighting if installed via homebrew
[[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh