#!/user/bin/env bats
load configuration

@test "bash executes" {
  run bash --version
  [ "$status" -eq 0 ]
}

@test "1.1.4 controller connects to internet" {
  run ping -q -c1 google.com
  [ "$status" -eq 0 ]
}

@test "1.1.5 firewall is disabled" {
  run service firewall status
  [ "$status" -ne 0 ]
}

@test "1.1.9 SElinux is disabled" {
  run bash -c "sestatus | grep 'SELinux status' | egrep 'disabled'"
  [ "$status" -eq 0 ]
}

@test "1.1.6a iptables have the right masquerade rules" {
  iptables-save | grep -C3 'POSTROUTING -s 10.146.0.0/16 ! -o docker0 -j MASQUERADE' | grep 'POSTROUTING -o [0-z]* -j MASQUERADE'
}

@test "1.1.6b iptables have the right acceptance rules" {
  iptables-save | grep 'br100 -j ACCEPT'
}

@test "1.1.8 3d interface is taken over by the bridge" {
  ip a | grep 'master br100'
}

@test "1.1.10 The timezone is set correctly" {
  echo $TIMEZONE > TZ
  run bash -c "date | grep $TIMEZONE"
  [ "$status" -eq 0 ]
}

@test "1.1.12 Hostname is set correctly" {
   s1=$HOSTNAME
   s2='controller.cluster'
   [ $s1 = $s2 ] 
}


@test "1.1.13 The controller node is setup to user LDAP for authentication" {
   run service slapd status
   [ "$status" -eq 0 ]
}


@test "1.1.14 The controller node hosts a docker registry with a trinity image" {
   run bash -c "docker images | grep "controller:5050/trinity""
   [ "$status" -eq 0 ]

}

@test "1.1.15 DNS is working on the controller" {
   run host controller localhost
   [ "$status" -eq 0 ]
}

@test "1.1.17 Openvswitch is available" {
   run bash -c " find /install/netboot/centos7/x86_64/trinity/rootimg/ -name "openvswitch" | grep "openvswitch""
   [ "$status" -eq 0 ]
}

@test "The controller hosts an openstack image" {
   run bash -c "tabdump osimage | grep "centos7-x86_64-install-openstack""
   [ "$status" -eq 0 ]
}

#@test "The controller has postscripts for the addition of the trinity api and dashboard"
   
