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

# 从 file 中执行命令
\i [file] 
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

## 语句

#### 1. 控制结构

```sql
-- if 条件表达式
-- ELSIF 可以写成 ELSEIF
IF ... THEN ... END IF
IF ... THEN ... ELSE ... END IF
IF ... THEN ... ELSIF ... THEN ... ELSE ... END IF

IF number IS NULL OR number = 0 THEN
    result := 'zero';
ELSIF number > 0 THEN
    result := 'positive';
ELSIF number < 0 THEN
    result := 'negative';
ELSE
    result := 'UNKNOWN';
END IF;

-- COALESCE 返回第一个非空表达式的值
COALESCE(value [, ...])

-- NULLIF 相等时返回 null
-- value1 == value2 ? null : value1
NULLIF(value1, value2)

-- 简单CASE
CASE search-expression
    WHEN expression [, expression [ ... ]] THEN
      statements
  [ WHEN expression [, expression [ ... ]] THEN
      statements
    ... ]
  [ ELSE
      statements ]
END CASE;

-- 示例
CASE x
    WHEN 1, 2 THEN
        msg := 'one or two';
    WHEN 3, 4 THEN
        msg := 'thre or four';
    ELSE
        msg := 'other value than one or two';
END CASE;

-- 搜索 CASE 等价于 IF-THEN-ELSIF
CASE
    WHEN boolean-expression THEN
      statements
  [ WHEN boolean-expression THEN
      statements
    ... ]
  [ ELSE
      statements ]
END CASE;

CASE
    WHEN x BETWEEN 0 AND 10 THEN
        msg := 'value is between zero and ten';
    WHEN x BETWEEN 11 AND 20 THEN
        msg := 'value is between eleven and twenty';
END CASE;

-- 循环
-- LOOP
-- label 可以被 EXIT 和 CONTINUE 语句用在嵌套循环中返回
[ <<label>> ]
LOOP
    ...
END LOOP [ label ];

-- EXIT 跳出循环
EXIT [ label ] [ WHEN boolean-expression ];

-- CONTINUE 跳过本次循环
CONTINUE [ label ] [ WHEN boolean-expression ];

-- 示例
LOOP
    -- 一些计算
    EXIT WHEN count > 100;
    CONTINUE WHEN count < 50;
    -- 一些用于 count IN [50 .. 100] 的计算
END LOOP;

-- WHILE
[ <<label>> ]
WHILE boolean-expression LOOP
    statements
END LOOP [ label ];

-- 示例
WHILE amount_owed > 0 AND gift_certificate_balance > 0 LOOP
    -- 这里是一些计算
END LOOP;

WHILE NOT done LOOP
    -- 这里是一些计算
END LOOP;

-- FOR 循环
-- REVERSE 表示递减，BY 后面跟步长， name 为 integer
[ <<label>> ]
FOR name IN [ REVERSE ] list [ BY step ] LOOP
    statements
END LOOP [ label ];

-- 示例
FOR i IN 1..10 LOOP
    -- 我在循环中将取值 1,2,3,4,5,6,7,8,9,10 
END LOOP;

FOR i IN REVERSE 10..1 LOOP
    -- 我在循环中将取值 10,9,8,7,6,5,4,3,2,1 
END LOOP;

FOR i IN REVERSE 10..1 BY 2 LOOP
    -- 我在循环中将取值 10,8,6,4,2 
END LOOP;

-- FOR 循环迭代查询结果
CREATE FUNCTION cs_refresh_mviews() RETURNS integer AS $$
DECLARE
    mviews RECORD;
BEGIN
    RAISE NOTICE 'Refreshing materialized views...';

    FOR mviews IN SELECT * FROM cs_materialized_views ORDER BY sort_key LOOP
        -- 现在 "mviews" 有一个来自于 cs_materialized_views 的记录
        RAISE NOTICE 'Refreshing materialized view %s ...', quote_ident(mviews.mv_name);
        EXECUTE format('TRUNCATE TABLE %I', mviews.mv_name);
        EXECUTE format('INSERT INTO %I %s', mviews.mv_name, mviews.mv_query);
    END LOOP;

    RAISE NOTICE 'Done refreshing materialized views.';
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

-- FOREACH 循环数组, 
-- SLICE 制定迭代维度
[ <<label>> ]
FOREACH target [ SLICE number ] IN ARRAY expression LOOP
    statements
END LOOP [ label ];

-- 示例
CREATE FUNCTION sum(int[]) RETURNS int8 AS $$
DECLARE
  s int8 := 0;
  x int;
BEGIN
  FOREACH x IN ARRAY $1
  LOOP
    s := s + x;
  END LOOP;
  RETURN s;
END;
$$ LANGUAGE plpgsql;
```

