drop table if exists table_name;
drop type if exists week; -- 定义枚举
create type week as enum('Sun','Mon','Tues','Wed','Thur','Fri','Sat');
create table table_name (
  id serial not null primary key,
  col_int int not null default 0,
  col_decimal decimal(8, 4) not null default 0.00,
  col_numeric numeric(8, 4) not null default 0.00,
  col_float float(4) not null default 0.00,
  col_char char(2) not null default '',
  col_varchar varchar(128) not null default '',
  col_text text not null default '',
  col_tst timestamp not null default now(),
  col_blob bytea not null default '',
  col_bool boolean not null default 'false',
  col_enum week not null default 'Sun',
  col_bit bit(1) not null default '0',
  col_array int[][] not null default '{{1, 2},{2, 3}}',
  --  primary key (id),
  --  foreign key (id) references some_table(id),
  constraint uk_col_int unique (col_int)
);

-- 约束
alter table table_name add constraint uk_col_int_2 unique (col_int, col_char);
--alter table table_name add constraint fk_col_int primary key (id);
--alter table table_name add constraint fk_col_int foreign key (id) references other_table(id);
alter table table_name add constraint ck_col_char check (col_int > 0 and col_char not in ('a'));

-- 删除约束
alter table table_name drop constraint ck_col_char;

-- 索引
create index ix_table_name on table_name (id);
create unique index uk_table_name_id on table_name (id);

-- 删除索引
drop index uk_table_name_id;

-- 修改表名
alter table table_name rename to new_table_name;
alter table new_table_name rename to table_name;
-- not null
alter table table_name alter column col_int set not null; -- column 可以省略
-- 默认值约束
alter table table_name alter column col_int set default 0;
-- 删除约束
alter table table_name alter column col_int drop not null;

-- 改变列类型
alter table table_name alter column col_int type bigint;
-- 新增列
alter table table_name add column col_int_new int not null default 0;
-- 修改列名
alter table table_name rename column col_int_new to col_int_new_modify;
-- 删除列
alter table table_name drop column col_int_new_modify;


comment on table table_name is 'sql 语句示例';
comment on column table_name.id is '主键';

select * from table_name;
