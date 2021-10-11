#!/bin/bash
# echo ./iptable.sh >> /etc/rc.d/rc.local
sleep 20s
/usr/sbin/iptables -I DOCKER-USER -s 172.111.0.0/24 -d 172.111.11.0/24 -j DROP
/usr/sbin/iptables -I DOCKER-USER -s 172.111.0.0/24 -d 172.111.0.0/24 -j DROP
/usr/sbin/iptables -I DOCKER-USER -s 172.111.0.0/24 -d 172.111.11.24/32 -j ACCEPT

# webrtc coturn服务 相关端口开放
firewall-cmd --zone=public --add-port=3478/udp --permanent
firewall-cmd --zone=public --add-port=3478/tcp --permanent
firewall-cmd --zone=public --add-port=59000-65535/udp --permanent
firewall-cmd --reload
