with cte as (select s2.company,
                    s2.week,
                    (s2.share_price - s1.share_price) -
                    (avg(s2.share_price - s1.share_price) over (partition by s2.week)) as i
             from StockQuotes s1,
                  StockQuotes s2
             where s1.company = s2.company
               and s1.week = s2.week - 1),
     cte2 as (select *,
                     coalesce(week - (lag(week, 1) over (partition by company order by week)), week) as q
              from cte
              where cte.i > 0),
     cte3 as (select *,
                     case
                         when
                             m.q = 1
                             then
                             coalesce((select t.week
                                       from cte2 t
                                       where t.company = m.company
                                         and t.week <= m.week
                                         and t.q != 1 order by t.week desc limit 1), 1)
                         else m.week
                         end as y
              from cte2 m),
     cte4 as (select company, count(*) - 2 as total
              from cte3
              group by cte3.company, cte3.y
              having count(*) >= 3),
     cte5 as (select company, sum(total) result
              from cte4
              group by cte4.company)
select company::TEXT, result::BIGINT
from cte5