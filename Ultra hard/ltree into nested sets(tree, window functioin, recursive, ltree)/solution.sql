with recursive
    root_size as (
        select
            id,
            path,
            (select count(*) as size from keywordltree k2 where k2.path <@ k.path and k2.path != k.path) size,
            nlevel(k.path)+1 depth,
            rank() over (order by k.path) as rank
        from keywordltree k),
    result as (
        select base.id, base.value, base.path,
            1::bigint as lft,
            (select 1+(2*rz.size + 1) from root_size rz where rz.path = base.path) as rgt
        from keywordltree base
        where base.path = ''
            union all
        select step.id, step.value, step.path,
            (select rz.rank + rz.rank - rz.depth from root_size rz where rz.path = step.path) as lft,
            (select (rz.rank + rz.rank - rz.depth) + (2*rz.size+1) from root_size rz where rz.path = step.path) as rgt
        from keywordltree step
        join result on step.path <@ result.path and nlevel(step.path) - nlevel(result.path) = 1)
select id, value, lft, rgt  from result order by path