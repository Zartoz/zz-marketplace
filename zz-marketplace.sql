CREATE TABLE IF NOT EXISTS `marketplace_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seller_id` varchar(50) NOT NULL,
  `seller_name` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `description` text NOT NULL,
  `is_sold` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `recent_buys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `buyer_name` varchar(255) NOT NULL,
  `seller_name` varchar(255) NOT NULL,
  `bought_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
