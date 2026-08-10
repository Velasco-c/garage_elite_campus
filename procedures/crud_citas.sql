USE garage_elite_campus;

DELIMITER //

-- -----------------------------------------------------------------------------
-- 1. CREAR CITA DE SERVICIO
-- -----------------------------------------------------------------------------
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
    DECLARE v_mecanico_activo BOOLEAN;
    DECLARE v_vehiculo_existe INT;
    DECLARE v_servicio_existe INT;

    IF p_fecha_programada IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La fecha programada no puede ser nula.';
    END IF;

    IF p_precio_final < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El precio final no puede ser negativo.';
    END IF;

    SELECT COUNT(*) INTO v_vehiculo_existe FROM vehiculos WHERE id = p_vehiculo_id;
    IF v_vehiculo_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El vehiculo especificado no existe.';
    END IF;

    SELECT COUNT(*) INTO v_servicio_existe FROM servicios WHERE id = p_servicio_id;
    IF v_servicio_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El servicio especificado no existe.';
    END IF;

    SELECT activo INTO v_mecanico_activo FROM mecanicos WHERE id = p_mecanico_id;
    IF v_mecanico_activo IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El mecanico especificado no existe.';
    ELSEIF v_mecanico_activo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El mecanico asignado no se encuentra activo.';
    END IF;

    START TRANSACTION;
        INSERT INTO citas_servicio (
            vehiculo_id, servicio_id, mecanico_id, 
            fecha_programada, estado, precio_final, notas
        ) VALUES (
            p_vehiculo_id, p_servicio_id, p_mecanico_id, 
            p_fecha_programada, 'pendiente', p_precio_final, p_notas
        );
        SET p_cita_id = LAST_INSERT_ID();
    COMMIT;
END//

-- -----------------------------------------------------------------------------
-- 2. LISTAR / CONSULTAR CITAS
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- 3. ACTUALIZAR CITA DE SERVICIO
-- -----------------------------------------------------------------------------
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
    DECLARE v_estado_actual VARCHAR(20);
    DECLARE v_mecanico_activo BOOLEAN;

    SELECT estado INTO v_estado_actual FROM citas_servicio WHERE id = p_cita_id;
    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La cita a actualizar no existe.';
    END IF;

    IF v_estado_actual = 'cancelada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No se puede modificar una cita que ya ha sido cancelada.';
    END IF;

    IF p_estado NOT IN ('pendiente', 'en_proceso', 'completada', 'cancelada') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El estado indicado no es valido.';
    END IF;

    IF p_precio_final < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El precio final no puede ser negativo.';
    END IF;

    SELECT activo INTO v_mecanico_activo FROM mecanicos WHERE id = p_mecanico_id;
    IF v_mecanico_activo IS NULL OR v_mecanico_activo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El mecanico no existe o no esta activo.';
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

-- -----------------------------------------------------------------------------
-- 4. CANCELAR CITA DE SERVICIO (Eliminacion Logica)
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_cancelar_cita_servicio//
CREATE PROCEDURE sp_cancelar_cita_servicio(
    IN p_cita_id INT,
    IN p_motivo VARCHAR(255)
)
BEGIN
    DECLARE v_estado_actual VARCHAR(20);

    SELECT estado INTO v_estado_actual FROM citas_servicio WHERE id = p_cita_id;

    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La cita especificada no existe.';
    END IF;

    IF v_estado_actual = 'cancelada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La cita ya se encuentra cancelada.';
    END IF;

    IF v_estado_actual = 'completada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No se puede cancelar una cita que ya fue completada.';
    END IF;

    START TRANSACTION;
        UPDATE citas_servicio
        SET estado = 'cancelada',
            notas = CONCAT(IFNULL(notas, ''), ' | Motivo Cancelacion: ', IFNULL(p_motivo, 'No especificado'))
        WHERE id = p_cita_id;
    COMMIT;
END//

-- -----------------------------------------------------------------------------
-- 5. ELIMINAR CITA BORRADOR (Eliminacion Fisica Controlada)
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_eliminar_cita_borrador//
CREATE PROCEDURE sp_eliminar_cita_borrador(
    IN p_cita_id INT
)
BEGIN
    DECLARE v_estado_actual VARCHAR(20);

    SELECT estado INTO v_estado_actual FROM citas_servicio WHERE id = p_cita_id;

    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La cita a eliminar no existe.';
    END IF;

    IF v_estado_actual != 'pendiente' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Solo se pueden eliminar fisicamente citas en estado pendiente.';
    END IF;

    START TRANSACTION;
        DELETE FROM citas_servicio WHERE id = p_cita_id;
    COMMIT;
END//

DELIMITER ;