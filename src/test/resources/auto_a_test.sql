select
        this_week_uv, last_week_uv
    from
        (
        select count( uuid) as this_week_uv
        from mart_waimai.fact_xianfu_waimai_log__dt_user_first
        where 
            dt<= from_unixtime(unix_timestamp()-60*60*24,'yyyymmdd')
            and
            dt>= from_unixtime(unix_timestamp()-60*60*24*7,'yyyymmdd')
        ) as a,
        (
        select count( uuid) as last_week_uv
        from mart_waimai.fact_xianfu_waimai_log__dt_user_first
        where 
            dt<= from_unixtime(unix_timestamp()-60*60*24*8,'yyyymmdd')
            and
            dt>= from_unixtime(unix_timestamp()-60*60*24*14,'yyyymmdd')
        ) as b