CREATE DATABASE  IF NOT EXISTS `stats` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `stats`;
-- MySQL dump 10.13  Distrib 5.7.17, for Win64 (x86_64)
--
-- Host: localhost    Database: stats
-- ------------------------------------------------------
-- Server version	5.7.19-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `exp_detail`
--

DROP TABLE IF EXISTS `exp_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exp_detail` (
  `session_id` int(11) NOT NULL AUTO_INCREMENT,
  `exp_id` int(11) NOT NULL,
  `control_val` int(11) DEFAULT NULL,
  `exp_val` int(11) DEFAULT NULL,
  PRIMARY KEY (`session_id`),
  KEY `fk_exp_detail_experiments1_idx` (`exp_id`),
  CONSTRAINT `fk_exp_detail_experiments1` FOREIGN KEY (`exp_id`) REFERENCES `experiments` (`exp_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exp_detail`
--

LOCK TABLES `exp_detail` WRITE;
/*!40000 ALTER TABLE `exp_detail` DISABLE KEYS */;
INSERT INTO `exp_detail` VALUES (1,1,5,4),(2,1,3,3),(3,1,3,5),(8,3,23,16),(9,3,15,21),(10,3,16,16),(11,3,25,11),(12,3,20,24),(13,3,17,21),(14,3,18,18),(15,3,14,15),(16,3,12,19),(17,3,19,22),(18,3,21,13),(19,3,22,24),(27,2,7,16),(28,2,8,15),(29,2,6,18),(30,2,7,10);
/*!40000 ALTER TABLE `exp_detail` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER hypothesis_update
	BEFORE INSERT ON exp_detail
    FOR EACH ROW
BEGIN
DECLARE update_val TINYINT;
DECLARE control_mean DOUBLE;
DECLARE experimental_mean DOUBLE;
DECLARE control_var DOUBLE;
DECLARE experimental_var DOUBLE;
DECLARE pooled_var DOUBLE;
DECLARE t_calc DOUBLE;
DECLARE t_table DECIMAL(4,3);
DECLARE degrees_freedom INT;

	SET control_mean = (SELECT SUM(control_val)/COUNT(control_val) FROM exp_detail WHERE exp_id = NEW.exp_id);
	SET experimental_mean = (SELECT SUM(exp_val)/COUNT(exp_val) FROM exp_detail WHERE exp_id = NEW.exp_id);
	SET control_var = (SELECT SUM(POWER((control_val - control_mean), 2))/(COUNT(control_val) - 1) FROM exp_detail WHERE exp_id = NEW.exp_id);
	SET experimental_var = (SELECT SUM(POWER((exp_val - experimental_mean), 2))/(COUNT(exp_val) - 1) FROM exp_detail WHERE exp_id = NEW.exp_id);
    SET degrees_freedom = (SELECT (COUNT(control_val)+COUNT(exp_val)-2) FROM exp_detail WHERE exp_id = NEW.exp_id);
    SET pooled_var = (SELECT (((COUNT(control_val)-1)*control_var)+((COUNT(exp_val)-1)*experimental_var))/degrees_freedom FROM exp_detail WHERE exp_id = NEW.exp_id);
    SET t_calc = (SELECT ((control_mean - experimental_mean)/SQRT((pooled_var/COUNT(control_val))+(pooled_var/COUNT(exp_val)))) FROM exp_detail WHERE exp_id = NEW.exp_id);
    SET t_table = (SELECT t_val FROM t_dist_values WHERE degree_freedom = degrees_freedom);
    
    IF  (t_calc < t_table) AND (t_calc > (-1.0*t_table)) THEN
		SET update_val = 1;
	ELSE
		SET update_val = 0;
	END IF;
    UPDATE experiments SET result_null_true = update_val WHERE exp_id = NEW.exp_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER hypothesis_on_update
	BEFORE UPDATE ON exp_detail
    FOR EACH ROW
BEGIN
DECLARE update_val TINYINT;
DECLARE control_mean DOUBLE;
DECLARE experimental_mean DOUBLE;
DECLARE control_var DOUBLE;
DECLARE experimental_var DOUBLE;
DECLARE pooled_var DOUBLE;
DECLARE t_calc DOUBLE;
DECLARE t_table DECIMAL(4,3);
DECLARE degrees_freedom INT;

	SET control_mean = (SELECT SUM(control_val)/COUNT(control_val) FROM exp_detail WHERE exp_id = NEW.exp_id);
	SET experimental_mean = (SELECT SUM(exp_val)/COUNT(exp_val) FROM exp_detail WHERE exp_id = NEW.exp_id);
	SET control_var = (SELECT SUM(POWER((control_val - control_mean), 2))/(COUNT(control_val) - 1) FROM exp_detail WHERE exp_id = NEW.exp_id);
	SET experimental_var = (SELECT SUM(POWER((exp_val - experimental_mean), 2))/(COUNT(exp_val) - 1) FROM exp_detail WHERE exp_id = NEW.exp_id);
    SET degrees_freedom = (SELECT (COUNT(control_val)+COUNT(exp_val)-2) FROM exp_detail WHERE exp_id = NEW.exp_id);
    SET pooled_var = (SELECT (((COUNT(control_val)-1)*control_var)+((COUNT(exp_val)-1)*experimental_var))/degrees_freedom FROM exp_detail WHERE exp_id = NEW.exp_id);
    SET t_calc = (SELECT ((control_mean - experimental_mean)/SQRT((pooled_var/COUNT(control_val))+(pooled_var/COUNT(exp_val)))) FROM exp_detail WHERE exp_id = NEW.exp_id);
    SET t_table = (SELECT t_val FROM t_dist_values WHERE degree_freedom = degrees_freedom);
    
    IF  (t_calc < t_table) AND (t_calc > (-1.0*t_table)) THEN
		SET update_val = 1;
	ELSE
		SET update_val = 0;
	END IF;
    UPDATE experiments SET result_null_true = update_val WHERE exp_id = NEW.exp_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `exp_type`
--

DROP TABLE IF EXISTS `exp_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exp_type` (
  `type_id` int(11) NOT NULL AUTO_INCREMENT,
  `type_name` varchar(45) NOT NULL,
  `quantitative` tinyint(4) NOT NULL,
  `num_of_samples` int(11) DEFAULT NULL,
  `related_samples` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exp_type`
--

LOCK TABLES `exp_type` WRITE;
/*!40000 ALTER TABLE `exp_type` DISABLE KEYS */;
INSERT INTO `exp_type` VALUES (1,'t-test',1,2,2),(2,'f-test',1,2,1),(3,'t-test',1,2,1),(4,'t-test',1,1,2);
/*!40000 ALTER TABLE `exp_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experimenter_to_exp`
--

DROP TABLE IF EXISTS `experimenter_to_exp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `experimenter_to_exp` (
  `expr_exp_id` int(11) NOT NULL AUTO_INCREMENT,
  `experimenter_id` int(11) NOT NULL,
  `exp_id` int(11) NOT NULL,
  PRIMARY KEY (`expr_exp_id`),
  KEY `fk_experimenter_to_exp_experimenters_idx` (`experimenter_id`),
  KEY `fk_experimenter_to_exp_experiments1_idx` (`exp_id`),
  CONSTRAINT `fk_experimenter_to_exp_experimenters` FOREIGN KEY (`experimenter_id`) REFERENCES `experimenters` (`experimenter_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_experimenter_to_exp_experiments1` FOREIGN KEY (`exp_id`) REFERENCES `experiments` (`exp_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experimenter_to_exp`
--

LOCK TABLES `experimenter_to_exp` WRITE;
/*!40000 ALTER TABLE `experimenter_to_exp` DISABLE KEYS */;
INSERT INTO `experimenter_to_exp` VALUES (1,1,1),(2,2,2),(3,4,3),(4,1,3);
/*!40000 ALTER TABLE `experimenter_to_exp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experimenters`
--

DROP TABLE IF EXISTS `experimenters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `experimenters` (
  `experimenter_id` int(11) NOT NULL AUTO_INCREMENT,
  `experimenter_name` varchar(100) NOT NULL,
  `experimenter_employed_at` varchar(100) NOT NULL,
  PRIMARY KEY (`experimenter_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experimenters`
--

LOCK TABLES `experimenters` WRITE;
/*!40000 ALTER TABLE `experimenters` DISABLE KEYS */;
INSERT INTO `experimenters` VALUES (1,'John Doe','Northeastern University'),(2,'B. F. Skinner','Harvard University'),(3,'Sigmund Freud','University of Vienna'),(4,'Jane Doe','Massachusetts General Hospital'),(5,'Jim Halpert','Dunder Mifflin');
/*!40000 ALTER TABLE `experimenters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiments`
--

DROP TABLE IF EXISTS `experiments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `experiments` (
  `exp_id` int(11) NOT NULL AUTO_INCREMENT,
  `type_id` int(11) NOT NULL,
  `exp_name` varchar(100) NOT NULL,
  `exp_date` date NOT NULL,
  `exp_desc` varchar(500) NOT NULL,
  `table_name` varchar(45) DEFAULT NULL,
  `null_hypothesis` varchar(100) NOT NULL,
  `alternate_hypothesis` varchar(100) NOT NULL,
  `alpha` decimal(4,3) NOT NULL,
  `result_null_true` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`exp_id`),
  KEY `fk_experiments_exp_type_idx` (`type_id`),
  CONSTRAINT `fk_experiments_exp_type` FOREIGN KEY (`type_id`) REFERENCES `exp_type` (`type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiments`
--

LOCK TABLES `experiments` WRITE;
/*!40000 ALTER TABLE `experiments` DISABLE KEYS */;
INSERT INTO `experiments` VALUES (1,1,'ADHD experimental procedure','2017-12-03','check for improvement for kids with ADHD and kids who do not have ADHD after experimental procedure.','','There is no change in attention span.','There is a change in attention span.',0.950,1),(2,1,'corn field test','2017-12-04','comparing between two corn fields when additive agent is not added and when additive agent is added.','','additive agent makes no difference','additive agent makes a difference',0.950,0),(3,1,'Muscle Atrophy after Drug X','2017-12-03','To check if there was a change in muscle atrophy after giving drug X to one group of subjects.','','There is no change in muscle atrophy.','There is a change in muscle atrophy.',0.950,1);
/*!40000 ALTER TABLE `experiments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `t_dist_values`
--

DROP TABLE IF EXISTS `t_dist_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `t_dist_values` (
  `degree_freedom` int(11) NOT NULL AUTO_INCREMENT,
  `alpha` decimal(4,3) NOT NULL,
  `t_val` decimal(4,3) NOT NULL,
  PRIMARY KEY (`degree_freedom`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `t_dist_values`
--

LOCK TABLES `t_dist_values` WRITE;
/*!40000 ALTER TABLE `t_dist_values` DISABLE KEYS */;
INSERT INTO `t_dist_values` VALUES (1,0.950,1.270),(2,0.950,4.303),(3,0.950,3.182),(4,0.950,2.776),(5,0.950,2.571),(6,0.950,2.447),(7,0.950,2.365),(8,0.950,2.306),(9,0.950,2.262),(10,0.950,2.228),(11,0.950,2.201),(12,0.950,2.179),(13,0.950,2.160),(14,0.950,2.145),(15,0.950,2.131),(16,0.950,2.120),(17,0.950,2.110),(18,0.950,2.101),(19,0.950,2.093),(20,0.950,2.086),(21,0.950,2.080),(22,0.950,2.074),(23,0.950,2.069),(24,0.950,2.064),(25,0.950,2.060),(26,0.950,2.056);
/*!40000 ALTER TABLE `t_dist_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'stats'
--

--
-- Dumping routines for database 'stats'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-12-07 18:51:47
