#POWERLEVEL9K_MODE='awesome-fontconfig'
POWERLEVEL9K_MODE='nerdfont-complete'
ZSH_THEME="powerlevel9k/powerlevel9k"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_DISABLE_RPROMPT=true
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

export TERM="xterm-256color"
export TERMINAL="gnome-terminal"
export ZSH=$HOME/.oh-my-zsh
export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.wasme/bin:$HOME/.krew/bin"
export KUBE_EDITOR=vim

plugins=(
    git
    docker-compose
    ssh-agent
    kubectl
    zsh-autosuggestions
    gcloud
)


# Element styles
POWERLEVEL9K_OS_ICON_BACKGROUND="white"
POWERLEVEL9K_OS_ICON_FOREGROUND="blue"
POWERLEVEL9K_DIR_HOME_FOREGROUND="white"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="white"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="white"
POWERLEVEL9K_SHOW_CHANGESET=true
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND="white"
POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND="blue"

source $ZSH/oh-my-zsh.sh
source ~/.aliases

eval "$(direnv hook zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/google-cloud-sdk/completion.zsh.inc'; fi
