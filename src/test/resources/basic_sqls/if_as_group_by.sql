select
      	rest_id,
      	rest_name,
      	week_day_type,
      	start_hour,
      	start_minute,
      	end_hour,
      	end_minute,
      	if(week_day_type==1, count(*)/(6*2), count(*)/(6*5) )as estimate_state
      from
        (
            select
                rest_id,
                rest_name,
                if(from_unixtime(unix_timestamp(time_from), 'u')>=6,1,0)		as week_day_type,
                hour(time_from)													as start_hour,
                if(minute(time_from)>30,30,0)									as start_minute,
                if(minute(time_from)>30,hour(time_from)+1, hour(time_from))		as end_hour,
                if(minute(time_from)>30,0,30)									as end_minute
            from	
                mart_sr.queue_item
            where
                time_from >= from_unixtime(unix_timestamp('20160501','yyyymmdd'),'yyyy-mm-dd hh:mm:ss')
          		and
          		(
                  (hour(time_from)>=10 and hour(time_from)<=15)
                  or
                  (hour(time_from)>=17 and hour(time_from)<=21)
                )
          		
        )as t1
      group by
      	rest_id,
      	rest_name,
      	week_day_type,
      	start_hour,
      	start_minute,
      	end_hour,
      	end_minute