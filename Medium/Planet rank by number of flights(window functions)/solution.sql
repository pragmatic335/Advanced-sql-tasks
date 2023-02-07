with total as (select p.name planet, ps.value psystem, sum(case when f.id is null then 0 else 1 end) as count_flight
               from planet p
                        join PoliticalSystem ps on p.psystem_id = ps.id
                        left join flight f on p.id = f.planet_id
               group by p.name, ps.value)
select planet,
       psystem,
       rank() over (partition by psystem order by count_flight desc) local_rank, rank() over (order by count_flight desc) global_rank
from total