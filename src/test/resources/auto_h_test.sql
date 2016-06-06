select
    website website,
  shopid shopid,
  sum(case
         when prev_callnum=0 or prev_callnum is null then if(callnum<20,callnum,0)
         when prev_callnum > callnum then if(callnum<20,callnum,0)
         when callnum >= prev_callnum then callnum - prev_callnum
         else 0
       end) callnum,
  dt
from 


(select
 websiteid website,
        shopid shopid,
        pmod(callnum, 1000) callnum,
      lead(pmod(callnum, 1000), 1, 0) over (partition by websiteid, shopid, queueid order by modtime desc) prev_callnum,
      lead(pmod(callnum, 1000), 1, 0) over (partition by websiteid, shopid, queueid order by modtime asc) next_callnum,
      dt 
from 
(
  select
        websiteid websiteid,
        shopid shopid,
        pmod(callnum, 1000) callnum,
      lead(pmod(callnum, 1000), 1, 0) over (partition by websiteid, shopid, queueid order by modtime desc) prev_callnum,
      lead(pmod(callnum, 1000), 1, 0) over (partition by websiteid, shopid, queueid order by modtime asc) next_callnum,
      dt,queueid,modtime
    from origin_cis.poi_callnum_history a
    where dt between '$now.delta(1).datekey' and '$now.datekey' and modtime > 3600 * 2

) a
where case when callnum<prev_callnum then next_callnum<prev_callnum else 1=1 end
) result