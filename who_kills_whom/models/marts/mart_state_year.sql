select
    state_name,
    year,
    count(*)                                                   as victims,
    count_if(is_solved)                                        as solved_victims,

    count_if(relationship_group = 'Intimate partner')          as partner_victims,
    count_if(relationship_group = 'Family')                    as family_victims,
    count_if(relationship_group = 'Acquaintance')              as acquaintance_victims,
    count_if(relationship_group = 'Stranger')                  as stranger_victims,
    count_if(relationship_group <> 'Unknown')                  as relationship_known_victims,

    count_if(weapon_group = 'Gun')                             as gun_victims,
    count_if(weapon_group <> 'Unknown')                        as weapon_known_victims,

    count_if(is_single_offender and offender_sex = 'Female')   as female_offender_victims,
    count_if(is_single_offender and offender_sex in ('Male', 'Female'))
                                                               as offender_sex_known_victims
from {{ ref('int_homicides') }}
group by state_name, year