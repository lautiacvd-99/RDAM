-- Inicialización Docker RDAM
CREATE DATABASE IF NOT EXISTS rdam_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rdam_db;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------
-- Estructura de tabla `auditoria`
-- --------------------------------------------------------

CREATE TABLE `auditoria` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `accion` varchar(100) NOT NULL,
  `solicitud_id` int(11) DEFAULT NULL,
  `detalle` text DEFAULT NULL,
  `ip_origen` varchar(45) DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Log inmutable de acciones del sistema — solo INSERT';

-- Solo auditoría relacionada a solicitudes 1 y 2, y logins necesarios
INSERT INTO `auditoria` (`id`, `usuario_id`, `accion`, `solicitud_id`, `detalle`, `ip_origen`, `fecha`) VALUES
(1, 4, 'LOGIN', NULL, NULL, '::1', '2026-02-27 15:56:57'),
(2, 4, 'USUARIO_CREADO', NULL, 'email: operador@rdam.gob.ar, rol: OPERADOR', '::1', '2026-02-27 16:00:11'),
(3, 5, 'LOGIN', NULL, NULL, '::1', '2026-02-27 16:01:13'),
(4, 5, 'RESOLUCION_EMITIDA', 1, 'resultado: APROBADO', '::1', '2026-02-27 16:06:12');

-- --------------------------------------------------------
-- Estructura de tabla `historial_estado_solicitud`
-- --------------------------------------------------------

CREATE TABLE `historial_estado_solicitud` (
  `id` int(11) NOT NULL,
  `solicitud_id` int(11) NOT NULL,
  `estado_anterior` enum('PENDIENTE_PAGO','PAGADA','PENDIENTE_REVISION','EN_REVISION','APROBADA','RECHAZADA','CERTIFICADO_EMITIDO') DEFAULT NULL,
  `estado_nuevo` enum('PENDIENTE_PAGO','PAGADA','PENDIENTE_REVISION','EN_REVISION','APROBADA','RECHAZADA','CERTIFICADO_EMITIDO') NOT NULL,
  `usuario_id` int(11) DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `observacion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Registro inmutable append-only de transiciones de estado (RN-08)';

-- Historial solo de solicitudes 1 y 2
INSERT INTO `historial_estado_solicitud` (`id`, `solicitud_id`, `estado_anterior`, `estado_nuevo`, `usuario_id`, `fecha`, `observacion`) VALUES
(1, 1, NULL, 'PENDIENTE_PAGO', NULL, '2026-02-26 16:12:33', 'Solicitud creada por ciudadano'),
(2, 1, 'PENDIENTE_PAGO', 'PAGADA', NULL, '2026-02-27 15:35:26', 'Confirmado por PlusPagos. TransaccionPlataformaId: 123456'),
(3, 1, 'PAGADA', 'PENDIENTE_REVISION', NULL, '2026-02-27 15:35:26', 'Transición automática post-pago'),
(4, 1, 'PENDIENTE_REVISION', 'EN_REVISION', 5, '2026-02-27 16:04:30', NULL),
(5, 1, 'EN_REVISION', 'APROBADA', 5, '2026-02-27 16:06:12', 'Documentación verificada correctamente'),
(6, 1, 'APROBADA', 'CERTIFICADO_EMITIDO', NULL, '2026-02-27 16:08:22', 'PDF generado y almacenado'),
(7, 2, NULL, 'PENDIENTE_PAGO', NULL, '2026-02-27 16:16:36', 'Solicitud creada por ciudadano');

-- --------------------------------------------------------
-- Estructura de tabla `otp_session`
-- --------------------------------------------------------

CREATE TABLE `otp_session` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `codigo` varchar(4) NOT NULL,
  `expiracion` datetime NOT NULL,
  `usado` tinyint(1) NOT NULL DEFAULT 0,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='OTP de un solo uso para autenticación del ciudadano (RN-04)';

-- otp_session vacío — los OTPs son temporales, no tiene sentido seed
-- (sin INSERT)

-- --------------------------------------------------------
-- Estructura de tabla `pago`
-- --------------------------------------------------------

CREATE TABLE `pago` (
  `id` int(11) NOT NULL,
  `solicitud_id` int(11) NOT NULL,
  `transaccion_id` varchar(100) NOT NULL,
  `estado_pago` enum('PENDIENTE','APROBADO','CONFIRMADO','FALLIDO') NOT NULL DEFAULT 'PENDIENTE',
  `monto` decimal(10,2) NOT NULL,
  `proveedor` varchar(50) NOT NULL DEFAULT 'pluspagos',
  `metadata_webhook` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata_webhook`)),
  `fecha_pago` datetime DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Transacciones de arancel — idempotencia garantizada por transaccion_id';

