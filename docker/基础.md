#### 帮助手册

    docker stats --help

#### 载入镜像 

    docker pull training/webapp 

#### 交互式运行

    docker run -i -t ubuntu /bin/bash

- i 允许内的标准输入进行交互
- t 指定一个为终端

#### 启动容器

    # 外部端口 5001 -> 内部端口 5000
    docker run -d --name pyapp -p 5001:5000 training/webapp python app.py

- d daemon 守护线程方式启动 
- P 内部端口随机映射到外部
- p 指定端口，可指定 ip
- name 容器命名为 pyapp

    #可以通过访问 127.0.0.1:5001 来访问容器的 5000 端口
    docker run -d -p 127.0.0.1:5001:5000 training/webapp python app.py


#### 容器内运行命令

    docker run ubuntu /bin/echo "Hello world"

- ubuntu 表示运行的镜像，没有将会从仓库下载。

#### 重起容器

    docker start pyapp

#### 查看容器

    docker ps

    docker container ls

- l 查看最后一次创建的容器

#### 查看容器内标准输出

    docker logs

#### 查看端口映射
    # id 也可以是容器名
    docker port 123dfsf3 

    # 查看容器对应的外部端口
    docker port 123dfsf3 5000

#### 查看容器内部运行的进程

    docker top 1233fsdfe

#### 查看 Docker 容器的配置和状态信息

    docker inspect wizardly_chandrasekhar

#### 停止容器

    docker stop 12dfe3f5 

#### 移除容器

    docker rm 323jfsdf

## 镜像

#### 镜像列表

    docker images

    docker image ls

#### 使用镜像运行容器

    docker run -it --rm ubuntu:1804 /bin/bash

    -it 交互方式
    --rm 退出后自动删除容器

#### 查找镜像

    docker search ubuntu

#### 获取镜像

    docker pull ubuntu

#### 更新镜像

    docker commit -m="update" -a="author" e218edb10161 rep/ubuntu:v2

- m 提交信息
- a 作者

#### 构建镜像

    docker build -t myapp/ubuntu:dev .

- t 指定镜像名
- . 当前文件夹，需要包含 Dockerfile 文件

    docker build -f /path/to/Dockerfile -t liubaozhu/myapp .

- f 指定 Dockerfile 路径

#### 设置镜像标签

    docker tag 860c279d2fec myapp/ubuntu:dev

#### Docker network

    docker network ls

#### prune

```sh
# 删除已经停止的容器
docker container prune 

# 删除多余的镜像，比如中间镜像
docker image prune
```

