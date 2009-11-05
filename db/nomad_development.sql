-- MySQL dump 10.9
--
-- Host: sakai.trigger.biz    Database: nomad_development
-- ------------------------------------------------------
-- Server version	4.1.13-standard

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE="NO_AUTO_VALUE_ON_ZERO" */;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
CREATE TABLE `addresses` (
  `id` bigint(20) NOT NULL default '0',
  `first_name` varchar(40) default NULL,
  `last_name` varchar(40) default NULL,
  `email` varchar(100) default NULL,
  `company` varchar(80) default NULL,
  `phone` varchar(12) default NULL,
  `address_line_1` varchar(50) default NULL,
  `address_line_2` varchar(50) default NULL,
  `city` varchar(25) default NULL,
  `state` char(2) default NULL,
  `zip` varchar(10) default NULL,
  `country` varchar(25) default NULL,
  `customer_id` bigint(20) NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `addresses`
--


/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
LOCK TABLES `addresses` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;

--
-- Table structure for table `addresses_orders`
--

DROP TABLE IF EXISTS `addresses_orders`;
CREATE TABLE `addresses_orders` (
  `order_id` bigint(20) default NULL,
  `address_id` bigint(20) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `addresses_orders`
--


/*!40000 ALTER TABLE `addresses_orders` DISABLE KEYS */;
LOCK TABLES `addresses_orders` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `addresses_orders` ENABLE KEYS */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers` (
  `id` bigint(20) NOT NULL auto_increment,
  `user_name` varchar(50) NOT NULL default '',
  `real_name` varchar(80) default NULL,
  `password` varchar(50) NOT NULL default '',
  `created_on` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customers`
--


/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
LOCK TABLES `customers` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;

--
-- Table structure for table `lineitem_product_options`
--

DROP TABLE IF EXISTS `lineitem_product_options`;
CREATE TABLE `lineitem_product_options` (
  `lineitem_id` int(10) unsigned default NULL,
  `product_option_value_id` int(10) unsigned default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `lineitem_product_options`
--


/*!40000 ALTER TABLE `lineitem_product_options` DISABLE KEYS */;
LOCK TABLES `lineitem_product_options` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `lineitem_product_options` ENABLE KEYS */;

--
-- Table structure for table `lineitems`
--

DROP TABLE IF EXISTS `lineitems`;
CREATE TABLE `lineitems` (
  `id` bigint(20) unsigned NOT NULL auto_increment,
  `order_id` bigint(20) unsigned default NULL,
  `product_id` int(10) unsigned default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `lineitems`
--


/*!40000 ALTER TABLE `lineitems` DISABLE KEYS */;
LOCK TABLES `lineitems` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `lineitems` ENABLE KEYS */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` bigint(20) unsigned NOT NULL auto_increment,
  `customer_id` bigint(20) unsigned NOT NULL default '0',
  `sales_rep_id` int(11) unsigned default NULL,
  `active` tinyint(4) unsigned NOT NULL default '0',
  `on_account` tinyint(4) unsigned NOT NULL default '0',
  `shipping_method_id` int(11) unsigned default NULL,
  `submit_method_id` int(11) unsigned default NULL,
  `proof_method_id` int(11) unsigned default NULL,
  `color_type` tinyint(4) unsigned default NULL,
  `due_date` date default NULL,
  `ca_resale` varchar(50) default NULL,
  `ps_num` int(11) default NULL,
  `created_on` datetime default NULL,
  `modified_on` datetime default NULL,
  `customer_notes` text,
  `prepress_notes` text,
  `press_notes` text,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orders`
--


/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
LOCK TABLES `orders` WRITE;
UNLOCK TABLES;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;

--
-- Table structure for table `product_option_values`
--

DROP TABLE IF EXISTS `product_option_values`;
CREATE TABLE `product_option_values` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `product_option_id` varchar(50) default NULL,
  `label` varchar(50) default NULL,
  `kind` enum('Fixed','Area','Quantity','Both') default NULL,
  `price_per_unit` float default NULL,
  `unit_quantity` int(10) NOT NULL default '0',
  `price_per_sqin` float default NULL,
  `price_rule` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product_option_values`
--


/*!40000 ALTER TABLE `product_option_values` DISABLE KEYS */;
LOCK TABLES `product_option_values` WRITE;
INSERT INTO `product_option_values` VALUES (1,'2','Text','Area',NULL,1000,0.5146,NULL),(2,'2','9pt Cover','Area',NULL,1000,0.61526,NULL),(3,'2','12pt Cover','Area',NULL,1000,0.6883,NULL),(4,'3','U.V.','Area',NULL,1000,0.0487013,NULL),(5,'3','Aqueus Matte','Area',NULL,1000,0.0243507,NULL),(7,'7','1 Fold','Quantity',15,1000000,NULL,NULL),(8,'7','2 Folds','Quantity',20,1000000,NULL,NULL),(9,'7','3 Folds','Quantity',25,1000000,NULL,NULL),(10,'5','','Quantity',10,1000000,NULL,NULL),(11,'6','','Quantity',15,1000000,NULL,NULL);
UNLOCK TABLES;
/*!40000 ALTER TABLE `product_option_values` ENABLE KEYS */;

--
-- Table structure for table `product_options`
--

DROP TABLE IF EXISTS `product_options`;
CREATE TABLE `product_options` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(20) default NULL,
  `setup_price` float default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product_options`
--


/*!40000 ALTER TABLE `product_options` DISABLE KEYS */;
LOCK TABLES `product_options` WRITE;
INSERT INTO `product_options` VALUES (1,'Ink',NULL),(2,'Paper',NULL),(3,'Coating',NULL),(4,'Turnaround',NULL),(5,'3 Hole Punch',15),(6,'Perferation',15),(7,'Folding',20),(8,'Shipping',NULL),(9,'Proofing',NULL),(10,'Envelopes',NULL),(11,'Diecutting',NULL),(12,'Slot',NULL),(13,'Mailing',20);
UNLOCK TABLES;
/*!40000 ALTER TABLE `product_options` ENABLE KEYS */;

--
-- Table structure for table `product_options_products`
--

DROP TABLE IF EXISTS `product_options_products`;
CREATE TABLE `product_options_products` (
  `product_id` int(10) unsigned default NULL,
  `product_option_id` int(10) unsigned default NULL,
  `required` tinyint(4) default NULL,
  `product_option_value_id` int(10) unsigned default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product_options_products`
--


/*!40000 ALTER TABLE `product_options_products` DISABLE KEYS */;
LOCK TABLES `product_options_products` WRITE;
INSERT INTO `product_options_products` VALUES (1,2,1,3),(1,3,1,4),(2,2,1,1),(2,7,1,NULL);
UNLOCK TABLES;
/*!40000 ALTER TABLE `product_options_products` ENABLE KEYS */;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `sku` varchar(10) default NULL,
  `height` float default NULL,
  `width` float default NULL,
  `title` varchar(50) default NULL,
  `description` varchar(255) default NULL,
  `setup_price` float default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `products`
--


/*!40000 ALTER TABLE `products` DISABLE KEYS */;
LOCK TABLES `products` WRITE;
INSERT INTO `products` VALUES (1,'post46',8.5,6,'8.5\" x 6\" Postcard',NULL,1.08442),(2,'broch',11,8.5,'Brochure',NULL,1.42857);
UNLOCK TABLES;
/*!40000 ALTER TABLE `products` ENABLE KEYS */;

--
-- Table structure for table `proof_methods`
--

DROP TABLE IF EXISTS `proof_methods`;
CREATE TABLE `proof_methods` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `proof_methods`
--


/*!40000 ALTER TABLE `proof_methods` DISABLE KEYS */;
LOCK TABLES `proof_methods` WRITE;
INSERT INTO `proof_methods` VALUES (1,'PDF/JPEG'),(2,'Composite');
UNLOCK TABLES;
/*!40000 ALTER TABLE `proof_methods` ENABLE KEYS */;

--
-- Table structure for table `quantities`
--

DROP TABLE IF EXISTS `quantities`;
CREATE TABLE `quantities` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `first` int(10) unsigned default NULL,
  `last` int(10) unsigned default NULL,
  `step` int(10) unsigned default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `quantities`
--


/*!40000 ALTER TABLE `quantities` DISABLE KEYS */;
LOCK TABLES `quantities` WRITE;
INSERT INTO `quantities` VALUES (1,500,4000,500),(2,5000,15000,1000),(3,20000,50000,10000);
UNLOCK TABLES;
/*!40000 ALTER TABLE `quantities` ENABLE KEYS */;

--
-- Table structure for table `sales_reps`
--

DROP TABLE IF EXISTS `sales_reps`;
CREATE TABLE `sales_reps` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sales_reps`
--


/*!40000 ALTER TABLE `sales_reps` DISABLE KEYS */;
LOCK TABLES `sales_reps` WRITE;
INSERT INTO `sales_reps` VALUES (1,'WebSales');
UNLOCK TABLES;
/*!40000 ALTER TABLE `sales_reps` ENABLE KEYS */;

--
-- Table structure for table `shipping_methods`
--

DROP TABLE IF EXISTS `shipping_methods`;
CREATE TABLE `shipping_methods` (
  `id` tinyint(4) NOT NULL auto_increment,
  `name` varchar(25) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `shipping_methods`
--


/*!40000 ALTER TABLE `shipping_methods` DISABLE KEYS */;
LOCK TABLES `shipping_methods` WRITE;
INSERT INTO `shipping_methods` VALUES (1,'Pick Up'),(2,'Overnight');
UNLOCK TABLES;
/*!40000 ALTER TABLE `shipping_methods` ENABLE KEYS */;

--
-- Table structure for table `submit_methods`
--

DROP TABLE IF EXISTS `submit_methods`;
CREATE TABLE `submit_methods` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `submit_methods`
--


/*!40000 ALTER TABLE `submit_methods` DISABLE KEYS */;
LOCK TABLES `submit_methods` WRITE;
INSERT INTO `submit_methods` VALUES (1,'Client Upload');
UNLOCK TABLES;
/*!40000 ALTER TABLE `submit_methods` ENABLE KEYS */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

