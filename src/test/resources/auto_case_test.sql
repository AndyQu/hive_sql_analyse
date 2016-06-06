select
	website website,
	shopid shopid,
	sum(
		case
        	when prev_callnum=0 or prev_callnum is null 
        		then if(callnum<20,callnum,0)
         	when prev_callnum > callnum 
         		then if(callnum<20,callnum,0)
         	when callnum >= prev_callnum 
         		then callnum - prev_callnum
         	else 0
       	end
    ) callnum,
	dt
from 
	a
where 
	case 
		when callnum<prev_callnum 
			then next_callnum<prev_callnum 
		else 1=1 
	end