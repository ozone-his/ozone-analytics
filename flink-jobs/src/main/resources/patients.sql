SELECT patient.patient_id         AS id,
       name.given_name            AS given_name,
       name.middle_name           AS middle_name,
       name.family_name           AS family_name,
       identifier.identifier      AS identifier,
       person.gender              AS gender,
       person.birthdate           AS birthdate,
       person.birthdate_estimated AS birthdate_estimated,
       address.city_village       AS city,
       person.dead                AS dead,
       person.death_date          AS death_date,
       person.cause_of_death      AS cause_of_death,
       person.creator             AS creator,
       person.date_created        AS date_created,
       person.voided              AS person_voided,
       person.void_reason         AS person_void_reason
FROM   patient
       LEFT JOIN person person
              ON patient.patient_id = person.person_id
       LEFT JOIN person_name  name
              ON person.person_id = name.person_id
       LEFT JOIN person_address  address
              ON person.person_id = address.person_id
       LEFT JOIN patient_identifier identifier
              ON patient.patient_id = identifier.patient_id
