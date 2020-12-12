drop table if exists k_line_5;
create table k_line_5 (
	stock_code integer not null,
	open numeric(5, 2) not null default 0.00,
	close numeric(5, 2) not null default 0.00,
	high numeric(5, 2) not null default 0.00,
	low numeric(5, 2) not null default 0.00,
	turnover_rate numeric(4, 2) not null default 0.00
);

alter table k_line_5 add constraint k_line_5_pk primary key (stock_code);

comment on table k_line_5 is '5 分钟  K 线';
comment on column k_line_5.stock_code is '股票数字代码';