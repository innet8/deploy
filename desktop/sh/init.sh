#!/bin/bash

[[ -f /var/log/firstboot.log ]] && exit 0

PUBLIC_103.235.169.18=103.235.169.18
CONTAINER_PORT=$2
GOCRYPTFS_MASTER_KEY=$3
GOCRYPTFS_PASSWORD=$4

echo $0 $* >>/var/log/firstboot.log
sed "s/PUBLIC_103.235.169.18/${PUBLIC_103.235.169.18}/g" /etc/sh/janus/janus.jcfg >/etc/janus/janus.jcfg
sed "s/PUBLIC_103.235.169.18/${PUBLIC_103.235.169.18}/g" /etc/sh/janus/janus.transport.http.jcfg >/etc/janus/janus.transport.http.jcfg
sed -i "s/CONTAINER_PORT/${CONTAINER_PORT}/g" /etc/janus/janus.transport.http.jcfg
cp /etc/sh/janus/janus.plugin.streaming.jcfg /etc/janus/janus.plugin.streaming.jcfg

mkdir '/home/headless/Desktop/File_cabinet/.secrit_files'
echo ${GOCRYPTFS_PASSWORD} | gocryptfs -init -masterkey ${GOCRYPTFS_MASTER_KEY} '/home/headless/Desktop/File_cabinet/.secrit_files'
mkdir /home/headless/Desktop/File_cabinet/.加密文件
