USE garage_elite_campus;

-- 1. Listado de citas pendientes ordenadas por fecha mas cercana
SELECT 
    c.id AS cita_id,
    c.fecha_programada,
    CONCAT(cl.nombres, ' ', cl.apellidos) AS cliente,
    v.placa,
    s.nombre AS servicio,
    c.precio_final
FROM citas_servicio c
INNER JOIN vehiculos v ON c.vehiculo_id = v.id
INNER JOIN clientes cl ON v.cliente_id = cl.id
INNER JOIN servicios s ON c.servicio_id = s.id
WHERE c.estado = 'pendiente'
ORDER BY c.fecha_programada ASC;

-- 2. Total estimado acumulado por estado de cita
SELECT 
    estado,
    COUNT(*) AS total_citas,
    SUM(precio_final) AS monto_total_estimado,
    AVG(precio_final) AS precio_promedio
FROM citas_servicio
GROUP BY estado;

-- 3. Ranking de mecanicos por cantidad de citas atendidas
SELECT 
    m.id AS mecanico_id,
    CONCAT(m.nombres, ' ', m.apellidos) AS mecanico,
    m.especialidad,
    COUNT(c.id) AS total_citas_atendidas
FROM mecanicos m
LEFT JOIN citas_servicio c 
    ON m.id = c.mecanico_id
    AND c.estado IN ('en_proceso', 'completada')
GROUP BY m.id, m.nombres, m.apellidos, m.especialidad
ORDER BY total_citas_atendidas DESC;

-- 4. Vehiculos con mas de una cita registrada
SELECT 
    v.id AS vehiculo_id,
    v.marca,
    v.modelo,
    v.placa,
    CONCAT(cl.nombres, ' ', cl.apellidos) AS propietario,
    COUNT(c.id) AS cantidad_citas
FROM vehiculos v
INNER JOIN clientes cl 
    ON v.cliente_id = cl.id
INNER JOIN citas_servicio c 
    ON v.id = c.vehiculo_id
GROUP BY 
    v.id,
    v.marca,
    v.modelo,
    v.placa,
    cl.nombres,
    cl.apellidos
HAVING COUNT(c.id) > 1;

-- 5. Servicios mas solicitados y promedio de precio final
SELECT 
    s.id AS servicio_id,
    s.nombre AS servicio,
    s.categoria,
    COUNT(c.id) AS cantidad_solicitudes,
    AVG(c.precio_final) AS precio_final_promedio
FROM servicios s
INNER JOIN citas_servicio c ON s.id = c.servicio_id
GROUP BY s.id, s.nombre, s.categoria
ORDER BY cantidad_solicitudes DESC;