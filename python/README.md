## 安装 pyton

```sh
wget https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz
tar -zxvf  Python-3.8.3.tgz

cd Python-3.8.3
# 安装到 /user/local/python3
./configure --prefix=/usr/local/python3 --enable-optimizations
make && make install

# 执行命令查看是否成功 
python3 
```

建立指向 python 命令的软连接，之后可以使用 python 命令而不是 python3

```sh
# 查看软连接
ll /usr/local/bin | grep python

# 删除原来的软连接
rm -rf /usr/local/bin/python

# 添加python3的软链接 
ln -s /usr/local/bin/python3 /usr/local/bin/python

# 执行命令查看是否成功
python
```