select --业务类型代码
      lead(
      --业务类型代码
      	pmod(callnum, 1000), 
      	1, 
      	0
      ) over (
      	partition by websiteid, shopid, queueid 
      	order by modtime asc
       next_callnum