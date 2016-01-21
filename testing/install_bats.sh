#!/bin/bash

yum -y -q install git
git clone https://github.com/sstephenson/bats.git && bats/install.sh /usr/local
