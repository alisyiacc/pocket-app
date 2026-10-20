-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: localhost    Database: pocket
-- ------------------------------------------------------
-- Server version	8.4.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friendships`
--

DROP TABLE IF EXISTS `friendships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friendships` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `friend_id` bigint unsigned NOT NULL,
  `status` enum('pending','accepted') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `friendships_user_id_friend_id_unique` (`user_id`,`friend_id`),
  KEY `friendships_friend_id_status_index` (`friend_id`,`status`),
  CONSTRAINT `friendships_friend_id_foreign` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `friendships_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friendships`
--

LOCK TABLES `friendships` WRITE;
/*!40000 ALTER TABLE `friendships` DISABLE KEYS */;
INSERT INTO `friendships` VALUES (1,1,2,'accepted','2026-10-15 00:49:09','2026-10-15 00:50:51'),(2,3,2,'accepted','2026-10-15 01:06:54','2026-10-15 01:09:46'),(3,3,1,'pending','2026-10-15 01:06:56','2026-10-15 01:06:56'),(4,4,1,'pending','2026-10-16 03:15:28','2026-10-16 03:15:28'),(5,5,4,'pending','2026-10-17 20:23:39','2026-10-17 20:23:39'),(6,6,2,'pending','2026-10-17 21:19:36','2026-10-17 21:19:36'),(7,7,2,'accepted','2026-10-17 21:28:18','2026-10-17 21:29:49');
/*!40000 ALTER TABLE `friendships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sender_id` bigint unsigned NOT NULL,
  `receiver_id` bigint unsigned NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `snap_id` bigint unsigned DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `messages_snap_id_foreign` (`snap_id`),
  KEY `messages_sender_id_receiver_id_index` (`sender_id`,`receiver_id`),
  KEY `messages_receiver_id_read_at_index` (`receiver_id`,`read_at`),
  CONSTRAINT `messages_receiver_id_foreign` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_snap_id_foreign` FOREIGN KEY (`snap_id`) REFERENCES `snaps` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,1,2,'p',NULL,'2026-10-17 21:23:24','2026-10-15 01:08:42','2026-10-17 21:23:24'),(2,3,2,'hai sisii',NULL,NULL,'2026-10-17 20:28:17','2026-10-17 20:28:17'),(3,1,2,'aw',6,'2026-10-17 21:23:24','2026-10-17 21:00:47','2026-10-17 21:23:24'),(4,2,7,'hai',NULL,'2026-10-17 21:35:58','2026-10-17 21:33:59','2026-10-17 21:35:58'),(5,7,2,'hai',8,NULL,'2026-10-17 21:35:41','2026-10-17 21:35:41');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_10_15_000001_add_username_to_users_table',1),(5,'2026_10_15_000002_create_personal_access_tokens_table',1),(6,'2026_10_15_000003_create_friendships_table',1),(7,'2026_10_15_000004_create_snaps_table',1),(8,'2026_10_15_000005_create_snap_recipients_table',1),(9,'2026_10_15_000006_create_snap_reactions_table',1),(10,'2026_10_15_000007_create_messages_table',1),(11,'2026_10_15_000008_create_rollcalls_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (5,'App\\Models\\User',1,'pocket-app','53391c05507b03310eaf2f64efa05563f4be94f6aeb75a772d93f48c354059e5','[\"*\"]','2026-10-15 00:52:58',NULL,'2026-10-15 00:51:57','2026-10-15 00:52:58'),(10,'App\\Models\\User',2,'pocket-app','81ccb6a8a8db13a5ed8f6ded33a91ac5b5204708330637f811ba46d5cca9003e','[\"*\"]','2026-10-15 02:55:30',NULL,'2026-10-15 01:23:57','2026-10-15 02:55:30'),(11,'App\\Models\\User',4,'pocket-app','1b750bc69808ccf9cb08eab610650d8e7eaae103019428b458e3bfbab75b447d','[\"*\"]','2026-10-16 01:36:09',NULL,'2026-10-16 01:35:58','2026-10-16 01:36:09'),(12,'App\\Models\\User',4,'pocket-app','2f1534b7d0ef999c6e6538d10e8b4f873833b17e1055727638d5bf23767b0b50','[\"*\"]','2026-10-16 02:11:53',NULL,'2026-10-16 02:11:51','2026-10-16 02:11:53'),(13,'App\\Models\\User',4,'pocket-app','bd9714f17ec78e53b33271a3f0ea41db122adbd25311cfabbbecddc4eb3a08c9','[\"*\"]','2026-10-16 03:15:31',NULL,'2026-10-16 02:57:09','2026-10-16 03:15:31'),(14,'App\\Models\\User',4,'pocket-app','49dc7338147b51315dca1f3537bf61778306c5f20bb6ab4a97cec84f737b49d3','[\"*\"]','2026-10-16 03:42:27',NULL,'2026-10-16 03:42:25','2026-10-16 03:42:27');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rollcalls`
--

DROP TABLE IF EXISTS `rollcalls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rollcalls` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` bigint unsigned NOT NULL,
  `photo_count` int unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `rollcalls_created_by_foreign` (`created_by`),
  CONSTRAINT `rollcalls_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rollcalls`
--

