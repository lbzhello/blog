## 卸载工具
UninstallTool

## 文件右键菜单删除
1. 打开注册表 regedit
2. 定位到 计算机\HKEY_CLASSES_ROOT\Directory\Background\shell\Git Bash Here\command, 没有的话新建一个
3. 修改默认值定位到程序执行文件比如 D:\Git\git-bash.exe

## 其他右键菜单删除
1. 打开注册表 regedit
2. 点击计算机 -> 编辑 -> 查找 -> 修改或删除

## 图标缺失
右键属性 -> 快捷方式 -> 更改图标

## git 出现 SSL certificate problem: unable to get local issuer certificate
git config --global http.sslVerify false

## gpedit 本地组策略

## regedit 注册表

## curl
Linux 下的一个常用工具 curl 非常好用，但是在 powershell 里面却被占用了（作为 Invoke-WebRequest 的别名）
【解决】：删除 curl 别名，反正也基本用不到，或者说完全可以被真正的 curl 取代。

```sh
remove-item alias:\curl
```

然后正常安装 [curl：https://curl.haxx.se/windows](https://curl.haxx.se/windows/) 设置环境变量就可以了。
