#!/usr/bin/python3

# 导入psycopg2包
import psycopg2

# 连接到一个给定的数据库
conn = psycopg2.connect(host="127.0.0.1", port="5432", database="test", 
                        user="postgres", password="191908577")

# 建立游标，用来执行数据库操作
cursor = conn.cursor()


# 执行SQL SELECT命令
cursor.execute("select * from log")


# 获取SELECT返回的元组
rows = cursor.fetchall()
for row in rows:
    print(row)


# 关闭游标
cursor.close()


# 关闭数据库连接
conn.close()