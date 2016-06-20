select * 
from a
cluster by `record_date`
distribute by `record_date`,`source_system`, `business_type`
sort by `record_date` asc, `source_system` desc