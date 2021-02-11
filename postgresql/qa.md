## deadLocak
https://blog.csdn.net/guangmingguangming/article/details/104886309

## 安装提示 
Installation Directory: D:\PostgreSQL\13
Server Installation Directory: D:\PostgreSQL\13
Data Directory: D:\PostgreSQL\13\data
Database Port: 5432
Database Superuser: postgres
Operating System Account: NT AUTHORITY\NetworkService
Database Service: postgresql-x64-13
Command Line Tools Installation Directory: D:\PostgreSQL\13
pgAdmin4 Installation Directory: D:\PostgreSQL\13\pgAdmin 4
Stack Builder Installation Directory: D:\PostgreSQL\13


## 日期时间戳转换

```sql
-- 日期转时间戳
select extract(epoch from now())

--时间戳转日期
SELECT TO_TIMESTAMP(1512490630)
```

## 时区

```sql
-- 查看当前时区
show time zone;

-- 临时设定时区
set time zone 'Asia/Shanghai';
```