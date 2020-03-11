#### win10家庭版安装Docker for Windows

1. 新建 hyperv.cmd 文件，内容如下：

```powershell
pushd "%~dp0"

dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyper-v.txt

for /f %%i in ('findstr /i . hyper-v.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"

del hyper-v.txt

Dism /online /enable-feature /featurename:Microsoft-Hyper-V-All /LimitAccess /ALL
```

2. 以管理员身份执行 hyperv.cmd 文件

3. 控制面板 -> 程序和功能 -> 启用或关闭Windows功能打开 Hyper-V

4. 安装 docker

#### 有些模拟器需要关闭 Hyper-V

1. 控制面板 -> 程序和功能 -> 启用或关闭 Windows 功能 -> 去勾选 -> 重启
2. 管理员身份运行命令，win + x 选择管理员启动ps
```
bcdedit /set hypervisorlaunchtype off
```

重启，运行 vm 即可。

如果恢复 Hyper-V

```
bcdedit / set hypervisorlaunchtype auto
```

## 参考：
[Windows 10 下如何彻底关闭 Hyper-V 服务(翻外篇)](https://blog.csdn.net/l1028386804/article/details/78838399)