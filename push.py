#!/usr/bin/python3

import sys
import os

msg = 'update'

# 第一个参数为消息内容
if len(sys.argv) == 2:
    msg = sys.argv[1]
elif len(sys.argv) > 2:
    pass

ad = 'git add .'
co = 'git commit -am "{}"'.format(msg)
pu = 'git push origin master'

os.system(ad)
os.system(co)
os.system(pu)
