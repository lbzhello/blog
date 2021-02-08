# tcpdump
```sh
# 获取所有网卡，以文本显示，通过 80 端口数据，
sudo tcpdump -i any -A port 80

# 获取所有发送到端口 80 的数据包
tcpdump -s 0 -X 'tcp dst port 80'

# 获取所有网卡；以文本显示；ip 不转成主机名；发送到 80 端口的数据
tcpdump -i any -A -n dst port 80
```