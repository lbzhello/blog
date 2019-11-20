## 卸载工具
UninstallTool

## 文件右键菜单删除
1. 打开注册表 regedit
2. 定位到 计算机\HKEY_CLASSES_ROOT\Directory\Background\shell\Git Bash Here\command, 没有的话新建一个
3. 修改默认值定位到程序执行文件比如 D:\Git\git-bash.exe

## 图标缺失
右键属性 -> 快捷方式 -> 更改图标

## git 出现 SSL certificate problem: unable to get local issuer certificate
git config --global http.sslVerify false