## 报错 
error during connect: Get http://%2F%2F.%2Fpipe%2Fdocker_engine/v1.40/containers/json: open //./pipe/docker_engine: The system cannot find the file specified. In the default daemon configuration on Windows, the docker client must be run elevated to connect. This error may also indicate that the docker daemon is not running. 

## 解决
```
cd "C:\Program Files\Docker\Docker"
./DockerCli.exe -SwitchDaemon
```