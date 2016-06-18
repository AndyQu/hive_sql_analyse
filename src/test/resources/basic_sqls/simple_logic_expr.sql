select count( uuid) as this_week_uv
        from mart_waimai.fact_xianfu_waimai_log__dt_user_first
        where 
        	dt!=1
        	and
            (dt>= 2
            or
            dt>= 3)
