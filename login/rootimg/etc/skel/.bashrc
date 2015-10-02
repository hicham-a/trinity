# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ ! -f ~/.ssh/id_dsa.pub ]; then
  ssh-keygen -f ~/.ssh/id_dsa -q -t dsa -N ''
  cp ~/.ssh/id_dsa.pub ~/.ssh/authorized_keys
fi
