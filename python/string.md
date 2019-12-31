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

## format 格式化

```python
# hello world!
'hello {}{}'.format('world', '!')
'hello {0}{1}'.format('world')

# hello world!world
'hello {0}{1}{0}'.format('world')

# 双大括号会输出一个大括号
'{{0}:{1}}'.format(2, 4) # 输出 {0}:{1}

'{{0}}'.fromat(2, 4) # 输出 {0}

'{{{}:{}}}'.format('hello', 'world') # 输出 {hello:world}