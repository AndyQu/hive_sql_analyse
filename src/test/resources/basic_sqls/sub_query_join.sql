select
  new.city,
  '20160601' as day
from
  (
	select 
		city 
	from 
		banner_city
	where 
		day >= '20150101'
  )as old
  right join
  (
    select
      city
    from
      (select
           city,
           count(poiid) as poi_count
        from
          (
            select
              city,
              poiid
            from
              (  
                select
                    city,
                    poiid,
                    sum(icount) as num_count
                from
                    mart_sr.poi_callnum_daily
                where
                    `day` between '20160501' and '20160601'
                group by
                    city,
                    poiid
              ) as t1
            where
              num_count>=50
          )as t2
        group by
          city
      )as t3
    where
      poi_count>=10
 )as new
on
	old.city = new.city
where
	old.city is null;