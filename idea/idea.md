[IntelliJ IDEA 常用快捷键)](https://www.cnblogs.com/kirin1105916774/p/11298550.html)

# http rest client

## 三个 '#' 标识不同请求之间的分隔符(可以作为注释说明)

```
### 获取第一个资源
GET http://localhost:8080/resources/1

### 删除第一个资源
DELETE http://localhost:8080/resources/1

```

## 上传文件

```
POST http://localhost:8080/resources/hello
Content-Type: multipart/form-data

--null


< G:\tmp.txt
--null--
```

## idea 初次配置

## tab placement 
【操作】：ctrl + shift + a -> 输入 "tab placement" -> none

这样工作区只会显示一个 editor 窗口，非常简洁。可以配合下面快捷键使用：

- ctrl + tab：上个编辑的文件
- ctrl + e：最近编辑的文件，然后点击上下键选择

## 项目编码
【操作】：ctrl + shift + a -> 输入 "file encodings" -> 全部选择 "utf-8"

Tips: Properties Files 有个 "Transparent native-to-ascii conversion" 选项，表示将 unicode 字符转码成 ascii 格式，如 "\u00df"

勾选后 -> 添加中文注释 -> 去勾选 -> 显示为 "\u00ab" 格式 -> 再勾选 -> 显示正常

参见(这里)[https://www.jianshu.com/p/11932ce51284]

## Codota (Tabnine 支持更多）
代码，提示，补全，示例

## JRebel
> https://jrebel.qekang.com/18f8e60d-bb37-4a20-b316-f15ae20f1428
[IDEA插件-热部署:JRebel](https://blog.csdn.net/u014395955/article/details/106938527/)

修改代码后 Ctrl + Shift + F9