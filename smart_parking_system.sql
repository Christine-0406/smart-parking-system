-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: parking_system
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `parking_rate_rules`
--

DROP TABLE IF EXISTS `parking_rate_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parking_rate_rules` (
  `rule_id` int NOT NULL AUTO_INCREMENT,
  `min_occupancy` decimal(5,2) NOT NULL,
  `max_occupancy` decimal(5,2) NOT NULL,
  `multiplier` decimal(5,2) NOT NULL,
  `base_rate` decimal(10,2) NOT NULL DEFAULT '150.00',
  PRIMARY KEY (`rule_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parking_rate_rules`
--

LOCK TABLES `parking_rate_rules` WRITE;
/*!40000 ALTER TABLE `parking_rate_rules` DISABLE KEYS */;
INSERT INTO `parking_rate_rules` VALUES (1,0.00,50.00,1.00,150.00),(2,50.01,80.00,1.50,150.00),(3,80.01,100.00,2.00,150.00);
/*!40000 ALTER TABLE `parking_rate_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parking_rates`
--

DROP TABLE IF EXISTS `parking_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parking_rates` (
  `rate_id` int NOT NULL AUTO_INCREMENT,
  `vehicle_type` varchar(50) NOT NULL,
  `rate_per_hour` decimal(10,2) NOT NULL,
  PRIMARY KEY (`rate_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parking_rates`
--

LOCK TABLES `parking_rates` WRITE;
/*!40000 ALTER TABLE `parking_rates` DISABLE KEYS */;
INSERT INTO `parking_rates` VALUES (1,'Car',150.00),(2,'Motorcycle',100.00);
/*!40000 ALTER TABLE `parking_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parking_sessions`
--

DROP TABLE IF EXISTS `parking_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parking_sessions` (
  `session_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `slot_id` int NOT NULL,
  `entry_time` datetime NOT NULL,
  `exit_time` datetime DEFAULT NULL,
  `hourly_rate` decimal(10,2) DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Active',
  `amount_before_vat` decimal(10,2) DEFAULT NULL,
  `vat_amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`session_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parking_sessions`
--

LOCK TABLES `parking_sessions` WRITE;
/*!40000 ALTER TABLE `parking_sessions` DISABLE KEYS */;
INSERT INTO `parking_sessions` VALUES (2,5,1,2,'2026-09-27 16:47:52','2026-09-27 16:49:00',150.00,150.00,'Completed',NULL,NULL),(3,15,5,4,'2026-09-27 17:09:45','2026-09-27 17:10:22',150.00,150.00,'Completed',NULL,NULL),(4,15,5,1,'2026-09-27 17:47:26','2026-09-27 20:27:33',150.00,450.00,'Completed',NULL,NULL),(5,19,11,4,'2026-09-28 01:19:29','2026-09-28 09:00:11',150.00,1200.00,'Completed',NULL,NULL),(6,19,11,4,'2026-09-28 12:20:30','2026-09-28 12:44:51',150.00,150.00,'Completed',129.31,20.69),(7,5,1,3,'2026-09-28 18:28:10','2026-09-28 19:33:39',150.00,300.00,'Completed',258.62,41.38),(8,19,11,4,'2026-09-28 19:35:35','2026-09-28 19:35:40',150.00,150.00,'Completed',129.31,20.69),(9,17,9,1,'2026-09-28 19:46:09','2026-09-28 19:46:16',150.00,150.00,'Completed',129.31,20.69),(10,18,10,5,'2026-09-28 19:47:20','2026-09-28 19:47:26',100.00,100.00,'Completed',86.21,13.79),(11,15,6,2,'2026-09-28 19:57:22','2026-09-28 19:59:53',150.00,150.00,'Completed',129.31,20.69),(12,15,6,2,'2026-09-28 20:01:53','2026-09-28 20:02:03',150.00,150.00,'Completed',129.31,20.69);
/*!40000 ALTER TABLE `parking_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parking_slots`
--

DROP TABLE IF EXISTS `parking_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parking_slots` (
  `slot_id` int NOT NULL AUTO_INCREMENT,
  `slot_number` varchar(20) NOT NULL,
  `slot_type` varchar(50) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Available',
  PRIMARY KEY (`slot_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parking_slots`
--

LOCK TABLES `parking_slots` WRITE;
/*!40000 ALTER TABLE `parking_slots` DISABLE KEYS */;
INSERT INTO `parking_slots` VALUES (1,'A01','Car','Available'),(2,'A02','Car','Available'),(3,'A03','Car','Available'),(4,'A04','Car','Available'),(5,'B01','Motorcycle','Available'),(6,'B02','Motorcycle','Reserved');
/*!40000 ALTER TABLE `parking_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `session_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(30) NOT NULL,
  `payment_reference` varchar(100) DEFAULT NULL,
  `payment_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(20) NOT NULL DEFAULT 'Pending',
  PRIMARY KEY (`payment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,5,2,150.00,'Cash','TEST001','2026-09-27 16:59:08','Paid'),(2,15,3,150.00,'Cash','TEST002','2026-09-27 17:20:35','Paid'),(3,19,5,1200.00,'Cash','TEST003','2026-09-28 09:00:56','Paid'),(4,15,4,450.00,'M-Pesa','TEST004','2026-09-28 10:47:13','Paid'),(5,19,6,150.00,'Cash','TEST005','2026-09-28 12:45:30','Paid'),(6,5,7,300.00,'M-Pesa','TEST006','2026-09-28 19:34:01','Paid'),(7,19,8,150.00,'Card','TEST010','2026-09-28 19:36:05','Paid');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservations` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `slot_id` int NOT NULL,
  `reservation_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Pending',
  PRIMARY KEY (`reservation_id`),
  KEY `user_id` (`user_id`),
  KEY `vehicle_id` (`vehicle_id`),
  KEY `slot_id` (`slot_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users_test` (`user_id`),
  CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles_test` (`vehicle_id`),
  CONSTRAINT `reservations_ibfk_3` FOREIGN KEY (`slot_id`) REFERENCES `parking_slots` (`slot_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations`
--

LOCK TABLES `reservations` WRITE;
/*!40000 ALTER TABLE `reservations` DISABLE KEYS */;
/*!40000 ALTER TABLE `reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations_test`
--

DROP TABLE IF EXISTS `reservations_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservations_test` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `slot_id` int NOT NULL,
  `reservation_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Pending',
  PRIMARY KEY (`reservation_id`),
  KEY `reservations_user_fk` (`user_id`),
  CONSTRAINT `reservations_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users_test` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations_test`
--

LOCK TABLES `reservations_test` WRITE;
/*!40000 ALTER TABLE `reservations_test` DISABLE KEYS */;
/*!40000 ALTER TABLE `reservations_test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations_working`
--

DROP TABLE IF EXISTS `reservations_working`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservations_working` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `slot_id` int NOT NULL,
  `reservation_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Pending',
  `payment_method` varchar(20) DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT 'Pending',
  PRIMARY KEY (`reservation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations_working`
--

LOCK TABLES `reservations_working` WRITE;
/*!40000 ALTER TABLE `reservations_working` DISABLE KEYS */;
INSERT INTO `reservations_working` VALUES (1,5,1,3,'2026-09-28','12:18:00','15:15:00','Completed',NULL,'Pending'),(3,15,6,2,'2026-09-28','20:50:00','22:50:00','Completed',NULL,'Pending'),(4,16,8,6,'2026-09-27','20:22:00','21:22:00','Confirmed','M-Pesa','Pending'),(5,17,9,1,'2026-09-27','20:34:00','20:40:00','Completed','M-Pesa','Pending'),(6,18,10,5,'2026-09-27','21:10:00','21:11:00','Completed','M-Pesa','Pending'),(7,19,11,4,'2026-09-27','21:15:00','21:17:00','Completed','Card','Paid'),(8,19,11,4,'2026-09-28','18:30:00','19:30:00','Completed',NULL,'Not Required'),(9,15,6,2,'2026-09-28','20:01:00','21:01:00','Completed',NULL,'Not Required');
/*!40000 ALTER TABLE `reservations_working` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_test`
--

DROP TABLE IF EXISTS `user_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_test` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(30) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_test`
--

LOCK TABLES `user_test` WRITE;
/*!40000 ALTER TABLE `user_test` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_old`
--

DROP TABLE IF EXISTS `users_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_old` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(30) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_old`
--

LOCK TABLES `users_old` WRITE;
/*!40000 ALTER TABLE `users_old` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_old` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_test`
--

DROP TABLE IF EXISTS `users_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users_test` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(30) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_test`
--

LOCK TABLES `users_test` WRITE;
/*!40000 ALTER TABLE `users_test` DISABLE KEYS */;
INSERT INTO `users_test` VALUES (5,'Roy','scrypt:32768:8:1$MWTRCEEYpIUTzNYU$fd420ddde93212ef7f30f52320c79c8b6389c7b32c78a658dcd916e315cecd4b9cbac25fcb59613037d57ddcfff3e69ff1ebc1b6ad50c8afe64af3fc60f06089','client','roy@gmail.com','0712345678'),(15,'Doe','scrypt:32768:8:1$FHvHOard4pTMiiSI$5b947c0e1939e3dd80e45a19317e846112c2d8f6674632df8d02508039a1234083b1cc76b3cd172d6f04a33bc8a353190864e7d385f5c223bab49364414cec81','client','doe@gmail.com','0167890432'),(16,'Me','scrypt:32768:8:1$LOUFjmOOuO8wKPD1$1c9083fd5a57de4d2cd062edc84eda43afff633d4de873f83001b795e1b51b9fe9ef226ca8d8831c80aaf57c606b50293124d5d15c83b4d2669362e81450d95d','client','me@gmail.com','012345678'),(17,'P','scrypt:32768:8:1$0NBxyz4AwdCB4brB$9fc68cb22c0b337925c84ab96fd740fe621f5ff08a369889147d9f8d71d808a666f72b019a7d9abef61eded7ca5e5e95d332b9d2fec000747cf35f7b6a0aead6','client','p@gmail.com','123456789'),(18,'Y','scrypt:32768:8:1$Xa9kJfD7uxA5zgl8$92dc879ba30d4117acdca0b52a1723bed27e10d69be02ca8b00706bc5d713441d48e6a59cae9d4aa4013a68f862f00e7955a5a61ed8e7883cb04b26c9160e0ef','client','y@gmail.com','0876431234'),(19,'A','scrypt:32768:8:1$jN3HKgB1rf1DVjSX$8e84b3322085b37fb3738f939647bcd720ee0039bdafbf60a28304e88e6a6bcd8695694c7592a693f1a025c23fa67506ca61736e4a7efbd9e020f9d43a9a1b48','client','a@gmail.com','0123456789');
/*!40000 ALTER TABLE `users_test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicles`
--

DROP TABLE IF EXISTS `vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicles` (
  `vehicle_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `registration_number` varchar(20) NOT NULL,
  `vehicle_type` varchar(30) NOT NULL,
  `vehicle_model` varchar(50) DEFAULT NULL,
  `vehicle_color` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`vehicle_id`),
  UNIQUE KEY `registration_number` (`registration_number`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicles`
--

LOCK TABLES `vehicles` WRITE;
/*!40000 ALTER TABLE `vehicles` DISABLE KEYS */;
/*!40000 ALTER TABLE `vehicles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicles_test`
--

DROP TABLE IF EXISTS `vehicles_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicles_test` (
  `vehicle_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `registration_number` varchar(20) NOT NULL,
  `vehicle_type` varchar(50) NOT NULL,
  `vehicle_model` varchar(100) NOT NULL,
  `vehicle_color` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`vehicle_id`),
  KEY `vehicles_test_user_fk` (`user_id`),
  CONSTRAINT `vehicles_test_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users_test` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicles_test`
--

LOCK TABLES `vehicles_test` WRITE;
/*!40000 ALTER TABLE `vehicles_test` DISABLE KEYS */;
INSERT INTO `vehicles_test` VALUES (1,5,'KAZ 314','Car','GLE','Black'),(5,15,'KMP 324','Van','Suzuki','Umber'),(6,15,'KZA 543','Car','Audi','white'),(7,15,'KDZ 908','Motorcycle','BMW','Black'),(8,16,'KMR 231','Motorcycle','TVS','Red'),(9,17,'KDA 678','Car','Prado','Maroon'),(10,18,'KAD 234','Motorcycle','Honda','Blue'),(11,19,'KMD 178','Car','Mazda','Grey');
/*!40000 ALTER TABLE `vehicles_test` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `violations`
--

DROP TABLE IF EXISTS `violations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `violations` (
  `violation_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `slot_id` int DEFAULT NULL,
  `violation_type` varchar(100) NOT NULL,
  `description` text,
  `violation_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(30) DEFAULT 'Unresolved',
  PRIMARY KEY (`violation_id`),
  KEY `user_id` (`user_id`),
  KEY `vehicle_id` (`vehicle_id`),
  KEY `slot_id` (`slot_id`),
  CONSTRAINT `violations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users_test` (`user_id`),
  CONSTRAINT `violations_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles_test` (`vehicle_id`),
  CONSTRAINT `violations_ibfk_3` FOREIGN KEY (`slot_id`) REFERENCES `parking_slots` (`slot_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `violations`
--

LOCK TABLES `violations` WRITE;
/*!40000 ALTER TABLE `violations` DISABLE KEYS */;
INSERT INTO `violations` VALUES (2,5,1,1,'Unauthorized Parking','Vehicle parked without a valid reservation.','2026-09-28 01:49:11','Unresolved'),(3,19,11,4,'Overstaying','Vehicle remained in the parking slot after the reservation end time.','2026-09-28 02:26:34','Unresolved'),(4,5,1,3,'Overstaying','Vehicle remained in the parking slot after the reservation end time.','2026-09-28 18:38:07','Unresolved'),(5,17,9,1,'Overstaying','Vehicle remained in the parking slot after the reservation end time.','2026-09-28 19:46:09','Unresolved'),(6,18,10,5,'Overstaying','Vehicle remained in the parking slot after the reservation end time.','2026-09-28 19:47:20','Unresolved');
/*!40000 ALTER TABLE `violations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'parking_system'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-28 23:21:03