-- Solo el pago aprobado de la solicitud 1
INSERT INTO `pago` (`id`, `solicitud_id`, `transaccion_id`, `estado_pago`, `monto`, `proveedor`, `metadata_webhook`, `fecha_pago`, `fecha_creacion`) VALUES
(1, 1, '123456', 'APROBADO', 2500.00, 'pluspagos', '{"Tipo":"PAGO","TransaccionPlataformaId":"123456","TransaccionComercioId":"RDAM-1-1772219302000","Monto":"2500.00","EstadoId":"3","Estado":"REALIZADA","FechaProcesamiento":"2026-02-27T18:35:26.000Z"}', '2026-02-27 15:35:26', '2026-02-27 15:35:26');

-- --------------------------------------------------------
-- Estructura de tabla `resolucion`
-- --------------------------------------------------------

CREATE TABLE `resolucion` (
  `id` int(11) NOT NULL,
  `solicitud_id` int(11) NOT NULL,
  `usuario_operario_id` int(11) NOT NULL,
  `resultado` enum('APROBADO','RECHAZADO') NOT NULL,
  `observaciones` text DEFAULT NULL,
  `url_pdf` varchar(500) DEFAULT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Resolución 1:1 por solicitud — aprobación o rechazo del operario';

-- Solo la resolución de la solicitud 1
INSERT INTO `resolucion` (`id`, `solicitud_id`, `usuario_operario_id`, `resultado`, `observaciones`, `url_pdf`, `fecha_emision`) VALUES
(1, 1, 5, 'APROBADO', 'Documentación verificada correctamente', 'http://localhost/storage/pdfs/certificado_1_demo.pdf', '2026-02-27 16:06:12');

-- --------------------------------------------------------
-- Estructura de tabla `solicitud`
-- --------------------------------------------------------

CREATE TABLE `solicitud` (
  `id` int(11) NOT NULL,
  `cuil` varchar(13) NOT NULL COMMENT 'CUIL del solicitante, formato XX-XXXXXXXX-X o sin guiones',
  `email_ciudadano` varchar(255) NOT NULL,
  `ciudad` enum('SANTA_FE','ROSARIO','VENADO_TUERTO','RECONQUISTA','RAFAELA') NOT NULL COMMENT 'Sede provincial más cercana al domicilio del solicitante',
  `estado` enum('PENDIENTE_PAGO','PAGADA','PENDIENTE_REVISION','EN_REVISION','APROBADA','RECHAZADA','CERTIFICADO_EMITIDO') NOT NULL DEFAULT 'PENDIENTE_PAGO',
  `operario_asignado_id` int(11) DEFAULT NULL COMMENT 'Operario que tomó la solicitud (RN-02). Se asigna en PATCH /tomar',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Trámite central: certificado digital de deuda alimenticia';

-- Las 2 primeras solicitudes
INSERT INTO `solicitud` (`id`, `cuil`, `email_ciudadano`, `ciudad`, `estado`, `operario_asignado_id`, `fecha_creacion`) VALUES
(1, '20301234567', 'ciudadano@test.com', 'SANTA_FE', 'CERTIFICADO_EMITIDO', NULL, '2026-02-26 16:12:33'),
(2, '20301234567', 'ciudadano@test.com', 'SANTA_FE', 'PENDIENTE_PAGO', NULL, '2026-02-27 16:16:36');

-- --------------------------------------------------------
-- Estructura de tabla `usuario`
-- --------------------------------------------------------

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

INSERT INTO `usuario` (`id`, `nombre`, `email`, `password_hash`, `rol`, `activo`, `fecha_creacion`, `fecha_desactivacion`) VALUES
(4, 'Administrador RDAM', 'admin@rdam.gob.ar', '$2a$12$xFoa3tgTLMNL4wgvgsnEtuK.sPW0rejtu0KtEMv/vZwhiZkPbsHUu', 'ADMIN', 1, '2026-02-27 15:56:49', NULL),
(5, 'Juan Operador', 'operador@rdam.gob.ar', '$2a$12$64hk7WyEdKwREjY3d.sdJOiSS6yPKads.HEasNn8TWhDyD8UR/v8G', 'OPERADOR', 1, '2026-02-27 16:00:11', NULL),
(6, 'lautaro acevedo', 'lauta.acvd@gmail.com', '$2a$12$8sTEuFgrQZ4HJ/njACz5cuIZznOxcR4LUcJyO92KwZYdNFHdY70Oy', 'OPERADOR', 1, '2026-03-03 21:56:37', NULL);

-- --------------------------------------------------------
-- Índices
-- --------------------------------------------------------

ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_auditoria_usuario_id` (`usuario_id`),
  ADD KEY `idx_auditoria_solicitud_id` (`solicitud_id`);

ALTER TABLE `historial_estado_solicitud`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_historial_solicitud_id` (`solicitud_id`),
  ADD KEY `idx_historial_usuario_id` (`usuario_id`);

ALTER TABLE `otp_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_otp_session_email` (`email`);

ALTER TABLE `pago`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pago_transaccion_id` (`transaccion_id`),
  ADD KEY `idx_pago_solicitud_id` (`solicitud_id`);

ALTER TABLE `resolucion`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_resolucion_solicitud_id` (`solicitud_id`),
  ADD KEY `idx_resolucion_usuario_operario_id` (`usuario_operario_id`);

ALTER TABLE `solicitud`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_solicitud_cuil` (`cuil`),
  ADD KEY `idx_solicitud_estado` (`estado`),
  ADD KEY `idx_solicitud_ciudad` (`ciudad`),
  ADD KEY `idx_solicitud_email_ciudadano` (`email_ciudadano`),
  ADD KEY `idx_solicitud_operario_asignado` (`operario_asignado_id`);

ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_usuario_email` (`email`);

-- --------------------------------------------------------
-- AUTO_INCREMENT
-- --------------------------------------------------------

ALTER TABLE `auditoria`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

ALTER TABLE `historial_estado_solicitud`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

ALTER TABLE `otp_session`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

ALTER TABLE `pago`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE `resolucion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE `solicitud`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

-- --------------------------------------------------------
-- Foreign Keys
-- --------------------------------------------------------

ALTER TABLE `auditoria`
  ADD CONSTRAINT `fk_auditoria_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitud` (`id`),
  ADD CONSTRAINT `fk_auditoria_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`);

ALTER TABLE `historial_estado_solicitud`
  ADD CONSTRAINT `fk_historial_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitud` (`id`),
  ADD CONSTRAINT `fk_historial_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`);

ALTER TABLE `pago`
  ADD CONSTRAINT `fk_pago_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitud` (`id`);

ALTER TABLE `resolucion`
  ADD CONSTRAINT `fk_resolucion_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitud` (`id`),
  ADD CONSTRAINT `fk_resolucion_usuario` FOREIGN KEY (`usuario_operario_id`) REFERENCES `usuario` (`id`);

ALTER TABLE `solicitud`
  ADD CONSTRAINT `fk_solicitud_operario` FOREIGN KEY (`operario_asignado_id`) REFERENCES `usuario` (`id`);

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;