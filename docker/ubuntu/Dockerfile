FROM ubuntu

# 更新数据源，安装必要工具
RUN mv /etc/apt/sources.list /etc/apt/sources.list_backup
ADD sources.list /etc/apt/

RUN apt update
RUN apt -y install curl && apt -y install vim && apt -y install net-tools && apt -y install default-jre default-jdk