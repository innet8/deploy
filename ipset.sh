#!/bin/sh
apt update
apt install ipset dnsmasq -y 2> /dev/null
systemctl  stop systemd-resolved
systemctl  disable systemd-resolved
echo "all-servers" > /etc/dnsmasq.conf
echo "cache-size=10000" >> /etc/dnsmasq.conf
echo "clear-on-reload" >> /etc/dnsmasq.conf
echo "resolv-file=/etc/resolv.dnsmasq.conf" >> /etc/dnsmasq.conf
echo "conf-dir=/etc/dnsmasq.d " >> /etc/dnsmasq.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.dnsmasq.conf
echo "nameserver 114.114.114.114" >> /etc/resolv.dnsmasq.conf
sed -i 's@nameserver.*@nameserver 127.0.0.1@' /etc/resolv.conf
systemctl  restart dnsmasq.service

echo "*/1 * * * *  root ls /etc/dnsmasq.d/sh/ | grep '.sh' | xargs -t -I {} bash /etc/dnsmasq.d/sh/{} &> /dev/null && rm -rf /etc/dnsmasq.d/sh/* && ipset save > /etc/ipset.conf && iptables-save > /etc/iptables.conf" >> /etc/crontab