#### 2. 其他语句

```sql
-- RAISE 抛出错误
RAISE [ level ] 'format' [, expression [, ... ]] [ USING option = expression [, ... ] ];
RAISE [ level ] condition_name [ USING option = expression [, ... ] ];
RAISE [ level ] SQLSTATE 'sqlstate' [ USING option = expression [, ... ] ];
RAISE [ level ] USING option = expression [, ... ];
RAISE ;


```


## 函数

```sql
-- 函数定义
CREATE [OR REPLACE] FUNCTION somefunc(integer, text) RETURNS integer
AS $$'function body text'$$ -- 一般用 $$ 表示函数体的开始和结束
LANGUAGE plpgsql;

-- 函数体
[ <<label>> ] -- 标签可以用于 exit 或 end, 也可以用标签访问变量的名字
[ DECLARE
    declarations ]
BEGIN
    statements
-- 捕获错误，可选扩展
-- 尽量避免使用，开销较大
[ EXCEPTION
    WHEN condition [ OR condition ... ] THEN
        handler_statements
    [ WHEN condition [ OR condition ... ] THEN
        handler_statements ]
]
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

-- RETURN NEXT / RETURN QUERY
-- 函数被声明为 SETOF sometype 时使用
-- 类似于递归，将返回结果追加到一个结果集中，随后 RETURN; 时将结果集返回
-- RETURN NEXT 用于标量和复合数据类型，RETURN QUERY 将查询的结果追加到结果集
CREATE TABLE foo (fooid INT, foosubid INT, fooname TEXT);
INSERT INTO foo VALUES (1, 2, 'three');
INSERT INTO foo VALUES (4, 5, 'six');

CREATE OR REPLACE FUNCTION get_all_foo() RETURNS SETOF foo AS
$BODY$
DECLARE
    r foo%rowtype;
BEGIN
    FOR r IN
        SELECT * FROM foo WHERE fooid > 0
    LOOP
        -- 这里可以做一些处理
        RETURN NEXT r; -- 返回 SELECT 的当前行
    END LOOP;
    RETURN;
END
$BODY$
LANGUAGE plpgsql;

SELECT * FROM get_all_foo();

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

-- 触发器
-- 创建函数时指定无参数，并且返回类型为 TRIGGER（数据更改触发器）或 EVENT_TRIGGER（事件触发器） 

-- 数据更改触发器
CREATE TRIGGER trigger_name BEFORE|AFTER INSERT|UPDATE|DELETE ON some_table
    FOR EACH ROW EXECUTE PROCEDURE trigger_function();

-- 特殊变量
NEW: 表示 INSERT/UPDATE 后的新数据
OLD: 表示 UPDATE/DELETE 前的旧数据

-- 示例
-- 一个用于审计的 PL/pgSQL 触发器过程
CREATE TABLE emp (
    empname           text NOT NULL,
    salary            integer
);

CREATE TABLE emp_audit(
    operation         char(1)   NOT NULL,
    stamp             timestamp NOT NULL,
    userid            text      NOT NULL,
    empname           text      NOT NULL,
    salary integer
);

CREATE OR REPLACE FUNCTION process_emp_audit() RETURNS TRIGGER AS $emp_audit$
    BEGIN
        --
        -- 在 emp_audit 中创建一行来反映 emp 上执行的动作，
        -- 使用特殊变量 TG_OP 来得到操作。
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO emp_audit SELECT 'D', now(), user, OLD.*;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO emp_audit SELECT 'U', now(), user, NEW.*;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO emp_audit SELECT 'I', now(), user, NEW.*;
        END IF;
        RETURN NULL; -- 因为这是一个 AFTER 触发器，结果被忽略
    END;
$emp_audit$ LANGUAGE plpgsql;

CREATE TRIGGER emp_audit
AFTER INSERT OR UPDATE OR DELETE ON emp
    FOR EACH ROW EXECUTE PROCEDURE process_emp_audit()
```