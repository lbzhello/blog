#!/bin/bash

workdir=/app/zookeeper
zk_version=3.5.5
zk_path=/opt/zookeeper/${zk_version}
mkdir -p ${zk_path}

curl -o $workdir/zookeeper.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/current/apache-zookeeper-${zk_version}-bin.tar.gz
tar -zxf $workdir/zookeeper.tar.gz -C ${zk_path} --strip-components 1

cp $workdir/zoo.cfg $zk_path/conf/

# echo "export PATH=${PATH}:${zk_path}/bin" >> ~/.bashrc
# source ~/.bashrc

echo "${zk_path}/bin/zkServer.sh start" >> $workdir/start.sh

echo "while true; do echo hello world; sleep 1; done" >> $workdir/start.sh

# $zk_path/bin/zkServer.sh start