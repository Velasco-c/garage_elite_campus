USE garage_elite_campus;

DELIMITER //

-- ============================================================
-- 1. CREAR CITA DE SERVICIO
-- ============================================================
DROP PROCEDURE IF EXISTS sp_crear_cita_servicio//
CREATE PROCEDURE sp_crear_cita_servicio(
    IN p_vehiculo_id INT,
    IN p_servicio_id INT,
    IN p_mecanico_id INT,
    IN p_fecha_programada DATETIME,
    IN p_precio_final DECIMAL(10,2),
    IN p_notas VARCHAR(255),
    OUT p_cita_id INT
)
BEGIN
    DECLARE v_mecanico_activo BOOLEAN DEFAULT NULL;
    DECLARE v_vehiculo_existe INT DEFAULT 0;
    DECLARE v_servicio_existe INT DEFAULT 0;
    DECLARE v_servicio_estado VARCHAR(25) DEFAULT NULL;

    -- Validar fecha
    IF p_fecha_programada IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La fecha programada no puede ser nula.';
    END IF;

    -- Validar precio
    IF p_precio_final IS NULL OR p_precio_final < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El precio final no puede ser negativo ni nulo.';
    END IF;

    -- Validar existencia del vehiculo
    SELECT COUNT(*) INTO v_vehiculo_existe FROM vehiculos WHERE id = p_vehiculo_id;
    IF v_vehiculo_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El vehiculo especificado no existe.';
    END IF;

    -- Validar existencia y disponibilidad del servicio
    SELECT COUNT(*), MAX(estado) INTO v_servicio_existe, v_servicio_estado FROM servicios WHERE id = p_servicio_id;
    IF v_servicio_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El servicio especificado no existe.';
    END IF;

    IF v_servicio_estado <> 'Disponible' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El servicio seleccionado no se encuentra disponible.';
    END IF;

    -- Validar existencia y estado del mecanico
    SELECT activo INTO v_mecanico_activo FROM mecanicos WHERE id = p_mecanico_id;
    IF v_mecanico_activo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El mecanico especificado no existe.';
    ELSEIF v_mecanico_activo = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El mecanico asignado no se encuentra activo.';
    END IF;

    -- Crear la cita
    START TRANSACTION;
        INSERT INTO citas_servicio (vehiculo_id, servicio_id, mecanico_id, fecha_programada, estado, precio_final, notas)
        VALUES (p_vehiculo_id, p_servicio_id, p_mecanico_id, p_fecha_programada, 'pendiente', p_precio_final, p_notas);
        SET p_cita_id = LAST_INSERT_ID();
    COMMIT;
END//

-- ============================================================
-- 2. LISTAR / CONSULTAR CITAS
-- ============================================================
DROP PROCEDURE IF EXISTS sp_listar_citas_servicio//
CREATE PROCEDURE sp_listar_citas_servicio(
    IN p_estado VARCHAR(20)
)
BEGIN
    SELECT
        c.id AS cita_id,
        CONCAT(cl.nombres, ' ', cl.apellidos) AS cliente,
        CONCAT(v.marca, ' ', v.modelo, ' (', v.placa, ')') AS vehiculo,
        s.nombre AS servicio,
        CONCAT(m.nombres, ' ', m.apellidos) AS mecanico,
        c.fecha_programada,
        c.estado,
        c.precio_final,
        c.notas
    FROM citas_servicio c
    INNER JOIN vehiculos v ON c.vehiculo_id = v.id
    INNER JOIN clientes cl ON v.cliente_id = cl.id
    INNER JOIN servicios s ON c.servicio_id = s.id
    INNER JOIN mecanicos m ON c.mecanico_id = m.id
    WHERE (p_estado IS NULL OR c.estado = p_estado)
    ORDER BY c.fecha_programada ASC;
END//

