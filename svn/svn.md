## IDEA SVN 检出项目出现 Error:Cannot run program "svn" (in directory "D:\XXXXXX"):CreateProcess error=2系统找不到指定的文件

#### 原因：
没有安装 svn 命令行工具

#### 解决：
重新安装 svn 同时选中 'commend line ...'

## IDEA SVN 检出项目出现 No appropriate protocol (protocol is disabled or cipher suites are inappropriate)

#### 原因： 
需要权限验证

#### 解决：
1. 打开终端，输入 svn ls https://xxxxxxx(项目地址)
2. 输入 p
3. 输入账号密码，正确后路终端会打印出项目目录
4. 重新导入