LOCK TABLES `rollcalls` WRITE;
/*!40000 ALTER TABLE `rollcalls` DISABLE KEYS */;
INSERT INTO `rollcalls` VALUES (1,'kerkom',2,0,'2026-10-17 20:39:04','2026-10-17 20:39:04');
/*!40000 ALTER TABLE `rollcalls` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `snap_reactions`
--

DROP TABLE IF EXISTS `snap_reactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snap_reactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `snap_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `emoji` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `snap_reactions_snap_id_user_id_unique` (`snap_id`,`user_id`),
  KEY `snap_reactions_user_id_foreign` (`user_id`),
  CONSTRAINT `snap_reactions_snap_id_foreign` FOREIGN KEY (`snap_id`) REFERENCES `snaps` (`id`) ON DELETE CASCADE,
  CONSTRAINT `snap_reactions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `snap_reactions`
--

LOCK TABLES `snap_reactions` WRITE;
/*!40000 ALTER TABLE `snap_reactions` DISABLE KEYS */;
INSERT INTO `snap_reactions` VALUES (1,2,3,'💛','2026-10-15 01:11:31','2026-10-15 01:11:31'),(2,8,7,'🔥','2026-10-17 21:35:31','2026-10-17 21:35:31');
/*!40000 ALTER TABLE `snap_reactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `snap_recipients`
--

DROP TABLE IF EXISTS `snap_recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snap_recipients` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `snap_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `snap_recipients_snap_id_user_id_unique` (`snap_id`,`user_id`),
  KEY `snap_recipients_user_id_foreign` (`user_id`),
  CONSTRAINT `snap_recipients_snap_id_foreign` FOREIGN KEY (`snap_id`) REFERENCES `snaps` (`id`) ON DELETE CASCADE,
  CONSTRAINT `snap_recipients_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `snap_recipients`
--

LOCK TABLES `snap_recipients` WRITE;
/*!40000 ALTER TABLE `snap_recipients` DISABLE KEYS */;
INSERT INTO `snap_recipients` VALUES (1,1,1),(2,2,3),(3,3,3),(4,4,3),(5,5,1),(6,5,3),(7,6,1),(8,6,3),(10,7,1),(9,7,3),(12,8,1),(13,8,3),(11,8,7);
/*!40000 ALTER TABLE `snap_recipients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `snaps`
--

DROP TABLE IF EXISTS `snaps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snaps` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sender_id` bigint unsigned NOT NULL,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `caption` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `snaps_sender_id_created_at_index` (`sender_id`,`created_at`),
  CONSTRAINT `snaps_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `snaps`
--

LOCK TABLES `snaps` WRITE;
/*!40000 ALTER TABLE `snaps` DISABLE KEYS */;
INSERT INTO `snaps` VALUES (1,2,'10cfc17a-b148-4f40-b799-5a912ddca886.jpg','','2026-10-15 00:51:14','2026-10-15 00:51:14'),(2,2,'19c5e7c1-5495-4c54-af6c-4cdad7140dc9.jpg','haii','2026-10-15 01:10:11','2026-10-15 01:10:11'),(3,2,'0f10157d-b9e5-4254-a1da-725e93196a38.jpg','haloo','2026-10-15 01:24:35','2026-10-15 01:24:35'),(4,2,'b69a916b-1b32-48b7-af77-72520ca4a8ce.jpg','haii☺️','2026-10-17 20:25:55','2026-10-17 20:25:55'),(5,2,'789dfdbb-4002-42af-aa66-5870f6e87ad3.jpg','','2026-10-17 20:55:09','2026-10-17 20:55:09'),(6,2,'0a21254b-99aa-445a-9c93-e9d7b01e5e0c.jpg','','2026-10-17 20:58:58','2026-10-17 20:58:58'),(7,2,'abaa22ba-5e6e-44c0-a4e6-a437fba770e6.jpg','hai krlompok 7 hadir','2026-10-17 21:22:18','2026-10-17 21:22:18'),(8,2,'7c21db04-368c-444b-bd87-8ce1b314f72d.jpg','haii','2026-10-17 21:30:55','2026-10-17 21:30:55');
/*!40000 ALTER TABLE `snaps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'sharul','shauniverse','sharul123@gmail.com',NULL,'$2y$12$m4p5RFMSkr6HcPzQiIvr8.zgfuGpDYDd.KX9foFoJiRAafMBd3b1K',NULL,'2026-10-14 20:21:55','2026-10-14 20:21:55'),(2,'sisi','sisisi','sisi@gmail.com',NULL,'$2y$12$VC8r.nKZSKyg5FNIYplCdemqdGbwOdh85VokmxeYLS/puQGH5xKrO',NULL,'2026-10-15 00:43:49','2026-10-15 00:43:49'),(3,'zidan','zidan','zidan123@gmail.com',NULL,'$2y$12$gMUsCvNS8wSZnLwS0RIvgufmo13qGFCo6Dhk8ZbG3hqnXh4FqKirm',NULL,'2026-10-15 01:06:42','2026-10-15 01:06:42'),(4,'wisnu','azezki','wisnu123@gmail.com',NULL,'$2y$12$dNZQAK61I..eRU6spgyRJuoniB9SR.RyXf/gfkNw6Dm/ATS9QTKUS',NULL,'2026-10-16 01:35:57','2026-10-16 01:35:57'),(5,'zidan','zidanilmy','zidanilmy01@gmail.com',NULL,'$2y$12$7e.Y/agy1RRdYbKCH/xN3um6vU6XCDSfJ8/LPnR/jVt485zbW9mAm',NULL,'2026-10-17 20:22:03','2026-10-17 20:22:03'),(6,'sharul','sharulmaulana','sharulmaulana@gmail.com',NULL,'$2y$12$RE58vfz3tr7lWf.difhYg.z0L.PAwjzK4NYmkRuZ8hcyVISaHyEti',NULL,'2026-10-17 21:19:08','2026-10-17 21:19:08'),(7,'rafiibra','rafiibra','rafi123@gmail.com',NULL,'$2y$12$1QTmRMDuHom0gbhd/xwNlekrdGB.TMGnJmGEVAp/3v/xfz7uRwAwO',NULL,'2026-10-17 21:27:48','2026-10-17 21:27:48');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-20 23:03:56
