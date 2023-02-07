with recursive subtree as (select *, array[k.id] as roots, 1 as level
                           from keyword k
                           where k.id = 0
                           union
                           select k.*, array_append(st.roots, k.id) as roots, st.level + 1
                           from subtree st
                                    join keyword k on k.parent_id = st.id)
select k.id, sum(case when st.id is null then 1 else 1 end) as subtree_size
from keyword k
         left join subtree st on k.id = any (st.roots)
group by k.id