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