-- ============================================================
-- 3. ACTUALIZAR CITA DE SERVICIO
-- ============================================================
DROP PROCEDURE IF EXISTS sp_actualizar_cita_servicio//
CREATE PROCEDURE sp_actualizar_cita_servicio(
    IN p_cita_id INT,
    IN p_mecanico_id INT,
    IN p_fecha_programada DATETIME,
    IN p_estado VARCHAR(20),
    IN p_precio_final DECIMAL(10,2),
    IN p_notas VARCHAR(255)
)
BEGIN
    DECLARE v_estado_actual VARCHAR(20) DEFAULT NULL;
    DECLARE v_mecanico_activo BOOLEAN DEFAULT NULL;
    DECLARE v_cita_existe INT DEFAULT 0;

    SELECT COUNT(*) INTO v_cita_existe FROM citas_servicio WHERE id = p_cita_id;
    IF v_cita_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La cita a actualizar no existe.';
    END IF;

    SELECT estado INTO v_estado_actual FROM citas_servicio WHERE id = p_cita_id;
    IF v_estado_actual = 'cancelada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se puede modificar una cita que ya ha sido cancelada.';
    END IF;

    IF p_fecha_programada IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La fecha programada no puede ser nula.';
    END IF;

    IF p_estado IS NULL OR p_estado NOT IN ('pendiente', 'en_proceso', 'completada', 'cancelada') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El estado indicado no es valido.';
    END IF;

    IF p_precio_final IS NULL OR p_precio_final < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El precio final no puede ser negativo ni nulo.';
    END IF;

    SELECT activo INTO v_mecanico_activo FROM mecanicos WHERE id = p_mecanico_id;
    IF v_mecanico_activo IS NULL OR v_mecanico_activo = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El mecanico no existe o no esta activo.';
    END IF;

    START TRANSACTION;
        UPDATE citas_servicio
        SET mecanico_id = p_mecanico_id,
            fecha_programada = p_fecha_programada,
            estado = p_estado,
            precio_final = p_precio_final,
            notas = p_notas
        WHERE id = p_cita_id;
    COMMIT;
END//

-- ============================================================
-- 4. CANCELAR CITA DE SERVICIO
--    ELIMINACION LOGICA
-- ============================================================
DROP PROCEDURE IF EXISTS sp_cancelar_cita_servicio//
CREATE PROCEDURE sp_cancelar_cita_servicio(
    IN p_cita_id INT,
    IN p_motivo VARCHAR(255)
)
BEGIN
    DECLARE v_estado_actual VARCHAR(20) DEFAULT NULL;
    DECLARE v_cita_existe INT DEFAULT 0;

    SELECT COUNT(*) INTO v_cita_existe FROM citas_servicio WHERE id = p_cita_id;
    IF v_cita_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La cita especificada no existe.';
    END IF;

    SELECT estado INTO v_estado_actual FROM citas_servicio WHERE id = p_cita_id;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Debe especificarse un motivo de cancelacion.';
    END IF;

    IF v_estado_actual = 'cancelada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La cita ya se encuentra cancelada.';
    END IF;

    IF v_estado_actual = 'completada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se puede cancelar una cita que ya fue completada.';
    END IF;

    START TRANSACTION;
        UPDATE citas_servicio
        SET estado = 'cancelada',
            notas = CONCAT(IFNULL(notas, ''), ' | Motivo Cancelacion: ', p_motivo)
        WHERE id = p_cita_id;
    COMMIT;
END//

-- ============================================================
-- 5. ELIMINAR CITA BORRADOR
--    ELIMINACION FISICA CONTROLADA
-- ============================================================
DROP PROCEDURE IF EXISTS sp_eliminar_cita_borrador//
CREATE PROCEDURE sp_eliminar_cita_borrador(
    IN p_cita_id INT
)
BEGIN
    DECLARE v_estado_actual VARCHAR(20) DEFAULT NULL;
    DECLARE v_cita_existe INT DEFAULT 0;

    SELECT COUNT(*) INTO v_cita_existe FROM citas_servicio WHERE id = p_cita_id;
    IF v_cita_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La cita a eliminar no existe.';
    END IF;

    SELECT estado INTO v_estado_actual FROM citas_servicio WHERE id = p_cita_id;

    IF v_estado_actual <> 'pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Solo se pueden eliminar fisicamente citas en estado pendiente.';
    END IF;

    START TRANSACTION;
        DELETE FROM citas_servicio WHERE id = p_cita_id;
    COMMIT;
END//

