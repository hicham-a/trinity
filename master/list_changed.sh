#!/bin/bash
for file in $(find rootimg); do if [ -f $file ]; then if [ $file -nt  ${file#rootimg} ]; then echo ${file#rootimg}; fi ; fi; done
