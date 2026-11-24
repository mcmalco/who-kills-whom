with homicides as (
    select * from {{ ref('stg_homicides') }}
)

select
    *,

    -- How the VICTIM was related to the offender ("Wife" = victim was the offender's wife)
    case
        when relationship in ('Wife', 'Husband', 'Girlfriend', 'Boyfriend',
                              'Common-law wife', 'Common-law husband',
                              'Ex-wife', 'Ex-husband', 'Homosexual relationship')
            then 'Intimate partner'
        when relationship in ('Son', 'Daughter', 'Brother', 'Sister', 'Father', 'Mother',
                              'In-law', 'Other family', 'Stepfather', 'Stepmother',
                              'Stepson', 'Stepdaughter')
            then 'Family'
        when relationship in ('Acquaintance', 'Friend', 'Neighbor', 'Employer',
                              'Employee', 'Other - known to victim')
            then 'Acquaintance'
        when relationship = 'Stranger'
            then 'Stranger'
        else 'Unknown'
    end as relationship_group,

    case
        when weapon in ('Handgun - pistol, revolver, etc', 'Firearm, type not stated',
                        'Shotgun', 'Rifle', 'Other gun')
            then 'Gun'
        when weapon = 'Knife or cutting instrument'         then 'Knife'
        when weapon = 'Personal weapons, includes beating'  then 'Hands/feet'
        when weapon = 'Blunt object - hammer, club, etc'    then 'Blunt object'
        when weapon in ('Strangulation - hanging',
                        'Asphyxiation - includes death by gas') then 'Strangulation'
        when weapon in ('Other or type unknown', 'Weapon Not Reported') then 'Unknown'
        else 'Other'
    end as weapon_group,

    additional_offenders = 0 as is_single_offender

from homicides