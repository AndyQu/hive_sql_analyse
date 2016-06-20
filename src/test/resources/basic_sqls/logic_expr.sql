select 
count( uuid) as this_week_uv
--21-60*24
        from mart_waimai.fact_xianfu_waimai_log__dt_user_first
        where 
            dt<= 21-60*24
            and
            (
            dt>= from_unixtime(unix_timestamp()-60*60*24*7,'yyyyMMdd')
            or
            dt>= from_unixtime(unix_timestamp()-60*60*24*14,'yyyyMMdd')
            )