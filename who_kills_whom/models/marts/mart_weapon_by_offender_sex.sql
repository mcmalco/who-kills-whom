select
    year,
    offender_sex,
    weapon_group,
    count(distinct incident_id) as killings
from {{ ref('int_homicides') }}
where is_single_offender
  and offender_sex in ('Male', 'Female')
group by all