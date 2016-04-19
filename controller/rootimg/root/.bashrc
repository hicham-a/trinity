# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

if hash git 2> /dev/null ; then
    PS1="[\u@\h(\$(cat /trinity/site 2> /dev/null || echo "unknown" | head -1)\$([ \$(git status -s 2> /dev/null | wc -l) == 0 ] || echo '*')) \W]\\$ "
    if [ -f /home/$(logname)/.gitconfig ]; then
        export GIT_AUTHOR_EMAIL=$(cat /home/$(logname)/.gitconfig | grep "email =" | awk -F= '{print $2}')
        export GIT_AUTHOR_NAME=$(cat /home/$(logname)/.gitconfig | grep "name =" | awk -F= '{print $2}')
        export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME
        export GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL
    fi
else
    PS1="[\u@\h($(cat /trinity/site > /dev/null || echo "unknown" | head -1)) \W]\\$ "
fi
