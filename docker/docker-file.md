```dockerfile
FROM ubuntu
RUN yum install curl
RUN curl -O redis.tar.gz "http://download.redis.io/releases/redis-5.0.3.tar.gz"
RUN tar -zxvf redis.tar.gz
COPY redis.conf /opt/
```

## FROM
指定构建时（docker build ...）的基镜像

## RUN
docker build 时运行的命令

## COPY
复制文件到容器指定目录

格式：
```dockerfile
COPY [源路径1]... [目标路径]
```

> ADD 和 COPY 类似，会自动解压压缩包

## CMD
为启动的容器指定默认要运行的程序，程序运行结束，容器也就结束。CMD 指令指定的程序可被 docker run 命令行参数中指定要运行的程序所覆盖。

如果 Dockerfile 中如果存在多个 CMD 指令，仅最后一个生效。

格式：
```dockerfile
CMD <shell 命令> 
CMD ["<可执行文件或命令>","<param1>","<param2>",...] 
CMD ["<param1>","<param2>",...]  # 该写法是为 ENTRYPOINT 指令指定的程序提供默认参数
```

## ENTRYPOINT
类似于 CMD 指令，但其不会被 docker run 的命令行参数指定的指令所覆盖

在执行 docker run 的时候可以指定 ENTRYPOINT 运行所需的参数。也可以通过 CMD 指定默认的参数

如果 Dockerfile 中如果存在多个 ENTRYPOINT 指令，仅最后一个生效

格式：
```dockerfile
FROM nginx

ENTRYPOINT ["nginx", "-c"] # 定参
CMD ["/etc/nginx/nginx.conf"] # 变参 
```

下面运行这个镜像
```sh
$ docker run nginx # 相当于启动后运行 nginx -c /etc/nginx/nginx.conf 

$ docker run  nginx -c /etc/nginx/new.conf # 相当于启动后运行 nginx -c /etc/nginx/new.conf
```

## VOLUME
定义匿名数据卷。在启动容器时忘记挂载数据卷，会自动挂载到匿名卷

在启动容器 docker run 的时候，我们可以通过 -v 参数修改挂载点

格式：
```dockerfile
VOLUME ["<路径1>", "<路径2>"...]
VOLUME <路径>
```

## ENV
设定环境变量，在后续的指令中，就可以使用这个环境变量。

格式:
```dockerfile
ENV <key> <value>
ENV <key1>=<value1> <key2>=<value2>...
```

## ARG
和 EVN 类似，但是只在 docker build 的过程中有效

## EXPOSE
帮助镜像使用者理解这个镜像服务的守护端口，以方便配置映射。

在运行时使用随机端口映射时，也就是 docker run -P 时，会自动随机映射 EXPOSE 的端口。

格式：
```dockerfile
EXPOSE <端口1> [<端口2>...]
```

## WORKDIR
指定工作目录。用 WORKDIR 指定的工作目录，会在构建镜像的每一层中都存在。（WORKDIR 指定的工作目录，必须是提前创建好的）。

docker build 构建镜像过程中的，每一个 RUN 命令都是新建的一层。只有通过 WORKDIR 创建的目录才会一直存在。

格式：
```dockerfile
WORKDIR <工作目录路径>
```

## USER
用于指定执行后续命令的用户和用户组，这边只是切换后续命令执行的用户（用户和用户组必须提前已经存在）。

格式：
```dockerfile
USER <用户名>[:<用户组>]
```

## HEALTHCHECK
用于指定某个程序或者指令来监控 docker 容器服务的运行状态。

格式：
```dockerfile
HEALTHCHECK [选项] CMD <命令>：设置检查容器健康状况的命令
HEALTHCHECK NONE：如果基础镜像有健康检查指令，使用这行可以屏蔽掉其健康检查指令

HEALTHCHECK [选项] CMD <命令> : 这边 CMD 后面跟随的命令使用，可以参考 CMD 的用法。
```

## ONBUILD
用于延迟构建命令的执行。简单的说，就是 Dockerfile 里用 ONBUILD 指定的命令，在本次构建镜像的过程中不会执行（假设镜像为 test-build）。当有新的 Dockerfile 使用了之前构建的镜像 FROM test-build ，这是执行新镜像的 Dockerfile 构建时候，会执行 test-build 的 Dockerfile 里的 ONBUILD 指定的命令。

格式：
```dockerfile
ONBUILD <其它指令>
```