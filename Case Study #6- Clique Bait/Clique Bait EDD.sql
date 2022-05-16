CREATE TABLE `event_identifier` (
  `event_type` INTEGER,
  `event_name` VARCHAR(13)
);

CREATE TABLE `campaign_identifier` (
  `campaign_id` INTEGER,
  `products` VARCHAR(3),
  `campaign_name` VARCHAR(33),
  `start_date` TIMESTAMP,
  `end_date` TIMESTAMP
);

CREATE TABLE `page_hierarchy` (
  `page_id` INTEGER,
  `page_name` VARCHAR(14),
  `product_category` VARCHAR(9),
  `product_id` INTEGER
);

CREATE TABLE `users` (
  `user_id` INTEGER,
  `cookie_id` VARCHAR(6),
  `start_date` TIMESTAMP
);

CREATE TABLE `events` (
  `visit_id` VARCHAR(6),
  `cookie_id` VARCHAR(6),
  `page_id` INTEGER,
  `event_type` INTEGER,
  `sequence_number` INTEGER,
  `event_time` TIMESTAMP
);

ALTER TABLE `events` ADD FOREIGN KEY (`cookie_id`) REFERENCES `users` (`cookie_id`);

ALTER TABLE `event_identifier` ADD FOREIGN KEY (`event_type`) REFERENCES `events` (`event_type`);

ALTER TABLE `events` ADD FOREIGN KEY (`page_id`) REFERENCES `page_hierarchy` (`page_id`);

ALTER TABLE `campaign_identifier` ADD FOREIGN KEY (`start_date`) REFERENCES `users` (`start_date`);
