CREATE DATABASE  IF NOT EXISTS `geovisor_agua_saneamiento` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `geovisor_agua_saneamiento`;
-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: geovisor_agua_saneamiento
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
-- Table structure for table `categoria_incidente`
--

DROP TABLE IF EXISTS `categoria_incidente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria_incidente` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria_incidente`
--

LOCK TABLES `categoria_incidente` WRITE;
/*!40000 ALTER TABLE `categoria_incidente` DISABLE KEYS */;
INSERT INTO `categoria_incidente` VALUES (1,'AGUA'),(2,'ALCANTARILLADO'),(3,'CONTAMINACION');
/*!40000 ALTER TABLE `categoria_incidente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entidades`
--

DROP TABLE IF EXISTS `entidades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entidades` (
  `id_entidad` int NOT NULL AUTO_INCREMENT,
  `id_estado_cuenta` int NOT NULL,
  `nombre_entidad` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `nit_rut` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `correo_institucional` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `telefono` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `direccion` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `funcionario_responsable` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `documento_funcionario` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `sitio_web` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_entidad`),
  UNIQUE KEY `nit_rut` (`nit_rut`),
  UNIQUE KEY `correo_institucional` (`correo_institucional`),
  KEY `fk_entidad_estado` (`id_estado_cuenta`),
  CONSTRAINT `fk_entidad_estado` FOREIGN KEY (`id_estado_cuenta`) REFERENCES `estado_cuenta` (`id_estado_cuenta`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entidades`
--

LOCK TABLES `entidades` WRITE;
/*!40000 ALTER TABLE `entidades` DISABLE KEYS */;
INSERT INTO `entidades` VALUES (1,1,'Empresa de Acueducto Municipal','900123456-7','contacto@acueducto.gov.co','6011234567','Cundinamarca','Juan Perez','1020304050','https://acueducto.gov.co','2026-01-16 14:54:31','2026-01-16 14:54:31');
/*!40000 ALTER TABLE `entidades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estado_cuenta`
--

DROP TABLE IF EXISTS `estado_cuenta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estado_cuenta` (
  `id_estado_cuenta` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_estado_cuenta`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estado_cuenta`
--

LOCK TABLES `estado_cuenta` WRITE;
/*!40000 ALTER TABLE `estado_cuenta` DISABLE KEYS */;
INSERT INTO `estado_cuenta` VALUES (1,'ACTIVO','Cuenta habilitada y operativa'),(2,'INACTIVO','Cuenta deshabilitada temporalmente'),(3,'SUSPENDIDO','Cuenta suspendida por incumplimiento o revisión'),(4,'PENDIENTE','Cuenta en proceso de validación');
/*!40000 ALTER TABLE `estado_cuenta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estado_reporte`
--

DROP TABLE IF EXISTS `estado_reporte`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estado_reporte` (
  `id_estado` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_estado`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estado_reporte`
--

LOCK TABLES `estado_reporte` WRITE;
/*!40000 ALTER TABLE `estado_reporte` DISABLE KEYS */;
INSERT INTO `estado_reporte` VALUES (1,'PENDIENTE','Reporte creado, esperando revisión'),(2,'EN_REVISION','Moderador validando o clasificando'),(3,'EN_PROCESO','Entidad atendiendo el incidente'),(4,'RESUELTO','Incidente solucionado y cerrado');
/*!40000 ALTER TABLE `estado_reporte` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historial_reportes`
--

DROP TABLE IF EXISTS `historial_reportes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historial_reportes` (
  `id_historial` int NOT NULL AUTO_INCREMENT,
  `id_reporte` int NOT NULL,
  `estado_anterior` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `estado_nuevo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `comentario` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `id_usuario_accion` int NOT NULL,
  `fecha_cambio` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_historial`),
  KEY `fk_historial_usuario` (`id_usuario_accion`),
  KEY `idx_historial_reporte` (`id_reporte`),
  CONSTRAINT `fk_historial_reporte` FOREIGN KEY (`id_reporte`) REFERENCES `reportes` (`id_reporte`),
  CONSTRAINT `fk_historial_usuario` FOREIGN KEY (`id_usuario_accion`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historial_reportes`
--

LOCK TABLES `historial_reportes` WRITE;
/*!40000 ALTER TABLE `historial_reportes` DISABLE KEYS */;
INSERT INTO `historial_reportes` VALUES (1,2,'PENDIENTE','EN_REVISION','Reporte validado por moderador',1,'2026-01-16 15:47:56'),(2,2,'EN_REVISION','EN_REVISION','Validación inicial del reporte',1,'2026-01-16 16:34:24'),(3,5,'PENDIENTE','EN_REVISION','Clasificación y asignación a Empresa de Acueducto Municipal',3,'2026-02-07 22:30:17'),(4,5,'EN_REVISION','EN_PROCESO','Iniciamos atención del reporte',2,'2026-02-07 22:32:12'),(5,5,'EN_PROCESO','RESUELTO','Reporte solucionado: se reparó la fuga',2,'2026-02-07 22:43:45'),(6,23,'NINGUNO','PENDIENTE','Reporte creado por el usuario',1,'2026-03-01 11:10:16'),(7,24,'NINGUNO','PENDIENTE','Reporte creado por el usuario',1,'2026-04-25 22:30:09'),(8,25,'NINGUNO','PENDIENTE','Reporte creado por el usuario',1,'2026-04-25 23:21:45'),(9,2,'PENDIENTE','PENDIENTE','Reporte verificado, en proceso de atención',3,'2026-04-25 23:28:21');
/*!40000 ALTER TABLE `historial_reportes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `infraestructura_hidrica`
--

DROP TABLE IF EXISTS `infraestructura_hidrica`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `infraestructura_hidrica` (
  `id_infraestructura` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `tipo` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `latitud` decimal(10,7) NOT NULL,
  `longitud` decimal(10,7) NOT NULL,
  `fuente` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `estado` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `fecha_actualizacion` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_infraestructura`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `infraestructura_hidrica`
--

LOCK TABLES `infraestructura_hidrica` WRITE;
/*!40000 ALTER TABLE `infraestructura_hidrica` DISABLE KEYS */;
INSERT INTO `infraestructura_hidrica` VALUES (1,'Planta de tratamiento Central','PTAR',5.0222000,-74.0048000,'SIASAR','ACTIVA','2026-01-16 16:06:30'),(2,'Planta Norte Test','Planta de tratamiento',5.0100000,-74.0200000,'Río Bogotá','ACTIVO','2026-04-25 23:31:55');
/*!40000 ALTER TABLE `infraestructura_hidrica` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs_auditoria`
--

DROP TABLE IF EXISTS `logs_auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs_auditoria` (
  `id_log` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int DEFAULT NULL,
  `accion` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `modulo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `fecha_accion` datetime DEFAULT CURRENT_TIMESTAMP,
  `ip_origen` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_log`),
  KEY `fk_log_usuario` (`id_usuario`),
  CONSTRAINT `fk_log_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs_auditoria`
--

LOCK TABLES `logs_auditoria` WRITE;
/*!40000 ALTER TABLE `logs_auditoria` DISABLE KEYS */;
INSERT INTO `logs_auditoria` VALUES (1,1,'CREAR_REPORTE','REPORTES','2026-01-16 15:58:19','192.168.1.10'),(2,1,'LOGIN','AUTH','2026-04-25 23:11:25','127.0.0.1'),(3,1,'CREAR_REPORTE','REPORTES','2026-04-25 23:11:25','127.0.0.1'),(4,5,'CAMBIAR_ESTADO','REPORTES','2026-04-25 23:11:25','127.0.0.1'),(5,5,'LISTAR_USUARIOS','USUARIOS','2026-04-25 23:11:25','127.0.0.1');
/*!40000 ALTER TABLE `logs_auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificaciones`
--

DROP TABLE IF EXISTS `notificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notificaciones` (
  `id_notificacion` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `id_reporte` int DEFAULT NULL,
  `tipo_notificacion` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `mensaje` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `leida` tinyint(1) DEFAULT '0',
  `fecha_envio` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_notificacion`),
  KEY `fk_notif_reporte` (`id_reporte`),
  KEY `idx_notificaciones_usuario` (`id_usuario`),
  CONSTRAINT `fk_notif_reporte` FOREIGN KEY (`id_reporte`) REFERENCES `reportes` (`id_reporte`),
  CONSTRAINT `fk_notif_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificaciones`
--

LOCK TABLES `notificaciones` WRITE;
/*!40000 ALTER TABLE `notificaciones` DISABLE KEYS */;
INSERT INTO `notificaciones` VALUES (1,1,2,'CAMBIO_ESTADO','Tu reporte cambió a EN_REVISION',1,'2026-01-16 15:51:47'),(2,1,2,'CAMBIO_ESTADO','Tu reporte cambió a EN_REVISION',1,'2026-01-16 16:34:24'),(3,1,5,'ASIGNACION','Tu reporte fue asignado a la entidad responsable y se encuentra en revisión.',1,'2026-02-07 22:30:17'),(4,1,5,'CAMBIO_ESTADO','Tu reporte cambió a EN_PROCESO',1,'2026-02-07 22:32:12'),(5,1,5,'CAMBIO_ESTADO','Tu reporte cambió a RESUELTO',1,'2026-02-07 22:43:45'),(6,1,23,'REPORTE_CREADO','Tu reporte fue creado exitosamente y está en estado PENDIENTE',1,'2026-03-01 11:10:17'),(7,1,24,'REPORTE_CREADO','Tu reporte fue creado exitosamente y está en estado PENDIENTE',1,'2026-04-25 22:30:09'),(8,1,25,'REPORTE_CREADO','Tu reporte fue creado exitosamente y está en estado PENDIENTE',1,'2026-04-25 23:21:45'),(9,1,2,'CAMBIO_ESTADO','Tu reporte cambió a PENDIENTE',0,'2026-04-25 23:28:21');
/*!40000 ALTER TABLE `notificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recuperacion_contrasena`
--

DROP TABLE IF EXISTS `recuperacion_contrasena`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recuperacion_contrasena` (
  `id_recuperacion` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `fecha_expiracion` datetime NOT NULL,
  `usado` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id_recuperacion`),
  UNIQUE KEY `token` (`token`),
  KEY `fk_recup_usuario` (`id_usuario`),
  CONSTRAINT `fk_recup_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recuperacion_contrasena`
--

LOCK TABLES `recuperacion_contrasena` WRITE;
/*!40000 ALTER TABLE `recuperacion_contrasena` DISABLE KEYS */;
INSERT INTO `recuperacion_contrasena` VALUES (1,1,'token_prueba_123','2026-01-17 15:55:11',0);
/*!40000 ALTER TABLE `recuperacion_contrasena` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reportes`
--

DROP TABLE IF EXISTS `reportes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reportes` (
  `id_reporte` int NOT NULL AUTO_INCREMENT,
  `id_usuario` int NOT NULL,
  `id_entidad` int DEFAULT NULL,
  `id_tipo_incidente` int NOT NULL,
  `id_severidad` int NOT NULL,
  `id_estado` int NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `direccion` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `latitud` decimal(10,7) NOT NULL,
  `longitud` decimal(10,7) NOT NULL,
  `imagen_url` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `fuente_reporte` enum('CIUDADANO','ENTIDAD') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'CIUDADANO',
  `fecha_reporte` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_reporte`),
  KEY `fk_reportes_entidad` (`id_entidad`),
  KEY `fk_reportes_tipo` (`id_tipo_incidente`),
  KEY `fk_reportes_severidad` (`id_severidad`),
  KEY `idx_reportes_usuario` (`id_usuario`),
  KEY `idx_reportes_estado` (`id_estado`),
  CONSTRAINT `fk_reportes_entidad` FOREIGN KEY (`id_entidad`) REFERENCES `entidades` (`id_entidad`),
  CONSTRAINT `fk_reportes_estado` FOREIGN KEY (`id_estado`) REFERENCES `estado_reporte` (`id_estado`),
  CONSTRAINT `fk_reportes_severidad` FOREIGN KEY (`id_severidad`) REFERENCES `severidad` (`id_severidad`),
  CONSTRAINT `fk_reportes_tipo` FOREIGN KEY (`id_tipo_incidente`) REFERENCES `tipo_incidente` (`id_tipo_incidente`),
  CONSTRAINT `fk_reportes_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reportes`
--

LOCK TABLES `reportes` WRITE;
/*!40000 ALTER TABLE `reportes` DISABLE KEYS */;
INSERT INTO `reportes` VALUES (2,1,1,1,1,1,'Fuga de agua constante en la vía principal','Calle 10 # 5-20',5.0222000,-74.0048000,NULL,'CIUDADANO','2026-01-16 15:14:43','2026-01-16 15:14:43','2026-04-25 23:28:21'),(4,1,1,1,1,1,'Validación completa del sistema','Calle 123',5.0222000,-74.0048000,NULL,'CIUDADANO','2026-01-17 20:29:45','2026-01-17 20:29:45','2026-01-17 20:29:45'),(5,1,1,1,3,1,'Fuga de agua en la vía principal (reporte de prueba)','Calle 10 # 5-20, Zipaquirá',5.0220000,-74.0040000,NULL,'CIUDADANO','2026-02-07 22:24:30','2026-02-07 22:24:30','2026-02-15 00:04:06'),(22,1,NULL,1,2,1,'Fuga de agua visible en la esquina de la calle principal','Calle 10 # 5-30, Zipaquirá',5.0222000,-74.0048000,NULL,'CIUDADANO','2026-03-01 10:51:43','2026-03-01 10:51:43','2026-03-01 10:51:43'),(23,1,NULL,1,2,1,'Fuga de agua visible en la esquina de la calle principal','Calle 10 # 5-30, Zipaquirá',5.0222000,-74.0048000,NULL,'CIUDADANO','2026-03-01 11:10:16','2026-03-01 11:10:16','2026-03-01 11:10:16'),(24,1,NULL,1,1,1,'Prueba de reporte en nueva computadora','Calle 10 # 5-30, Zipaquirá',5.0222000,-74.0048000,'null','CIUDADANO','2026-04-25 22:30:09','2026-04-25 22:30:09','2026-04-25 22:30:09'),(25,1,NULL,1,1,1,'Prueba tubería rota sector norte','Calle 15 # 8-20, Zipaquirá',5.0230000,-74.0050000,'null','CIUDADANO','2026-04-25 23:21:45','2026-04-25 23:21:45','2026-04-25 23:21:45');
/*!40000 ALTER TABLE `reportes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id_rol` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'CIUDADANO','Usuario ciudadano que reporta incidentes y consulta el mapa','2026-01-16 14:42:07'),(2,'ENTIDAD','Entidad institucional que gestiona reportes asignados y actualiza estados','2026-01-16 14:42:07'),(3,'MODERADOR','Valida, clasifica y asigna reportes a entidades','2026-01-16 14:42:07'),(4,'ADMINISTRADOR','Administra usuarios, entidades, reportes, auditoría y estadísticas','2026-01-16 14:42:07');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `severidad`
--

DROP TABLE IF EXISTS `severidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `severidad` (
  `id_severidad` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_severidad`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `severidad`
--

LOCK TABLES `severidad` WRITE;
/*!40000 ALTER TABLE `severidad` DISABLE KEYS */;
INSERT INTO `severidad` VALUES (1,'BAJA','Incidente menor sin riesgo inmediato'),(2,'MEDIA','Incidente que requiere atención pronta'),(3,'ALTA','Incidente crítico con riesgo alto o afectación grave');
/*!40000 ALTER TABLE `severidad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipo_incidente`
--

DROP TABLE IF EXISTS `tipo_incidente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_incidente` (
  `id_tipo_incidente` int NOT NULL AUTO_INCREMENT,
  `id_categoria` int NOT NULL,
  `nombre` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_tipo_incidente`),
  UNIQUE KEY `id_categoria` (`id_categoria`,`nombre`),
  CONSTRAINT `fk_tipo_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria_incidente` (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_incidente`
--

LOCK TABLES `tipo_incidente` WRITE;
/*!40000 ALTER TABLE `tipo_incidente` DISABLE KEYS */;
INSERT INTO `tipo_incidente` VALUES (1,1,'Fuga de agua','Escape visible de agua en vía, andén o instalación'),(2,1,'Baja presión','Disminución notable del caudal o presión'),(3,2,'Taponamiento','Obstrucción de alcantarillado o sumideros'),(4,2,'Rebose de aguas residuales','Salida de aguas residuales en vía pública'),(5,3,'Agua contaminada','Cambio de color/olor/sabor del agua'),(6,3,'Basuras en cuerpos de agua','Residuos sólidos afectando fuentes hídricas');
/*!40000 ALTER TABLE `tipo_incidente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` int NOT NULL AUTO_INCREMENT,
  `id_rol` int NOT NULL,
  `id_estado_cuenta` int NOT NULL,
  `id_entidad` int DEFAULT NULL,
  `nombre_completo` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `correo` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `tipo_documento` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `numero_documento` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `telefono` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `pais` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ciudad` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `direccion` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `correo` (`correo`),
  UNIQUE KEY `numero_documento` (`numero_documento`),
  KEY `fk_usuario_rol` (`id_rol`),
  KEY `fk_usuario_estado` (`id_estado_cuenta`),
  KEY `idx_usuarios_id_entidad` (`id_entidad`),
  CONSTRAINT `fk_usuario_estado` FOREIGN KEY (`id_estado_cuenta`) REFERENCES `estado_cuenta` (`id_estado_cuenta`),
  CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`),
  CONSTRAINT `fk_usuarios_entidades` FOREIGN KEY (`id_entidad`) REFERENCES `entidades` (`id_entidad`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,1,1,NULL,'Juan Pérez','juan@test.com','$pbkdf2-sha256$29000$NMa4txbCGCNEaI2RklJKSQ$1o4DhRRmByc5HAQVvxO8jR1vbgjK3yA2fEXbLOrVyQM',NULL,'CC','123456789',NULL,NULL,NULL,NULL,'2026-01-16 15:13:42','2026-04-25 22:25:21'),(2,2,1,1,'Operador Entidad - Acueducto','operador.acueducto@demo.com','$pbkdf2-sha256$29000$NMa4txbCGCNEaI2RklJKSQ$1o4DhRRmByc5HAQVvxO8jR1vbgjK3yA2fEXbLOrVyQM',NULL,'CC','900000001','3001112233','Colombia','Zipaquirá','Oficina principal','2026-02-07 22:19:15','2026-04-25 22:25:21'),(3,3,1,NULL,'Moderador Prueba','moderador@demo.com','$pbkdf2-sha256$29000$NMa4txbCGCNEaI2RklJKSQ$1o4DhRRmByc5HAQVvxO8jR1vbgjK3yA2fEXbLOrVyQM',NULL,'CC','900000002','3001112244','Colombia','Zipaquirá','Oficina moderación','2026-02-07 22:26:19','2026-04-25 22:25:21'),(4,1,1,NULL,'Maria Test','maria.test@correo.com','$pbkdf2-sha256$29000$NMa4txbCGCNEaI2RklJKSQ$1o4DhRRmByc5HAQVvxO8jR1vbgjK3yA2fEXbLOrVyQM',NULL,'CC','987654321','3009876543','Colombia','Zipaquirá',NULL,'2026-03-01 11:15:46','2026-04-25 22:25:21'),(5,4,1,NULL,'Admin Geovisor','admin@geovisor.com','$pbkdf2-sha256$29000$NMa4txbCGCNEaI2RklJKSQ$1o4DhRRmByc5HAQVvxO8jR1vbgjK3yA2fEXbLOrVyQM',NULL,'CC','111111111',NULL,NULL,NULL,NULL,'2026-03-01 11:38:04','2026-04-25 22:25:21'),(6,1,1,NULL,'Carlos Prueba','carlos.prueba@correo.com','$pbkdf2-sha256$29000$xTjn/H.vtXYOAaA05jwHYA$JMN89MJipUHwg3HVCsljSy0.9rMJngGWZ37GMUOQBvQ','2003-08-25','CC','111222333','3009876543','Colombia','Bogotá','Calle 26 # 51-53','2026-04-25 23:38:26','2026-04-25 23:53:33'),(7,1,1,NULL,'Luis Test','luis.test@correo.com','$pbkdf2-sha256$29000$EcI4B0AoZUypNYZwLiVEaA$MZRq.ETv6Iiv2qr/HzqivWF6q8nnUnJrCeKRO04EYsw','2003-08-25','CC','555666777','3001112233','Colombia','Bogotá','Calle 10 # 5-30','2026-04-26 00:01:24','2026-04-26 00:04:39');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_reportes_completos`
--

DROP TABLE IF EXISTS `vw_reportes_completos`;
/*!50001 DROP VIEW IF EXISTS `vw_reportes_completos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_reportes_completos` AS SELECT 
 1 AS `id_reporte`,
 1 AS `ciudadano`,
 1 AS `nombre_entidad`,
 1 AS `tipo_incidente`,
 1 AS `severidad`,
 1 AS `estado`,
 1 AS `descripcion`,
 1 AS `latitud`,
 1 AS `longitud`,
 1 AS `fecha_reporte`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'geovisor_agua_saneamiento'
--

--
-- Dumping routines for database 'geovisor_agua_saneamiento'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_cambiar_estado_reporte` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cambiar_estado_reporte`(
    IN p_id_reporte INT,
    IN p_nuevo_estado INT,
    IN p_id_usuario INT,
    IN p_comentario VARCHAR(255)
)
BEGIN
    DECLARE v_estado_anterior VARCHAR(50);
    DECLARE v_nombre_estado_nuevo VARCHAR(50);

    -- 1. Obtener estado anterior (texto)
    SELECT er.nombre
    INTO v_estado_anterior
    FROM reportes r
    JOIN estado_reporte er ON r.id_estado = er.id_estado
    WHERE r.id_reporte = p_id_reporte;

    -- 2. Obtener nombre del nuevo estado
    SELECT nombre
    INTO v_nombre_estado_nuevo
    FROM estado_reporte
    WHERE id_estado = p_nuevo_estado;

    -- 3. Actualizar estado del reporte
    UPDATE reportes
    SET id_estado = p_nuevo_estado
    WHERE id_reporte = p_id_reporte;

    -- 4. Insertar historial
    INSERT INTO historial_reportes (
        id_reporte,
        estado_anterior,
        estado_nuevo,
        comentario,
        id_usuario_accion,
        fecha_cambio
    ) VALUES (
        p_id_reporte,
        v_estado_anterior,
        v_nombre_estado_nuevo,
        p_comentario,
        p_id_usuario,
        NOW()
    );

    -- 5. Crear notificación al usuario dueño del reporte
    INSERT INTO notificaciones (
        id_usuario,
        id_reporte,
        tipo_notificacion,
        mensaje,
        leida,
        fecha_envio
    )
    SELECT
        r.id_usuario,
        r.id_reporte,
        'CAMBIO_ESTADO',
        CONCAT('Tu reporte cambió a ', v_nombre_estado_nuevo),
        0,
        NOW()
    FROM reportes r
    WHERE r.id_reporte = p_id_reporte;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_reportes_completos`
--

/*!50001 DROP VIEW IF EXISTS `vw_reportes_completos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_reportes_completos` AS select `r`.`id_reporte` AS `id_reporte`,`u`.`nombre_completo` AS `ciudadano`,`e`.`nombre_entidad` AS `nombre_entidad`,`ti`.`nombre` AS `tipo_incidente`,`s`.`nombre` AS `severidad`,`er`.`nombre` AS `estado`,`r`.`descripcion` AS `descripcion`,`r`.`latitud` AS `latitud`,`r`.`longitud` AS `longitud`,`r`.`fecha_reporte` AS `fecha_reporte` from (((((`reportes` `r` join `usuarios` `u` on((`r`.`id_usuario` = `u`.`id_usuario`))) left join `entidades` `e` on((`r`.`id_entidad` = `e`.`id_entidad`))) join `tipo_incidente` `ti` on((`r`.`id_tipo_incidente` = `ti`.`id_tipo_incidente`))) join `severidad` `s` on((`r`.`id_severidad` = `s`.`id_severidad`))) join `estado_reporte` `er` on((`r`.`id_estado` = `er`.`id_estado`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-18 21:31:39
