with distance as (select t1.id, abs(t1.value - t2.value) s
                  from T t1,
                       T t2),
     distance_sum as (select id, sum(s) su
                      from distance
                      group by distance.id),
     distance_min as (select min(su) m
                      from distance_sum)
select main.value, (select count(*) from T)
from distance_sum d
         join T main on main.id = d.id
where d.su = (select * from distance_min)