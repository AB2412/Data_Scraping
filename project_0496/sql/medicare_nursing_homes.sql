CREATE TABLE `medicare_nursing_homes`
(
  `id` bigint NOT NULL AUTO_INCREMENT,
  `run_id` int DEFAULT NULL,
  `nursing_home_name` varchar(255) DEFAULT NULL,
  `nursing_home_address` varchar(255) DEFAULT NULL,
  `nursing_home_city` varchar(255) DEFAULT NULL,
  `nursing_home_zip_code` varchar(255) DEFAULT NULL,
  `nursing_home_state` varchar(255) DEFAULT NULL,
  `nursing_home_phone_number` varchar(255) DEFAULT NULL,
  `certified_beds_number` varchar(255) DEFAULT NULL,
  `data_source_url` varchar(255) DEFAULT NULL,
  `touched_run_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(255) DEFAULT 'Aqeel',
  `md5_hash` varchar(255) GENERATED ALWAYS AS (md5(concat_ws('',`nursing_home_name`,`nursing_home_address`,`nursing_home_city`,`nursing_home_state`,`nursing_home_zip_code`,`certified_beds_number`))) STORED UNIQUE KEY,
  PRIMARY KEY (`id`)
)
