#!/usr/bin/env bash

echo "updating openstack from source code repository"
HERE=$( cd $(dirname "$0") && pwd )
cp --dereference --recursive --verbose --preserve ${HERE}/rootimg/* /
# TODO: There should be a list of excludes here
LOCAL=/trinity/site-local/openstack
cp --dereference --recursive --verbose --preserve ${LOCAL}/rootimg/* /


