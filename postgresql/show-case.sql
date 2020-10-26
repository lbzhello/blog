drop table if exists show_case;
drop type if exists week; -- 定义枚举
create type week as enum('Sun','Mon','Tues','Wed','Thur','Fri','Sat');
create table show_case (
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
alter table show_case add constraint uk_col_int_2 unique (col_int, col_char);
--alter table show_case add constraint fk_col_int primary key (id);
--alter table show_case add constraint fk_col_int foreign key (id) references other_table(id);
alter table show_case add constraint ck_col_char check (col_int > 0 and col_char not in ('a'));

-- 删除约束
alter table show_case drop constraint ck_col_char;

-- 索引
create index ix_show_case on show_case (id);
create unique index uk_show_case_id on show_case (id);

-- 删除索引
drop index uk_show_case_id;

-- 修改表结构
-- not null
alter table show_case alter column col_int set not null; -- column 可以省略
alter table show_case alter column col_int set default 0;
alter table show_case alter column col_int drop not null;

-- 修改列
alter table show_case alter column col_int type bigint;

alter table show_case add column col_int_new int not null default 0;
alter table show_case rename column col_int_new to col_int_new_modify;
alter table show_case drop column col_int_new_modify;

comment on table show_case is 'sql 语句示例';
comment on column show_case.id is '主键';

select * from show_case;
