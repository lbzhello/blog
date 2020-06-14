#%%
import tushare as ts

ts.set_token('2ea612d41ee1fdb2fed04bb097debcbcee8d43eeba5570a2605d6914')

pro = ts.pro_api()

pro.daily(trade_date='20200611')