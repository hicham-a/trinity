# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

PS1="[\u@\h($(cat /trinity/site | head -1)) \W]\\$ "

if [ -f /home/$(logname)/.gitconfig ]; then
    export GIT_AUTHOR_EMAIL=$(cat /home/$(logname)/.gitconfig | grep "email =" | awk -F= '{print $2}')
    export GIT_AUTHOR_NAME=$(cat /home/$(logname)/.gitconfig | grep "name =" | awk -F= '{print $2}')
    export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME
    export GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL
fi


