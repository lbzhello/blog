## pip 源
pip 安装比较慢，国内源速度比较快

### pip 国内的一些镜像

阿里云 https://mirrors.aliyun.com/pypi/simple/ 
清华大学 https://pypi.tuna.tsinghua.edu.cn/simple/ 
中国科学技术大学 https://pypi.mirrors.ustc.edu.cn/simple/

### 修改方法

1. 安装时指定源，临时有效

```sh
pip install scrapy -i https://pypi.tuna.tsinghua.edu.cn/simple
```

2. **Linux:** 修改/创建 ~/.pip/pip.conf 文件，内容如下

```conf
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
```

3. **Windows:** 家目录（C:\Users\USERNAME）下修改/创建一个 pip/pip.ini 文件，内容如下
```conf
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
```

## 更新 pip

```sh
python -m pip install --upgrade pip
```

## 安装 jupyterlab

```sh
pip install jupyterlab
```

