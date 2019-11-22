#!/usr/bin/python3

import sys
import os

msg = 'update'

# 第一个参数为消息内容
if len(sys.argv) == 2:
    msg = sys.argv[1]
# 多个参数自动拼接，不用加引号了
elif len(sys.argv) > 2:
    msg = ' '.join(sys.argv[1:])

ad = 'git add .'
co = 'git commit -am "{}"'.format(msg)
pu = 'git push origin master'

os.system(ad)
os.system(co)
os.system(pu)
