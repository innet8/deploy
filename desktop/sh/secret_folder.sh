#!/bin/bash

checked=`mount | grep fuse`
if [ "$checked" == "" ]; then
  GOCRYPTFS_PASSWORD=$(zenity --password --title="請輸入加密文件夾密碼")
  echo ${GOCRYPTFS_PASSWORD} | gocryptfs /home/headless/Desktop/File_cabinet/.secrit_files '/home/headless/Desktop/File_cabinet/.加密文件'
  if [ "$?" != "0" ]; then
    zenity --error --text "密碼錯誤"
    exit 1
  fi
fi
thunar /home/headless/Desktop/File_cabinet/.加密文件