DELIMITER ;


-- ============================================================
-- PRUEBAS DE PROCEDIMIENTOS
-- ============================================================

USE garage_elite_campus;


-- ============================================================
-- 1. CREAR CITA
-- ============================================================

CALL sp_crear_cita_servicio(
    1,
    2,
    1,
    '2026-08-17 09:00:00',
    450.00,
    'Revision del sistema de frenos',
    @nueva_cita
);

SELECT @nueva_cita AS cita_creada_id;


-- ============================================================
-- 2. LISTAR CITAS PENDIENTES
-- ============================================================

CALL sp_listar_citas_servicio('pendiente');


-- ============================================================
-- 3. ACTUALIZAR CITA
-- ============================================================

CALL sp_actualizar_cita_servicio(
    @nueva_cita,
    2,
    '2026-08-17 10:00:00',
    'en_proceso',
    500.00,
    'Cliente autorizo ajuste de ultima hora'
);


-- Comprobar la actualizacion

CALL sp_listar_citas_servicio('en_proceso');


-- ============================================================
-- 4. CANCELAR CITA
-- ============================================================

CALL sp_cancelar_cita_servicio(
    @nueva_cita,
    'Cliente reprogramara para el proximo mes'
);


-- Comprobar la cancelacion

CALL sp_listar_citas_servicio('cancelada');


-- ============================================================
-- 5. CREAR CITA PARA PROBAR ELIMINACION FISICA
-- ============================================================

CALL sp_crear_cita_servicio(
    10,
    1,
    8,
    '2026-08-20 10:00:00',
    250.00,
    'Cita de prueba para eliminacion fisica',
    @cita_borrador
);

SELECT @cita_borrador AS cita_borrador_id;


-- ============================================================
-- 6. ELIMINAR CITA PENDIENTE
-- ============================================================

CALL sp_eliminar_cita_borrador(@cita_borrador);


-- Comprobar que ya no existe

SELECT *
FROM citas_servicio
WHERE id = @cita_borrador;


-- ============================================================
-- PRUEBAS DE ERROR CONTROLADO
-- ============================================================


-- ============================================================
-- 7. PRECIO NEGATIVO
-- Resultado esperado:
-- Error: El precio final no puede ser negativo ni nulo.
-- ============================================================

CALL sp_crear_cita_servicio(
    1,
    1,
    1,
    '2026-08-18 10:00:00',
    -100.00,
    'Prueba precio negativo',
    @cita_error
);


-- ============================================================
-- 8. MECANICO INACTIVO
-- El mecanico 7 esta configurado como inactivo.
--
-- Resultado esperado:
-- Error: El mecanico asignado no se encuentra activo.
-- ============================================================

CALL sp_crear_cita_servicio(
    1,
    1,
    7,
    '2026-08-18 10:00:00',
    250.00,
    'Prueba mecanico inactivo',
    @cita_error
);


-- ============================================================
-- 9. MODIFICAR CITA CANCELADA
-- @nueva_cita fue cancelada anteriormente.
--
-- Resultado esperado:
-- Error: No se puede modificar una cita que ya ha sido cancelada.
-- ============================================================

CALL sp_actualizar_cita_servicio(
    @nueva_cita,
    1,
    '2026-08-19 10:00:00',
    'en_proceso',
    500.00,
    'Intento ilegal de edicion'
);


-- ============================================================
-- 10. CANCELAR CITA COMPLETADA
-- La cita 2 fue cargada inicialmente como completada.
--
-- Resultado esperado:
-- Error: No se puede cancelar una cita que ya fue completada.
-- ============================================================

CALL sp_cancelar_cita_servicio(
    2,
    'Intento de cancelar cita completada'
);


-- ============================================================
-- 11. ELIMINAR CITA QUE NO ESTA PENDIENTE
-- La cita 2 esta completada.
--
-- Resultado esperado:
-- Error: Solo se pueden eliminar fisicamente citas
-- en estado pendiente.
-- ============================================================

CALL sp_eliminar_cita_borrador(2);


-- ============================================================
-- 12. CONSULTAR TODAS LAS CITAS
-- ============================================================

CALL sp_listar_citas_servicio(NULL);
