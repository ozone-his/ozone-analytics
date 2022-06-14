SELECT    visit.visit_id              AS visit_id,
          visit.patient_id            AS patient_id,
          visit_type.uuid             AS visit_type_uuid,
          visit_type.name             AS visit_type,
          visit.date_started          AS date_started,
          visit.date_stopped          AS date_stopped,
          visit.indication_concept_id AS indication_concept_id,
          visit.location_id           AS location_id,
          visit.voided                AS visit_voided,
          visit.uuid                  AS visit_uuid,
          person.person_id            AS person_id,
          person.gender               AS gender,
          person.birthdate            AS birthdate,
          person.birthdate_estimated  AS birthdate_estimated,
          CASE
                    WHEN Timestampdiff(day,person.birthdate , visit.date_started)  / 365 < 1 THEN '0 - 1'
                    WHEN Timestampdiff(day,person.birthdate , visit.date_started)  / 365 BETWEEN 1 AND       4 THEN '1 - 4'
                    WHEN Timestampdiff(day, person.birthdate , visit.date_started) / 365 BETWEEN 4 AND       9 THEN '5 - 9'
                    WHEN Timestampdiff(day, person.birthdate , visit.date_started) / 365 BETWEEN 10 AND       14 THEN '10 - 14'
                    WHEN Timestampdiff(day, person.birthdate , visit.date_started) / 365 BETWEEN 15 AND       19 THEN '15 - 19'
                    WHEN Timestampdiff(day, person.birthdate , visit.date_started) / 365 BETWEEN 20 AND       24 THEN '20 - 24'
                    WHEN Timestampdiff(day, person.birthdate , visit.date_started) / 365 > 24 THEN '25+'
                    ELSE 'Invalid birthdate'
          END                                                           AS `age_at_visit_group_profile_1`,
          timestampdiff(day, person.birthdate,visit.date_started) / 365 AS age_at_visit,
          person.dead                                                   AS dead,
          person.death_date                                             AS death_date,
          person.cause_of_death                                         AS cause_of_death,
          person.voided                                                 AS person_voided,
          person.uuid                                                   AS person_uuid
FROM      visit
LEFT JOIN visit_type  visit_type
ON        visit.visit_type_id = visit_type.visit_type_id
LEFT JOIN person person
ON        visit.patient_id = person.person_id