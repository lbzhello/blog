[Centos 安装zlib](https://www.cnblogs.com/telwanggs/p/12963359.html)

```sh
tar -zxvf zlib-1.2.11.tar.gz

cd zlib-1.2.11/

./configure --prefix=/usr/local/zlib

make

make check

make install

echo "/usr/local/zlib/lib" >> /etc/ld.so.conf 

ldconfig -v
```