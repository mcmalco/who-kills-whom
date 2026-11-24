with source as (
    select * from {{ source('raw', 'shr_homicides') }}
)

select
    id                                      as homicide_id,
    try_to_number(year)                     as year,
    month                                   as month_name,
    state                                   as state_name,
    cntyfips                                as county_name,
    msa                                     as metro_area,
    agentype                                as agency_type,
    solved = 'Yes'                          as is_solved,
    situation,
    nullif(try_to_number(vicage), 999)      as victim_age,
    vicsex                                  as victim_sex,
    vicrace                                 as victim_race,
    nullif(try_to_number(offage), 999)      as offender_age,
    offsex                                  as offender_sex,
    offrace                                 as offender_race,
    weapon,
    relationship,
    circumstance,
    try_to_number(viccount)                 as additional_victims,
    try_to_number(offcount)                 as additional_offenders
from source
where homicide = 'Murder and non-negligent manslaughter'