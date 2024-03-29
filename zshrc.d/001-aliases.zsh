## CHECK IF NVIM
if [ -x /bin/nvim ]; then
    alias vi="/bin/nvim"
    alias vim="/bin/nvim"
    export EDITOR="/bin/nvim"
fi

if [ -x /usr/bin/nvim ]; then
    alias vi="/usr/bin/nvim"
    alias vim="/usr/bin/nvim"
    export EDITOR="/usr/bin/nvim"
fi

if [ -x /opt/local/bin/nvim ]; then
    alias vim="/opt/local/bin/nvim"
    alias vi="/opt/local/bin/nvim"
    export EDITOR="/opt/local/bin/nvim"
fi
if [ -x /usr/local/bin/nvim ]; then
    alias vim="/usr/local/bin/nvim"
    alias vi="/usr/local/bin/nvim"
    export EDITOR="/usr/local/bin/nvim"
fi

if [ -x $HOME/.local/bin/nvim ]; then
    alias vim="$HOME/.local/bin/nvim"
    alias vi="$HOME/.local/bin/nvim"
    export EDITOR="$HOME/.local/bin/nvim"
fi

# Clearly, I also really like nvim.

#ALIAS
alias zc="${EDITOR}  ~/.zshrc"
alias hc="sudo ${EDITOR} /etc/hosts"
alias ls='exa --icons --group-directories-first'
alias ll='exa -l --icons --no-user --group-directories-first  --time-style long-iso'
alias la='exa -la --icons --no-user --group-directories-first  --time-style long-iso'
alias lll='exa -alh --icons --no-user --group-directories-first  --time-style long-iso'
alias cat='bat'

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

#Lazygit and Lazydocker
alias lzg="lazygit"
alias lzd="lazydocker"

alias showhidden="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"

alias hidehidden="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"

#Hey -> ApacheBench
if [ $(uname -a | grep -ci Darwin) = 1 ] && [ -x hey ]; then
    alias ab="hey"
fi

batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

updatedns(){ 
    echo "[main]\\ndns=none\\nrc-manager=unmanaged" | sudo tee /etc/NetworkManager/conf.d/no-dns.conf      
    sudo rm /etc/resolv.conf
    sudo cp etc/resolv.conf /etc/resolv.conf

    if [[ -f "mglu/resolv.conf" ]]; then
        cat mglu/resolv.conf | sudo tee -a /etc/resolv.conf
    fi
    sudo systemctl restart NetworkManager.service
}

alias kubectx='switch'
alias kctx='switch'
alias kubeswitch='switch'
alias df='duf'
