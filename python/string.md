## 跟个字符串

```python
s = 'hello world'
s.split(' ')
```

## re 模块

```python
# 根据空格或者数字拆分字符串
ss = re.compile(r'\d|\s').split('hello123word haha')
print(ss[0])
print(ss[1])
print(ss[2])
```