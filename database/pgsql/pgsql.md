**[PostgreSQL 官方文档中文翻译](https://www.runoob.com/manual/PostgreSQL/)**

#### pgAdmin

postgres 自带的 web 管理页面

#### SQL Shell(psql)

postgres 命令行 shell

### 常用命令

```shell
# 查看SQL命令的解释，比如\h select。
\h

# 显示所有命令
\?

# 查看所有数据库
\l

# 选择 somedb 数据库
\c somedb;

# 列出当前数据库所有表，视图，序列
\d

# 列出一张表格的结构
\d sometable;

# 列出(scheme 中)所有表
\dt [scheme]

# 列出（匹配的）所有用户
\du [pattern]
```

## 数据类型
#### 1. 基础类型
#### 2. 组合类型
#### 3. 域 类型和限制的组合
#### 4. 伪类型

| 名字 | 描述 |
|:----|:-----| 
| any | 表示一个函数可以接受任意输入数据类型 |
| anyelement | 表示一个函数可以接受任意数据类型（参见第 37.2.5 节） |
| anyarray | 表示一个函数可以接受任意数组数据类型（参见第 37.2.5 节）
| anynonarray | 表示一个函数可以接受任意非数组数据类型（参见第 37.2.5 节） |
| anyenum | 表示一个函数可以接受任意枚举数据类型（参见第 37.2.5 节和第 8.7 节） |
| anyrange | 表示一个函数可以接受任意范围数据类型（参见第 37.2.5 节和第 8.17 节） |
| cstring | 表示一个函数接受或者返回一个非空结尾的C字符串 |
| internal | 表示一个函数接受或返回一个服务器内部数据类型 |
| language_handler | 一个被声明为返回language_handler的过程语言调用处理器 |
| fdw_handler | 一个被声明为返回fdw_handler的外部数据包装器处理器 |
| index_am_handler | 一个被声明为返回index_am_handler索引访问方法处理器 |
| tsm_handler | 一个被声明为返回tsm_handler的表采样方法处理器 |
| record | 标识一个接收或者返回一个未指定的行类型的函数 |
| trigger | 一个被声明为返回trigger的触发器函数 |
| event_trigger | 一个被声明为返回event_trigger的事件触发器函数 |
| pg_ddl_command | 标识一种对事件触发器可用的 DDL 命令的表达 |
| void | 表示一个函数不返回值 |
| unknown | 标识尚未解析的类型，例如，未装饰的字符串文字 |
| opaque | 一种已被废弃的类型名称，以前它用于实现大多数以上的目的 |

#### 5. 多态类型

### 条件表达式

```sql
-- case
CASE expression
    WHEN value THEN result
    [WHEN ...]
    [ELSE result]
END

-- case when
CASE WHEN condition THEN result
     [WHEN ...]
     [ELSE result]
END

-- 示例
SELECT a,
       CASE a WHEN 1 THEN 'one'
              WHEN 2 THEN 'two'
              ELSE 'other'
       END
FROM test;

SELECT a,
       CASE WHEN a=1 THEN 'one'
            WHEN a=2 THEN 'two'
            ELSE 'other'
       END
FROM test;

-- if 条件表达式
IF ... THEN ... END IF
IF ... THEN ... ELSE ... END IF
IF ... THEN ... ELSIF ... THEN ... ELSE ... END IF

-- COALESCE 返回第一个非空表达式的值
COALESCE(value [, ...])

-- NULLIF 相等时返回 null
-- value1 == value2 ? null : value1
NULLIF(value1, value2)

```

## 函数

```sql
-- 函数定义
CREATE FUNCTION somefunc(integer, text) RETURNS integer
AS $$'function body text'$$ -- 一般用 $$ 表示函数体的开始和结束
LANGUAGE plpgsql;

-- 函数体
[ <<label>> ] -- 标签可以用于 exit 或 end, 也可以用标签访问变量的名字
[ DECLARE
    declarations ]
BEGIN
    statements
END [ label ];

-- 示例
CREATE FUNCTION somefunc() RETURNS integer AS $$
<< outerblock >>
DECLARE
    quantity integer := 30;
BEGIN
    RAISE NOTICE 'Quantity here is %', quantity;  -- Prints 30
    quantity := 50;

    -- 创建一个子块
    DECLARE
        quantity integer := 80;
    BEGIN
        RAISE NOTICE 'Quantity here is %', quantity;  -- Prints 80
        -- 用标签访问外层变量
        RAISE NOTICE 'Outer quantity here is %', outerblock.quantity;  -- Prints 50
    END;

    RAISE NOTICE 'Quantity here is %', quantity;  -- Prints 50

    RETURN quantity;
END;
$$ LANGUAGE plpgsql;

-- 变量声明
var1 integer default 32;
var2 varchar := 'http://example.com';
var3 constant integer := 10; -- constant 声明常量

-- 函数参数， $1 $2 $3... $n 表示参数
CREATE FUNCTION sales_tax(real) RETURNS real AS $$
DECLARE
    -- 参数别名
    subtotal ALIAS FOR $1;
BEGIN
    RETURN subtotal * 0.06;
END;
$$ LANGUAGE plpgsql;

-- 别名可以在声明时指定，可以通过 sales_tax.subtotal 引用
CREATE FUNCTION sales_tax(subtotal real) RETURNS real AS $$
BEGIN
    RETURN subtotal * 0.06;
END;
$$ LANGUAGE plpgsql;

-- 参数类型可以是一张表
CREATE FUNCTION concat_selected_fields(in_t sometablename) RETURNS text AS $$
BEGIN
    RETURN in_t.f1 || in_t.f3 || in_t.f5 || in_t.f7;
END;
$$ LANGUAGE plpgsql;

-- out 表示输出参数，此时可以省略 returns real
CREATE FUNCTION sales_tax(subtotal real, OUT tax real) AS $$
BEGIN
    tax := subtotal * 0.06;
END;
$$ LANGUAGE plpgsql;

-- out 声明多返回值，相当于 returns record
CREATE FUNCTION sum_n_product(x int, y int, OUT sum int, OUT prod int) AS $$
BEGIN
    sum := x + y;
    prod := x * y;
END;
$$ LANGUAGE plpgsql;

-- returns table， 等同于声明OUT参数并且指定RETURNS SETOF sometype
CREATE FUNCTION extended_sales(p_itemno int)
RETURNS TABLE(quantity int, total numeric) AS $$
BEGIN
    RETURN QUERY SELECT s.quantity, s.quantity * s.price FROM sales AS s
                 WHERE s.itemno = p_itemno;
END;
$$ LANGUAGE plpgsql;

-- 返回多态类型 anyelement、anyarray、anynonarray、anyenum或anyrange， 会创建 $0 并返回
CREATE FUNCTION add_three_values(v1 anyelement, v2 anyelement, v3 anyelement)
RETURNS anyelement AS $$
DECLARE
    result ALIAS FOR $0;
BEGIN
    result := v1 + v2 + v3;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 复制类型 variable%TYPE
-- 变量 user_id 和 users 表的 user_id 列具有相同的数据类型
user_id users.user_id%TYPE;

-- 行类型 name table_name%ROWTYPE;
CREATE FUNCTION merge_fields(t_row table1) RETURNS text AS $$
DECLARE
    t2_row table2%ROWTYPE;
BEGIN
    SELECT * INTO t2_row FROM table2 WHERE ... ;
    RETURN t_row.f1 || t2_row.f3 || t_row.f5 || t2_row.f7;
END;
$$ LANGUAGE plpgsql;

SELECT merge_fields(t.*) FROM table1 t WHERE ... ;

-- 排序规则，默认字段共同类型
-- 可以用 COLLATE 制定排序规则
DECLARE
    local_a text COLLATE "en_US";

-- 在比较时指定排序规则，会覆盖前面的规则
CREATE FUNCTION less_than_c(a text, b text) RETURNS boolean AS $$
BEGIN
    RETURN a < b COLLATE "C";
END;
$$ LANGUAGE plpgsql;
```

## 语句
```sql
-- 赋值语句




```