    select
        wm_poi_id,
        wm_poi_name,
        poi_level,
        poi_aor_type,
        poi_city_id,
        poi_city_name,
        activity_type,
        count(user_id) as new_user_count,
        dt
    from
    (    SELECT
            first_poi_id 	as wm_poi_id,
            poi_name		as wm_poi_name,
            poi_level,
            poi_aor_type,
            poi_city_id,
            poi_city_name,
            if(first_reduce is not null,1,
               if(
                 full_reduce is not null, 2,
                 if(
                    coupon_from_sky is not null, 9,
                   if(
                    normal_coupon is not null, 10,
                     if(
                        poi_coupon is not null, 101,
                       9998
                     )
                   )
                 )	
               )
              )				as activity_type,
            user_id,
            dt
        
        FROM
          (SELECT
              a.*,
              b.level as poi_level
          FROM 
              (
                SELECT *
                FROM
                  mart_waimaigrowth.fact_order_as_one 
                WHERE
                  dt='$now.datekey'
                AND
                   usr_first_order_dt='$now.datekey'
                AND
                    order_sorted_id=1
              )as a
          left outer join
              (select wm_poi_id, level  from mart_waimaigrowth.topic_poi_cac_set_level where dt= '$now.datekey') as b
          on
              a.first_poi_id = b.wm_poi_id
          ) as t1
     )as t2