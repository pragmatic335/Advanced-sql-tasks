with recursive
    result as (select c.id, c.value, ARRAY[c.id] as sets, 1 as level
               from cities c
               where c.id = 0
               union all
               select c.id, c.value, array_append(r.sets, c.id) as sets, r.level + 1
               from cities c
                        join result r
                             on lower(left (c.value, 1)) = lower(right (r.value, 1)) and r.value != c.value and array_position(r.sets, c.id) is null
    )
select id, value, level as num
from result