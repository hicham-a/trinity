#!/usr/bin/env bash
##title          : update.sh
##description    : This script will update a node given a profile. It will copy   
##                 the Trinity supplied files from the repository to the root
##                 file system of the node. Optionally, it will perform some 
##                 additional steps for some profiles (master/controller), 
##                 e.g., update the version files, update xCAT tables etc
##                 
##author         : Abhishek Mukherjee & Hans Then
##email          : abhishek.mukherjee@clustervision.com 
##                 hans.then@clustervision.com


main(){
  if [ -z $1 ] || [ $1 == "--help" || $1 == "-h" ]; then
    echo "Usage:"
    echo "  sh update.sh <profile> [--tables]"
    return 0
  fi  
  profile=$1
  if ls | grep $0 ; then
    echo "This will update the current node using the from source code repository"
    echo "using the profile: $0"
    proceed=n
    echo "Do you want to continue (y/n) [n]:"
    read proceed
    if [ ${proceed} =='Y' || ${proceed}=='y' || ${proceed}=='Yes' || ${proceed} == 'YES'|| ${proceed} == 'yes' ]; then
      copy $1
      tables "$@"
      exit 0
    else
      exit 0
    fi
    return 0
  else
    echo "No such profile: $0"
    return 1
  fi
}

copy(){
  REPO=$( cd "$1" && pwd )
  cp --dereference --recursive --verbose --preserve ${REPO}/rootimg/* /
  # TODO: There should be a list of excludes here
  LOCAL=/trinity/site-local/$1
  cp --dereference --recursive --verbose --preserve ${LOCAL}/rootimg/* /
}
extras(){
  REPO=$( cd "$1" && pwd )
  case $1 in
    master | controller)
      (git branch | grep "*"; git rev-parse --short HEAD; git status --porcelain) > /trinity/version
      cp /trinity/version /trinity/$1/rootimg/install/postscripts/cv_trinity_version
      if [ -z $2 ]; then
        return 0
      fi
      source /etc/profile.d/xcat.sh
      mkdir -p /tmp/xcattables
      read ETH1 ETH2 ETH3 <<<$(ls /sys/class/net/ | grep "^e" | sort | head -3)
      for table in $(ls ${REPO}/tables); do
        sed -e "s/\<eno1\>/$ETH1/g" -e "s/\<eno2\>/$ETH2/g"  -e "s/\<eno3\>/$ETH3/g" ${REPO}/tables/$table > /tmp/xcattables/$table;
      done
      restorexCATdb -Vp /tmp/xcattables     
      return 0
    ;;
    *)
      return 0
    ;;
  esac
}
 
success=$(main "$@")
exit ${success}

