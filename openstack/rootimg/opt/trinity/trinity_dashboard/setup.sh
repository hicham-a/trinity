#!/bin/bash
read -e -p "Enter the dashboard directory [/usr/share/openstack-dashboard]: " top_dir
top_dir=${top_dir:="/usr/share/openstack-dashboard"}

if [ -d $top_dir ]; then
  echo "Will copy Trinity additions to $top_dir"
else
  echo "No such directory: $top_dir"
fi

img="${top_dir}/static/dashboard/img/"
if [ ! -d $img ]; then
 mkdir -pv $img
fi
if [ -f ${img}/logo.png ]; then
  cp  ${img}/logo.png ${img}/logo.png.orig
fi
if [ -f ${img}/logo-splash.png ]; then
  cp  ${img}/logo-splash.png ${img}/logo-splash.png.orig
fi
# removing the trinity logos for now, because of the formatting issue
# cp -rT ./img $img

enabled="${top_dir}/openstack_dashboard/local/enabled/"
if [ ! -d $enabled ]; then 
  mkdir -pv $enabled
fi
cp -rT ./local/enabled $enabled

admin="${top_dir}/openstack_dashboard/dashboards/admin/"
if  [ ! -d $admin ]; then 
  mkdir -pv $admin
fi
cp -rT ./dashboards/admin $admin

project="${top_dir}/openstack_dashboard/dashboards/project/"
if [ ! -d $project ]; then
  mkdir -pv $project 
fi
cp -rT ./dashboards/project $project

api="${top_dir}/openstack_dashboard/api/"
if [ ! -d $api ]; then 
  mkdir -pv $api 
fi
cp -rT ./api $api 

