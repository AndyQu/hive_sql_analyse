select
          version,
          count(distinct appkey) as total_count
          
      from
          origindb.sr__tb_queue_app
      group by
          version