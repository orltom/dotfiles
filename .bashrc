HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth


powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1

shopt -s histappend
shopt -s checkwinsize

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '

alias ll='ls -la --color'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

source "$HOME/.cargo/env"
. "$HOME/.cargo/env"

