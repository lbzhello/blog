#### pgAdmin

postgres 自带的 web 管理页面

#### SQL Shell(psql)

postgres 命令行 shell

### 常用命令

```shell
# 显示所有命令
\?

# 查看所有数据库
\l

# 选择 somedb 数据库
\c somedb;

# 查看表定义
\d sometable;

# 列出所有表
\dt

# 列出所有索引
\di
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