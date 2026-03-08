-- Inicialización Docker RDAM
CREATE DATABASE IF NOT EXISTS rdam_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rdam_db;

-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 07-03-2026 a las 17:43:08
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `rdam`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria`
--

CREATE TABLE `auditoria` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `accion` varchar(100) NOT NULL,
  `solicitud_id` int(11) DEFAULT NULL,
  `detalle` text DEFAULT NULL,
  `ip_origen` varchar(45) DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Log inmutable de acciones del sistema — solo INSERT';

--
-- Volcado de datos para la tabla `auditoria`
--

INSERT INTO `auditoria` (`id`, `usuario_id`, `accion`, `solicitud_id`, `detalle`, `ip_origen`, `fecha`) VALUES
(1, 4, 'LOGIN', NULL, NULL, '::1', '2026-02-27 15:56:57'),
(2, 4, 'USUARIO_CREADO', NULL, 'email: operador@rdam.gob.ar, rol: OPERADOR', '::1', '2026-02-27 16:00:11'),
(3, 5, 'LOGIN', NULL, NULL, '::1', '2026-02-27 16:01:13'),
(4, 5, 'RESOLUCION_EMITIDA', 1, 'resultado: APROBADO', '::1', '2026-02-27 16:06:12'),
(5, 5, 'LOGIN', NULL, NULL, '::1', '2026-03-02 12:53:37'),
(6, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-02 12:55:24'),
(7, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-02 15:47:08'),
(8, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-02 17:05:24'),
(9, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-02 17:05:37'),
(10, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-02 19:28:07'),
(11, 4, 'RESOLUCION_EMITIDA', 4, 'resultado: APROBADO', '::1', '2026-03-02 19:28:52'),
(12, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-03 14:52:33'),
(13, 4, 'RESOLUCION_EMITIDA', 6, 'resultado: APROBADO', '::1', '2026-03-03 14:58:10'),
(14, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-03 15:23:45'),
(15, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-03 15:31:43'),
(16, 4, 'RESOLUCION_EMITIDA', 7, 'resultado: RECHAZADO', '::1', '2026-03-03 15:32:33'),
(17, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-03 16:03:18'),
(18, 4, 'RESOLUCION_EMITIDA', 8, 'resultado: APROBADO', '::1', '2026-03-03 16:03:44'),
(19, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-03 16:09:44'),
(20, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-03 16:41:31'),
(21, 4, 'RESOLUCION_EMITIDA', 9, 'resultado: APROBADO', '::1', '2026-03-03 16:42:06'),
(22, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-03 19:03:49'),
(23, 4, 'RESOLUCION_EMITIDA', 10, 'resultado: APROBADO', '::1', '2026-03-03 19:04:26'),
(24, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-03 19:10:49'),
(25, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-03 21:44:09'),
(26, 4, 'USUARIO_CREADO', NULL, 'email: lauta.acvd@gmail.com, rol: OPERADOR', '::1', '2026-03-03 21:56:37'),
(27, 6, 'LOGIN', NULL, NULL, '::1', '2026-03-03 21:56:51'),
(28, 6, 'LOGIN', NULL, NULL, '::1', '2026-03-04 13:55:05'),
(29, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-04 13:55:16'),
(30, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-04 13:59:36'),
(31, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-04 14:02:42'),
(32, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-04 14:17:32'),
(33, 4, 'RESOLUCION_EMITIDA', 11, 'resultado: APROBADO', '::1', '2026-03-04 14:18:24'),
(34, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-06 15:20:24'),
(35, 5, 'LOGIN', NULL, NULL, '::1', '2026-03-06 15:20:43'),
(36, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-06 15:29:32'),
(37, 5, 'LOGIN', NULL, NULL, '::1', '2026-03-06 15:30:20'),
(38, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-06 16:53:43'),
(39, 5, 'LOGIN', NULL, NULL, '::1', '2026-03-06 16:53:50'),
(40, 5, 'LOGIN', NULL, NULL, '::1', '2026-03-06 17:09:53'),
(41, 5, 'LOGIN', NULL, NULL, '::1', '2026-03-06 17:10:46'),
(42, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-06 17:31:24'),
(43, 5, 'LOGIN', NULL, NULL, '::1', '2026-03-06 17:31:28'),
(44, 4, 'LOGIN', NULL, NULL, '::1', '2026-03-06 19:09:36'),
(45, 6, 'LOGIN', NULL, NULL, '::1', '2026-03-06 19:20:07');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_estado_solicitud`
--

