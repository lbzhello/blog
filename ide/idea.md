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
