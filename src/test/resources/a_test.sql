select
        this_week_uv, last_week_uv
    from
        (
        select count( uuid) as this_week_uv
        from mart_waimai.fact_xianfu_waimai_log__dt_user_first
        where 
            dt<= from_unixtime(unix_timestamp()-60*60*24,'yyyyMMdd')
            and
            dt>= from_unixtime(unix_timestamp()-60*60*24*7,'yyyyMMdd')
        ) as a,
        (
        select count( uuid) as last_week_uv
        from mart_waimai.fact_xianfu_waimai_log__dt_user_first
        where 
            dt<= from_unixtime(unix_timestamp()-60*60*24*8,'yyyyMMdd')
            and
            dt>= from_unixtime(unix_timestamp()-60*60*24*14,'yyyyMMdd')
        ) as b