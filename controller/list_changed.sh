#!/bin/bash
for file in $(find rootimg); do if [ -f $file ]; then if [ ${file#rootimg} -nt ${file} ]; then echo ${file#rootimg}; fi ; fi; done
