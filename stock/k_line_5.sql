drop table if exists k_line;
create table k_line (
	stock_code integer not null,
	start_time timestamp(0) with time zone not null default now(),
	end_time timestamp(0) with time zone not null default now(),
	open numeric(7, 2) not null default 0.00,
	close numeric(7, 2) not null default 0.00,
	high numeric(7, 2) not null default 0.00,
	low numeric(7, 2) not null default 0.00,
	volume integer not null default 0,
	turnover numeric(14, 2) not null default 0.00,
	volume_ratio numeric(6, 2) not null default 0.00,
	turnover_rate numeric(6, 2) not null default 0.00,
	committee numeric(5, 2) not null default 0.00,
	selling numeric(14, 2) not null default 0.00,
	buying numeric(14, 2) not null default 0.00
);

alter table k_line add constraint k_line_pk primary key (stock_code);

comment on table k_line is '5 分钟  K 线';
comment on column k_line.stock_code is '股票数字代码';
comment on column k_line.open is '开盘价';
comment on column k_line.close is '收盘价';
comment on column k_line.high is '最高价';
comment on column k_line.low is '最低价';
comment on column k_line.volume is '成交量';
comment on column k_line.turnover is '成交额';
comment on column k_line.volume_ratio is '量比';
comment on column k_line.turnover_rate is '换手率';
comment on column k_line.committee is '委比';
comment on column k_line.buying is '买盘/内盘';
comment on column k_line.selling is '卖盘/外盘';