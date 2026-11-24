select
    year,
    victim_sex,
    offender_sex,
    relationship_group,
    count(*) as victims
from {{ ref('int_homicides') }}
where is_single_offender
group by all