SELECT obs.obs_id AS obs_id,
       obs.person_id AS person_id,
       concept_concept_name.name AS concept_name,
       obs.concept_id AS concept_id,
       obs.obs_group_id AS obs_group_id,
       obs.accession_number AS accession_number,
       obs.form_namespace_and_path AS form_namespace_and_path,
       obs.value_coded AS value_coded,
       value_concept_name.name AS value_coded_name,
       obs.value_coded_name_id AS value_coded_name_id,
       obs.value_drug AS value_drug,
       obs.value_datetime AS value_datetime,
       obs.value_numeric AS value_numeric,
       obs.value_modifier AS value_modifier,
       obs.value_text AS value_text,
       obs.value_complex AS value_complex,
       obs.comments AS comments,
       obs.creator AS creator,
       obs.date_created AS date_created,
       obs.voided AS obs_voided,
       obs.void_reason AS obs_void_reason,
       obs.previous_version AS previous_version,
       encounter.encounter_id AS encounter_id,
       encounter.voided AS voided_2,
       visit.visit_id AS visit_id,
       visit.date_started AS visit_date_started,
       visit.date_stopped AS visit_date_stopped,
       visit.location_id AS location_id,
       encounter_type.name AS encounter_type_name,
       encounter_type.description AS encounter_type_description,
       encounter_type.retired AS encounter_type_retired,
       encounter_type.uuid AS encounter_type_uuid,
       visit_type.name AS visit_type_name,
       visit_type.retired AS visit_type_retired,
       visit_type.uuid AS visit_type_uuid,
       location.name AS location_name,
       location.address1 AS location_address1,
       location.address2 AS location_address2,
       location.city_village AS location_city_village,
       location.state_province AS location_state_province,
       location.postal_code AS location_postal_code,
       location.country AS location_country,
       location.retired AS location_retired,
       location.uuid AS location_uuid
FROM obs
LEFT JOIN concept_name value_concept_name ON obs.value_coded = value_concept_name.concept_id
AND obs.value_coded IS NOT NULL
LEFT JOIN encounter  encounter ON obs.encounter_id = encounter.encounter_id
LEFT JOIN visit  visit ON encounter.visit_id = visit.visit_id
LEFT JOIN encounter_type  encounter_type ON encounter.encounter_type = encounter_type.encounter_type_id
LEFT JOIN visit_type  visit_type ON visit.visit_type_id = visit_type.visit_type_id
LEFT JOIN location location ON obs.location_id = location.location_id
LEFT JOIN concept_name  concept_concept_name ON obs.concept_id = concept_concept_name.concept_id