CREATE TABLE `historial_estado_solicitud` (
  `id` int(11) NOT NULL,
  `solicitud_id` int(11) NOT NULL,
  `estado_anterior` enum('PENDIENTE_PAGO','PAGADA','PENDIENTE_REVISION','EN_REVISION','APROBADA','RECHAZADA','CERTIFICADO_EMITIDO') DEFAULT NULL,
  `estado_nuevo` enum('PENDIENTE_PAGO','PAGADA','PENDIENTE_REVISION','EN_REVISION','APROBADA','RECHAZADA','CERTIFICADO_EMITIDO') NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `observacion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registro inmutable append-only de transiciones de estado (RN-08)';

--
-- Volcado de datos para la tabla `historial_estado_solicitud`
--

INSERT INTO `historial_estado_solicitud` (`id`, `solicitud_id`, `estado_anterior`, `estado_nuevo`, `usuario_id`, `fecha`, `observacion`) VALUES
(1, 1, NULL, 'PENDIENTE_PAGO', NULL, '2026-02-26 16:12:33', 'Solicitud creada por ciudadano'),
(2, 1, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-02-27 15:35:26', 'Confirmado por PlusPagos. TransaccionPlataformaId: 123456'),
(3, 1, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-02-27 15:35:26', 'Transición automática post-pago'),
(4, 1, 'PENDIENTE_REVISION', 'EN_REVISION', 5, '2026-02-27 16:04:30', NULL),
(5, 1, 'EN_REVISION', 'APROBADA', 5, '2026-02-27 16:06:12', 'Documentación verificada correctamente'),
(6, 1, 'APROBADA', 'CERTIFICADO_EMITIDO', NULL, '2026-02-27 16:08:22', 'PDF generado y almacenado'),
(7, 2, NULL, 'PENDIENTE_PAGO', NULL, '2026-02-27 16:16:36', 'Solicitud creada por ciudadano'),
(8, 3, NULL, 'PENDIENTE_PAGO', NULL, '2026-02-27 16:22:29', 'Solicitud creada por ciudadano'),
(9, 4, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-02 15:51:55', 'Solicitud creada por ciudadano'),
(10, 4, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-03-02 19:26:57', 'Confirmado por PlusPagos. TransaccionPlataformaId: 905072'),
(11, 4, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-03-02 19:26:58', 'Transición automática post-pago'),
(12, 4, 'PENDIENTE_REVISION', 'EN_REVISION', 4, '2026-03-02 19:28:40', NULL),
(13, 4, 'EN_REVISION', 'APROBADA', 4, '2026-03-02 19:28:52', NULL),
(14, 5, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-03 14:40:49', 'Solicitud creada por ciudadano'),
(15, 6, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-03 14:46:44', 'Solicitud creada por ciudadano'),
(16, 6, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-03-03 14:47:11', 'Confirmado por PlusPagos. TransaccionPlataformaId: 720327'),
(17, 6, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-03-03 14:47:12', 'Transición automática post-pago'),
(18, 6, 'PENDIENTE_REVISION', 'EN_REVISION', 4, '2026-03-03 14:52:48', NULL),
(19, 6, 'EN_REVISION', 'APROBADA', 4, '2026-03-03 14:58:10', NULL),
(20, 7, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-03 15:30:17', 'Solicitud creada por ciudadano'),
(21, 7, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-03-03 15:31:24', 'Confirmado por PlusPagos. TransaccionPlataformaId: 698107'),
(22, 7, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-03-03 15:31:24', 'Transición automática post-pago'),
(23, 7, 'PENDIENTE_REVISION', 'EN_REVISION', 4, '2026-03-03 15:31:51', NULL),
(24, 7, 'EN_REVISION', 'RECHAZADA', 4, '2026-03-03 15:32:33', 'debes 70 lucas a tu ninio'),
(25, 8, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-03 16:02:41', 'Solicitud creada por ciudadano'),
(26, 8, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-03-03 16:03:07', 'Confirmado por PlusPagos. TransaccionPlataformaId: 952891'),
(27, 8, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-03-03 16:03:07', 'Transición automática post-pago'),
(28, 8, 'PENDIENTE_REVISION', 'EN_REVISION', 4, '2026-03-03 16:03:25', NULL),
(29, 8, 'EN_REVISION', 'APROBADA', 4, '2026-03-03 16:03:44', NULL),
(30, 9, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-03 16:40:56', 'Solicitud creada por ciudadano'),
(31, 9, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-03-03 16:41:17', 'Confirmado por PlusPagos. TransaccionPlataformaId: 229582'),
(32, 9, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-03-03 16:41:17', 'Transición automática post-pago'),
(33, 9, 'PENDIENTE_REVISION', 'EN_REVISION', 4, '2026-03-03 16:41:36', NULL),
(34, 9, 'EN_REVISION', 'APROBADA', 4, '2026-03-03 16:42:06', NULL),
(35, 10, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-03 19:03:05', 'Solicitud creada por ciudadano'),
(36, 10, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-03-03 19:03:33', 'Confirmado por PlusPagos. TransaccionPlataformaId: 501944'),
(37, 10, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-03-03 19:03:34', 'Transición automática post-pago'),
(38, 10, 'PENDIENTE_REVISION', 'EN_REVISION', 4, '2026-03-03 19:03:56', NULL),
(39, 10, 'EN_REVISION', 'APROBADA', 4, '2026-03-03 19:04:26', NULL),
(40, 11, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-04 14:14:26', 'Solicitud creada por ciudadano'),
(41, 11, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-03-04 14:17:14', 'Confirmado por PlusPagos. TransaccionPlataformaId: 584934'),
(42, 11, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-03-04 14:17:14', 'Transición automática post-pago'),
(43, 11, 'PENDIENTE_REVISION', 'EN_REVISION', 4, '2026-03-04 14:17:43', NULL),
(44, 11, 'EN_REVISION', 'APROBADA', 4, '2026-03-04 14:18:24', NULL),
(45, 12, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-04 15:37:38', 'Solicitud creada por ciudadano'),
(46, 13, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-04 15:44:08', 'Solicitud creada por ciudadano'),
(47, 14, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-06 14:51:13', 'Solicitud creada por ciudadano'),
(48, 15, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-06 15:20:56', 'Solicitud creada por ciudadano'),
(49, 14, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-03-06 15:28:27', 'Confirmado por PlusPagos. TransaccionPlataformaId: 123456'),
(50, 14, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-03-06 15:28:27', 'Transición automática post-pago'),
(51, 16, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-06 17:02:24', 'Solicitud creada por ciudadano'),
(52, 17, NULL, 'PENDIENTE_PAGO', NULL, '2026-03-06 17:31:55', 'Solicitud creada por ciudadano'),
(53, 17, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-03-06 17:42:21', 'Confirmado por PlusPagos. TransaccionPlataformaId: 123456'),
(54, 17, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-03-06 17:42:21', 'Transición automática post-pago'),
(55, 17, 'PENDIENTE_REVISION', 'EN_REVISION', 5, '2026-03-06 17:43:18', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `otp_session`
--

CREATE TABLE `otp_session` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `codigo` varchar(4) NOT NULL,
  `expiracion` datetime NOT NULL,
  `usado` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='OTP de un solo uso para autenticación del ciudadano (RN-04)';

--
-- Volcado de datos para la tabla `otp_session`
--

INSERT INTO `otp_session` (`id`, `email`, `codigo`, `expiracion`, `usado`, `fecha_creacion`) VALUES
(1, 'ciudadano@test.com', '8528', '2026-02-26 18:52:32', 1, '2026-02-26 15:37:32'),
(2, 'ciudadano@test.com', '2468', '2026-02-26 18:53:21', 1, '2026-02-26 15:38:21'),
(3, 'ciudadano@test.com', '5873', '2026-02-26 19:13:02', 1, '2026-02-26 15:58:02'),
(4, 'ciudadano@test.com', '7763', '2026-02-27 19:30:40', 1, '2026-02-27 16:15:40'),
(5, 'lauta.acvd@gmail.com', '2004', '2026-03-02 19:03:17', 1, '2026-03-02 15:48:17'),
(6, 'lauta.acvd@gmail.com', '8832', '2026-03-02 19:06:08', 1, '2026-03-02 15:51:08'),
(7, 'lauta.acvd@gmail.com', '9484', '2026-03-02 19:45:16', 1, '2026-03-02 16:30:16'),
(8, 'lauta.acvd@gmail.com', '2002', '2026-03-02 22:03:01', 1, '2026-03-02 18:48:01'),
(9, 'lauta.acvd@gmail.com', '8942', '2026-03-02 22:03:04', 1, '2026-03-02 18:48:04'),
(10, 'lauta.acvd@gmail.com', '5066', '2026-03-02 22:03:38', 1, '2026-03-02 18:48:38'),
(11, 'lauta.acvd@gmail.com', '9287', '2026-03-02 22:03:40', 1, '2026-03-02 18:48:40'),
(12, 'lauta.acvd@gmail.com', '7490', '2026-03-02 22:07:27', 1, '2026-03-02 18:52:27'),
(13, 'lauta.acvd@gmail.com', '5096', '2026-03-02 22:07:28', 1, '2026-03-02 18:52:28'),
(14, 'lauta.acvd@gmail.com', '1640', '2026-03-02 22:14:40', 1, '2026-03-02 18:59:40'),
(15, 'lauta.acvd@gmail.com', '1372', '2026-03-02 22:15:17', 1, '2026-03-02 19:00:17'),
(16, 'lauta.acvd@gmail.com', '3090', '2026-03-02 22:25:09', 1, '2026-03-02 19:10:09'),
(17, 'lauta.acvd@gmail.com', '1852', '2026-03-02 22:26:11', 1, '2026-03-02 19:11:11'),
(18, 'lauta.acvd@gmail.com', '2903', '2026-03-02 22:26:12', 1, '2026-03-02 19:11:12'),
(19, 'lauta.acvd@gmail.com', '5746', '2026-03-02 22:26:49', 1, '2026-03-02 19:11:49'),
(20, 'lauta.acvd@gmail.com', '8247', '2026-03-02 22:41:10', 1, '2026-03-02 19:26:10'),
(21, 'lauta.acvd@gmail.com', '3426', '2026-03-02 22:44:09', 1, '2026-03-02 19:29:09'),
(22, 'lauta.acvd@gmail.com', '1796', '2026-03-03 17:37:54', 1, '2026-03-03 14:22:54'),
(23, 'lauta.acvd@gmail.com', '7462', '2026-03-03 17:37:56', 1, '2026-03-03 14:22:56'),
(24, 'lauta.acvd@gmail.com', '8310', '2026-03-03 17:54:44', 1, '2026-03-03 14:39:44'),
(25, 'lauta.acvd@gmail.com', '8895', '2026-03-03 18:01:15', 1, '2026-03-03 14:46:15'),
(26, 'lauta.acvd@gmail.com', '8219', '2026-03-03 18:18:18', 1, '2026-03-03 15:03:18'),
(27, 'lauta.acvd@gmail.com', '6493', '2026-03-03 18:36:26', 1, '2026-03-03 15:21:26'),
(28, 'lauta.acvd@gmail.com', '2875', '2026-03-03 18:36:30', 1, '2026-03-03 15:21:30'),
(29, 'lauta.acvd@gmail.com', '3656', '2026-03-03 18:37:37', 1, '2026-03-03 15:22:37'),
(30, 'lauta.acvd@gmail.com', '4826', '2026-03-03 18:44:56', 1, '2026-03-03 15:29:56'),
(31, 'lauta.acvd@gmail.com', '6439', '2026-03-03 18:48:22', 1, '2026-03-03 15:33:22'),
(32, 'lauta.acvd@gmail.com', '8543', '2026-03-03 18:48:24', 1, '2026-03-03 15:33:24'),
(33, 'lauta.acvd@gmail.com', '1923', '2026-03-03 18:52:15', 1, '2026-03-03 15:37:15'),
(34, 'lauta.acvd@gmail.com', '1632', '2026-03-03 19:12:01', 1, '2026-03-03 15:57:01'),
(35, 'lauta.acvd@gmail.com', '4466', '2026-03-03 19:16:45', 1, '2026-03-03 16:01:45'),
(36, 'lauta.acvd@gmail.com', '7491', '2026-03-03 19:16:48', 1, '2026-03-03 16:01:48'),
(37, 'lauta.acvd@gmail.com', '4076', '2026-03-03 19:17:18', 1, '2026-03-03 16:02:18'),
(38, 'lauta.acvd@gmail.com', '7527', '2026-03-03 19:18:57', 1, '2026-03-03 16:03:57'),
(39, 'lauta.acvd@gmail.com', '6199', '2026-03-03 19:55:20', 1, '2026-03-03 16:40:20'),
(40, 'lauta.acvd@gmail.com', '4253', '2026-03-03 19:57:23', 1, '2026-03-03 16:42:23'),
(41, 'lauta.acvd@gmail.com', '1237', '2026-03-03 22:17:34', 1, '2026-03-03 19:02:34'),
(42, 'lauta.acvd@gmail.com', '2314', '2026-03-03 22:20:07', 1, '2026-03-03 19:05:07'),
(43, 'lauta.acvd@gmail.com', '2970', '2026-03-04 17:28:53', 1, '2026-03-04 14:13:53'),
(44, 'lauta.acvd@gmail.com', '8249', '2026-03-04 17:33:54', 1, '2026-03-04 14:18:54'),
(45, 'lauta.acvd@gmail.com', '7510', '2026-03-04 17:49:16', 1, '2026-03-04 14:34:16'),
(46, 'lauta.acvd@gmail.com', '9179', '2026-03-04 18:51:17', 1, '2026-03-04 15:36:17'),
(47, 'lauta.acvd@gmail.com', '5200', '2026-03-06 18:05:35', 1, '2026-03-06 14:50:35'),
(48, 'ciudadano@test.com', '3578', '2026-03-06 18:26:25', 1, '2026-03-06 15:11:25'),
(49, 'ciudadano@test.com', '6416', '2026-03-06 18:26:39', 1, '2026-03-06 15:11:39'),
(50, 'lauta.acvd@gmail.com', '4582', '2026-03-06 18:34:25', 1, '2026-03-06 15:19:25'),
(51, 'lauta.acvd@gmail.com', '9122', '2026-03-06 20:07:20', 1, '2026-03-06 16:52:20'),
(52, 'lauta.acvd@gmail.com', '4953', '2026-03-06 20:11:17', 1, '2026-03-06 16:56:17'),
(53, 'ciudadano@test.com', '2808', '2026-03-06 20:30:35', 0, '2026-03-06 17:15:35'),
(54, 'lauta.acvd@gmail.com', '1434', '2026-03-06 20:31:27', 1, '2026-03-06 17:16:27'),
(55, 'lauta.acvd@gmail.com', '8583', '2026-03-06 20:45:42', 1, '2026-03-06 17:30:42');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pago`
--

CREATE TABLE `pago` (
  `id` int(11) NOT NULL,
  `solicitud_id` int(11) NOT NULL,
  `transaccion_id` varchar(100) NOT NULL,
  `estado_pago` enum('PENDIENTE','CONFIRMADO','FALLIDO') NOT NULL DEFAULT 'PENDIENTE',
  `monto` decimal(10,2) NOT NULL,
  `proveedor` varchar(50) NOT NULL,
  `metadata_webhook` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata_webhook`)),
  `fecha_pago` datetime DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Transacciones de arancel — idempotencia garantizada por transaccion_id';

--
-- Volcado de datos para la tabla `pago`
--

INSERT INTO `pago` (`id`, `solicitud_id`, `transaccion_id`, `estado_pago`, `monto`, `proveedor`, `metadata_webhook`, `fecha_pago`, `fecha_creacion`) VALUES
(1, 1, '123456', '', 150.00, '', '{\"Tipo\":\"PAGO\",\"TransaccionPlataformaId\":\"123456\",\"TransaccionComercioId\":\"RDAM-1-1700000000000\",\"Monto\":\"150.00\",\"EstadoId\":\"3\",\"Estado\":\"REALIZADA\",\"FechaProcesamiento\":\"2026-02-27T15:00:00.000Z\"}', '2026-02-27 15:35:26', '2026-02-27 15:35:26'),
(2, 3, 'RDAM-3-1772220173601', 'PENDIENTE', 2500.00, '', NULL, '2026-02-27 16:22:53', '2026-02-27 16:22:53'),
(3, 4, 'RDAM-4-1772477518026', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 15:51:58', '2026-03-02 15:51:58'),
(4, 4, 'RDAM-4-1772479838472', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 16:30:38', '2026-03-02 16:30:38'),
(5, 4, 'RDAM-4-1772480005341', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 16:33:25', '2026-03-02 16:33:25'),
(6, 4, 'RDAM-4-1772480014401', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 16:33:34', '2026-03-02 16:33:34'),
(7, 4, 'RDAM-4-1772481027615', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 16:50:27', '2026-03-02 16:50:27'),
(8, 4, 'RDAM-4-1772481259162', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 16:54:19', '2026-03-02 16:54:19'),
(9, 4, 'RDAM-4-1772481299229', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 16:54:59', '2026-03-02 16:54:59'),
(10, 4, 'RDAM-4-1772488902191', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 19:01:42', '2026-03-02 19:01:42'),
(11, 4, 'RDAM-4-1772489425946', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 19:10:25', '2026-03-02 19:10:25'),
(12, 4, 'RDAM-4-1772490394754', 'PENDIENTE', 0.00, '', NULL, '2026-03-02 19:26:34', '2026-03-02 19:26:34'),
(13, 4, '905072', '', 0.00, '', '{\"Tipo\":\"PAGO\",\"TransaccionPlataformaId\":\"905072\",\"TransaccionComercioId\":\"RDAM-4-1772490394805\",\"Monto\":\"0.00\",\"EstadoId\":\"3\",\"Estado\":\"REALIZADA\",\"FechaProcesamiento\":\"2026-03-02T22:26:57.920Z\"}', '2026-03-02 19:26:57', '2026-03-02 19:26:57'),
(14, 6, 'RDAM-6-1772560006239', 'PENDIENTE', 0.00, '', NULL, '2026-03-03 14:46:46', '2026-03-03 14:46:46'),
(15, 6, '720327', '', 0.00, '', '{\"Tipo\":\"PAGO\",\"TransaccionPlataformaId\":\"720327\",\"TransaccionComercioId\":\"RDAM-6-1772560006255\",\"Monto\":\"0.00\",\"EstadoId\":\"3\",\"Estado\":\"REALIZADA\",\"FechaProcesamiento\":\"2026-03-03T17:47:11.893Z\"}', '2026-03-03 14:47:11', '2026-03-03 14:47:11'),
(16, 7, 'RDAM-7-1772562619809', 'PENDIENTE', 0.00, '', NULL, '2026-03-03 15:30:19', '2026-03-03 15:30:19'),
(17, 7, '698107', '', 0.00, '', '{\"Tipo\":\"PAGO\",\"TransaccionPlataformaId\":\"698107\",\"TransaccionComercioId\":\"RDAM-7-1772562619826\",\"Monto\":\"0.00\",\"EstadoId\":\"3\",\"Estado\":\"REALIZADA\",\"FechaProcesamiento\":\"2026-03-03T18:31:24.744Z\"}', '2026-03-03 15:31:24', '2026-03-03 15:31:24'),
(18, 8, 'RDAM-8-1772564562457', 'PENDIENTE', 0.00, '', NULL, '2026-03-03 16:02:42', '2026-03-03 16:02:42'),
(19, 8, '952891', '', 0.00, '', '{\"Tipo\":\"PAGO\",\"TransaccionPlataformaId\":\"952891\",\"TransaccionComercioId\":\"RDAM-8-1772564562477\",\"Monto\":\"0.00\",\"EstadoId\":\"3\",\"Estado\":\"REALIZADA\",\"FechaProcesamiento\":\"2026-03-03T19:03:07.428Z\"}', '2026-03-03 16:03:07', '2026-03-03 16:03:07'),
(20, 9, 'RDAM-9-1772566857827', 'PENDIENTE', 0.00, '', NULL, '2026-03-03 16:40:57', '2026-03-03 16:40:57'),
(21, 9, '229582', '', 0.00, '', '{\"Tipo\":\"PAGO\",\"TransaccionPlataformaId\":\"229582\",\"TransaccionComercioId\":\"RDAM-9-1772566857846\",\"Monto\":\"0.00\",\"EstadoId\":\"3\",\"Estado\":\"REALIZADA\",\"FechaProcesamiento\":\"2026-03-03T19:41:17.037Z\"}', '2026-03-03 16:41:17', '2026-03-03 16:41:17'),
(22, 10, 'RDAM-10-1772575390438', 'PENDIENTE', 0.00, '', NULL, '2026-03-03 19:03:10', '2026-03-03 19:03:10'),
(23, 10, '501944', '', 0.00, '', '{\"Tipo\":\"PAGO\",\"TransaccionPlataformaId\":\"501944\",\"TransaccionComercioId\":\"RDAM-10-1772575390518\",\"Monto\":\"0.00\",\"EstadoId\":\"3\",\"Estado\":\"REALIZADA\",\"FechaProcesamiento\":\"2026-03-03T22:03:33.523Z\"}', '2026-03-03 19:03:33', '2026-03-03 19:03:33'),
(24, 11, 'RDAM-11-1772644470104', 'PENDIENTE', 0.00, '', NULL, '2026-03-04 14:14:30', '2026-03-04 14:14:30'),
(25, 11, 'RDAM-11-1772644615065', 'PENDIENTE', 0.00, '', NULL, '2026-03-04 14:16:55', '2026-03-04 14:16:55'),
(26, 11, '584934', '', 0.00, '', '{\"Tipo\":\"PAGO\",\"TransaccionPlataformaId\":\"584934\",\"TransaccionComercioId\":\"RDAM-11-1772644615075\",\"Monto\":\"0.00\",\"EstadoId\":\"3\",\"Estado\":\"REALIZADA\",\"FechaProcesamiento\":\"2026-03-04T17:17:14.151Z\"}', '2026-03-04 14:17:14', '2026-03-04 14:17:14'),
(27, 5, 'RDAM-5-1772650622910', 'PENDIENTE', 2500.00, '', NULL, '2026-03-04 15:57:02', '2026-03-04 15:57:02'),
(28, 14, 'RDAM-14-1772821393851', 'PENDIENTE', 2500.00, '', NULL, '2026-03-06 15:23:13', '2026-03-06 15:23:13'),
(29, 14, 'RDAM-14-1772821545744', 'PENDIENTE', 2500.00, '', NULL, '2026-03-06 15:25:45', '2026-03-06 15:25:45'),
(30, 14, 'RDAM-14-1772821616081', 'PENDIENTE', 2500.00, '', NULL, '2026-03-06 15:26:56', '2026-03-06 15:26:56'),
(31, 14, 'RDAM-14-1772821631680', 'PENDIENTE', 2500.00, '', NULL, '2026-03-06 15:27:11', '2026-03-06 15:27:11'),
(32, 14, 'RDAM-14-1772821656645', 'PENDIENTE', 2500.00, '', NULL, '2026-03-06 15:27:36', '2026-03-06 15:27:36'),
(33, 14, 'RDAM-14-1772821664484', 'PENDIENTE', 2500.00, '', NULL, '2026-03-06 15:27:44', '2026-03-06 15:27:44'),
(35, 14, 'FAIL-1772821718817', 'FALLIDO', 0.00, '', '{\"TransaccionComercioId\":\"RDAM-14-1700000000000\",\"EstadoId\":\"4\",\"Estado\":\"RECHAZADA\"}', '2026-03-06 15:28:38', '2026-03-06 15:28:38'),
(36, 17, 'RDAM-17-1772829243834', 'PENDIENTE', 2500.00, '', NULL, '2026-03-06 17:34:03', '2026-03-06 17:34:03'),
(37, 17, 'RDAM-17-1772829531432', 'PENDIENTE', 2500.00, '', NULL, '2026-03-06 17:38:51', '2026-03-06 17:38:51'),
(39, 17, 'FAIL-1772829753982', 'FALLIDO', 0.00, '', '{\"TransaccionComercioId\":\"RDAM-17-1700000000000\",\"EstadoId\":\"4\",\"Estado\":\"RECHAZADA\"}', '2026-03-06 17:42:33', '2026-03-06 17:42:33');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `resolucion`
--

CREATE TABLE `resolucion` (
  `id` int(11) NOT NULL,
  `solicitud_id` int(11) NOT NULL,
  `usuario_operario_id` int(11) NOT NULL,
  `resultado` enum('APROBADO','RECHAZADO') NOT NULL,
  `observaciones` text DEFAULT NULL,
  `url_pdf` varchar(500) DEFAULT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Resolución 1:1 por solicitud — aprobación o rechazo del operario';

--
-- Volcado de datos para la tabla `resolucion`
--

INSERT INTO `resolucion` (`id`, `solicitud_id`, `usuario_operario_id`, `resultado`, `observaciones`, `url_pdf`, `fecha_emision`) VALUES
(1, 1, 5, 'APROBADO', 'Documentación verificada correctamente', 'http://localhost:3000/storage/pdfs/certificado_1_1772219302002.pdf', '2026-02-27 16:06:12'),
(2, 4, 4, 'APROBADO', NULL, NULL, '2026-03-02 19:28:52'),
(3, 6, 4, 'APROBADO', NULL, 'data:application/pdf;base64,JVBERi0xLjcNCiW1tbW1DQoxIDAgb2JqDQo8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFIvTGFuZyhlcykgL1N0cnVjdFRyZWVSb290IDEyIDAgUi9NYXJrSW5mbzw8L01hcmtlZCB0cnVlPj4vTWV0YWRhdGEgMjkgMCBSL1ZpZXdlclByZWZlcmVuY2VzIDMwIDAgUj4+DQplbmRvYmoNCjIgMCBvYmoNCjw8L1R5cGUvUGFnZXMvQ291bnQgMS9LaWRzWyAzIDAgUl0gPj4NCmVuZG9iag0KMyAwIG9iag0KPDwvVHlwZS9QYWdlL1BhcmVudCAyIDAgUi9SZXNvdXJjZXM8PC9Gb250PDwvRjEgNSAwIFI+Pi9FeHRHU3RhdGU8PC9HUzcgNyAwIFIvR1M4IDggMCBSPj4vWE9iamVjdDw8L0ltYWdlOSA5IDAgUi9JbWFnZTEwIDEwIDAg', '2026-03-03 14:58:10'),
(4, 7, 4, 'RECHAZADO', 'debes 70 lucas a tu ninio', 'data:application/pdf;base64,JVBERi0xLjYKJfbk/N8KMyAwIG9iago8PAovTGVuZ3RoIDE1OTY3OQovQml0c1BlckNvbXBvbmVudCA4Ci9Db2xvclNwYWNlIC9EZXZpY2VSR0IKL0ZpbHRlciBbL0FTQ0lJODVEZWNvZGUgL0RDVERlY29kZV0KL0hlaWdodCAxNjAwCi9TdWJ0eXBlIC9JbWFnZQovVHlwZSAvWE9iamVjdAovV2lkdGggMTEzMQo+PgpzdHJlYW0NCnM0SUEwISJfYWw4T2BbXCE8PCojISEqJyJzNFtPLCEhV1czInBZPjsjUkNZQiRPUjdLJWg5IVYlTSc8ZCZKLE5jKCpYSjInYnFUJCtzJiFOKiQtQEgyQ14lIy5RMElJMSxNMGc2cHNeVT4kbFopVlo/dSsicFA7OiM3KFM/JDRAMUskNGRVVCRrPGRgJi5vSGMmL0hIKSkmM2woJ2Q9XEUqWlE0SCpd', '2026-03-03 15:32:33'),
(5, 8, 4, 'APROBADO', NULL, NULL, '2026-03-03 16:03:44'),
(6, 9, 4, 'APROBADO', NULL, '/storage/pdfs/resolucion-9-1772566926252.pdf', '2026-03-03 16:42:06'),
(7, 10, 4, 'APROBADO', NULL, 'http://localhost:3001/storage/pdfs/resolucion-10-1772575466550.pdf', '2026-03-03 19:04:26'),
(8, 11, 4, 'APROBADO', NULL, 'http://localhost:3001/storage/pdfs/resolucion-11-1772644704020.pdf', '2026-03-04 14:18:24');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitud`
--

CREATE TABLE `solicitud` (
  `id` int(11) NOT NULL,
  `cuil` varchar(13) NOT NULL COMMENT 'CUIL del solicitante, formato XX-XXXXXXXX-X o sin guiones',
  `email_ciudadano` varchar(255) NOT NULL,
  `ciudad` enum('SANTA_FE','ROSARIO','VENADO_TUERTO','RECONQUISTA','RAFAELA') NOT NULL COMMENT 'Sede provincial más cercana al domicilio del solicitante',
  `estado` enum('PENDIENTE_PAGO','PAGADA','PENDIENTE_REVISION','EN_REVISION','APROBADA','RECHAZADA','CERTIFICADO_EMITIDO') NOT NULL DEFAULT 'PENDIENTE_PAGO',
  `operario_asignado_id` int(11) DEFAULT NULL COMMENT 'Operario que tomó la solicitud (RN-02). Se asigna en PATCH /tomar',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Trámite central: certificado digital de deuda alimenticia';

--
-- Volcado de datos para la tabla `solicitud`
--

INSERT INTO `solicitud` (`id`, `cuil`, `email_ciudadano`, `ciudad`, `estado`, `operario_asignado_id`, `fecha_creacion`) VALUES
(1, '20301234567', 'ciudadano@test.com', 'SANTA_FE', 'CERTIFICADO_EMITIDO', NULL, '2026-02-26 16:12:33'),
(2, '20301234567', 'ciudadano@test.com', 'SANTA_FE', 'PENDIENTE_PAGO', NULL, '2026-02-27 16:16:36'),
(3, '20301234567', 'ciudadano@test.com', 'SANTA_FE', 'PENDIENTE_PAGO', NULL, '2026-02-27 16:22:29'),
(4, '20415147938', 'lauta.acvd@gmail.com', 'SANTA_FE', 'APROBADA', NULL, '2026-03-02 15:51:55'),
(5, '20415147938', 'lauta.acvd@gmail.com', 'SANTA_FE', 'PENDIENTE_PAGO', NULL, '2026-03-03 14:40:49'),
(6, '20415147938', 'lauta.acvd@gmail.com', 'SANTA_FE', 'APROBADA', NULL, '2026-03-03 14:46:44'),
(7, '20415147938', 'lauta.acvd@gmail.com', 'SANTA_FE', 'RECHAZADA', NULL, '2026-03-03 15:30:17'),
(8, '20415147938', 'lauta.acvd@gmail.com', 'SANTA_FE', 'EN_REVISION', NULL, '2026-03-03 16:02:41'),
(9, '20415147938', 'lauta.acvd@gmail.com', 'SANTA_FE', 'APROBADA', NULL, '2026-03-03 16:40:56'),
(10, '20415147938', 'lauta.acvd@gmail.com', 'SANTA_FE', 'APROBADA', NULL, '2026-03-03 19:03:05'),
(11, '20415147938', 'lauta.acvd@gmail.com', 'ROSARIO', 'APROBADA', NULL, '2026-03-04 14:14:26'),
(12, '20301234567', 'lauta.acvd@gmail.com', 'SANTA_FE', 'PENDIENTE_PAGO', NULL, '2026-03-04 15:37:38'),
(13, '20301234567', 'lauta.acvd@gmail.com', 'SANTA_FE', 'PENDIENTE_PAGO', NULL, '2026-03-04 15:44:08'),
(14, '20301234567', 'lauta.acvd@gmail.com', 'SANTA_FE', 'PENDIENTE_REVISION', NULL, '2026-03-06 14:51:13'),
(15, '20301234567', 'lauta.acvd@gmail.com', 'SANTA_FE', 'PENDIENTE_PAGO', NULL, '2026-03-06 15:20:56'),
(16, '20301234567', 'lauta.acvd@gmail.com', 'SANTA_FE', 'PENDIENTE_PAGO', NULL, '2026-03-06 17:02:24'),
(17, '20301234567', 'lauta.acvd@gmail.com', 'SANTA_FE', 'EN_REVISION', NULL, '2026-03-06 17:31:55');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `rol` enum('ADMIN','OPERADOR') NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_desactivacion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Empleados internos: operarios y administradores del sistema';

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `nombre`, `email`, `password_hash`, `rol`, `activo`, `fecha_creacion`, `fecha_desactivacion`) VALUES
(4, 'Administrador RDAM', 'admin@rdam.gob.ar', '$2a$12$xFoa3tgTLMNL4wgvgsnEtuK.sPW0rejtu0KtEMv/vZwhiZkPbsHUu', 'ADMIN', 1, '2026-02-27 15:56:49', NULL),
(5, 'Juan Operador', 'operador@rdam.gob.ar', '$2a$12$64hk7WyEdKwREjY3d.sdJOiSS6yPKads.HEasNn8TWhDyD8UR/v8G', 'OPERADOR', 1, '2026-02-27 16:00:11', NULL),
(6, 'lautaro acevedo', 'lauta.acvd@gmail.com', '$2a$12$8sTEuFgrQZ4HJ/njACz5cuIZznOxcR4LUcJyO92KwZYdNFHdY70Oy', 'OPERADOR', 1, '2026-03-03 21:56:37', NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_auditoria_usuario_id` (`usuario_id`),
  ADD KEY `idx_auditoria_solicitud_id` (`solicitud_id`);

--
-- Indices de la tabla `historial_estado_solicitud`
--
ALTER TABLE `historial_estado_solicitud`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_historial_solicitud_id` (`solicitud_id`),
  ADD KEY `idx_historial_usuario_id` (`usuario_id`);

--
-- Indices de la tabla `otp_session`
--
ALTER TABLE `otp_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_otp_session_email` (`email`);

--
-- Indices de la tabla `pago`
--
ALTER TABLE `pago`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pago_transaccion_id` (`transaccion_id`),
  ADD KEY `idx_pago_solicitud_id` (`solicitud_id`);

--
-- Indices de la tabla `resolucion`
--
ALTER TABLE `resolucion`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_resolucion_solicitud_id` (`solicitud_id`),
  ADD KEY `idx_resolucion_usuario_operario_id` (`usuario_operario_id`);

--
-- Indices de la tabla `solicitud`
--
ALTER TABLE `solicitud`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_solicitud_cuil` (`cuil`),
  ADD KEY `idx_solicitud_estado` (`estado`),
  ADD KEY `idx_solicitud_ciudad` (`ciudad`),
  ADD KEY `idx_solicitud_email_ciudadano` (`email_ciudadano`),
  ADD KEY `idx_solicitud_operario_asignado` (`operario_asignado_id`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_usuario_email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT de la tabla `historial_estado_solicitud`
--
ALTER TABLE `historial_estado_solicitud`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT de la tabla `otp_session`
--
ALTER TABLE `otp_session`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT de la tabla `pago`
--
ALTER TABLE `pago`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `resolucion`
--
ALTER TABLE `resolucion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `solicitud`
--
ALTER TABLE `solicitud`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD CONSTRAINT `fk_auditoria_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitud` (`id`),
  ADD CONSTRAINT `fk_auditoria_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`);

--
-- Filtros para la tabla `historial_estado_solicitud`
--
ALTER TABLE `historial_estado_solicitud`
  ADD CONSTRAINT `fk_historial_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitud` (`id`),
  ADD CONSTRAINT `fk_historial_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`);

--
-- Filtros para la tabla `pago`
--
ALTER TABLE `pago`
  ADD CONSTRAINT `fk_pago_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitud` (`id`);

--
-- Filtros para la tabla `resolucion`
--
ALTER TABLE `resolucion`
  ADD CONSTRAINT `fk_resolucion_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitud` (`id`),
  ADD CONSTRAINT `fk_resolucion_usuario` FOREIGN KEY (`usuario_operario_id`) REFERENCES `usuario` (`id`);

--
-- Filtros para la tabla `solicitud`
--
ALTER TABLE `solicitud`
  ADD CONSTRAINT `fk_solicitud_operario` FOREIGN KEY (`operario_asignado_id`) REFERENCES `usuario` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
