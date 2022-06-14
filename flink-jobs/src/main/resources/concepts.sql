SELECT `concept`.`concept_id` AS `concept_id`,
       `concept_reference_source`.`name` AS `Concept Mapping Source`,
       `concept_reference_term`.`code` AS `Concept Mapping Code`,
       `concept_reference_term`.`name` AS `Concept Mapping Name`,
       `concept_name`.`name` AS `name`,
       `concept_name`.`locale` AS `locale`,
       `concept_name`.`locale_preferred` AS `locale_preferred`,
       `concept`.`retired` AS `retired`,
       `concept`.`uuid` AS `uuid`
FROM `concept`
LEFT JOIN `concept_reference_map` `concept_reference_map` ON `concept`.`concept_id` = `concept_reference_map`.`concept_id`
LEFT JOIN `concept_reference_term`   `concept_reference_term` ON `concept_reference_map`.`concept_reference_term_id` = `concept_reference_term`.`concept_reference_term_id`
LEFT JOIN `concept_reference_source`  `concept_reference_source` ON `concept_reference_term`.`concept_source_id` = `concept_reference_source`.`concept_source_id`
LEFT JOIN `concept_name`  `concept_name` ON `concept`.`concept_id` = `concept_name`.`concept_id`