#!/bin/bash
read -e -p "Enter the dashboard directory [/usr/share/openstack-dashboard]: " top_dir
top_dir=${top_dir:="/usr/share/openstack-dashboard"}

if [ -d $top_dir ]; then
  echo "Will copy Trinity additions to $top_dir"
else
  echo "No such directory: $top_dir"
fi

# Not adding the Trinity logos right now because of a bug in Horizon (Juno)
# which causes problems with the CSS rendering

# img="${top_dir}/static/dashboard/img/"
# if [ ! -d $img ]; then
#  mkdir -pv $img
# fi
# cp -rv ./img/* $img

enabled="${top_dir}/openstack_dashboard/local/enabled/"
if [ ! -d $enabled ]; then 
  mkdir -pv $enabled
fi
cp -rv ./local/enabled/* $enabled

admin="${top_dir}/openstack_dashboard/dashboards/admin/"
if  [ ! -d $admin ]; then 
  mkdir -pv $admin
fi
cp -rv ./dashboards/admin/* $admin

project="${top_dir}/openstack_dashboard/dashboards/project/"
if [ ! -d $project ]; then
  mkdir -pv $project 
fi
cp -rv ./dashboards/project/* $project

api="${top_dir}/openstack_dashboard/api/"
if [ ! -d $api ]; then 
  mkdir -pv $api 
fi
cp -rv ./api/* $api 

