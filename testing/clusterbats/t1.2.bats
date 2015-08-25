#!/user/env/bin/bats

@test "/cluster/vc-a/.modulespath is a file not a directory" {
  if  [ -f /vc-a/cluster/.modulespath ]
    then exit
  else
     rm -rf /cluster/vc-a/.modulespath
     cp /cluster/.skel/.modulespath /cluster/vc-a/.modulespath
     xdsh node001-node002 service trinity stop
     xdsh node001-node002 service trinity start

}



