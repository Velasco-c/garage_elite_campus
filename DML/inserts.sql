USE campuslands_mysql;

-- CLIENTES (10 registros)
INSERT INTO clientes (nombres, apellidos, telefono, email, estado, creado_en) VALUES
('Jose Luis', 'Hernandez Hernandez', '0001-0001', 'joseluis@gmail.com', 'Activo', '2026-08-07 08:00:00'),
('Maria Fernanda', 'Lopez Garcia', '0002-0002', 'maria.lopez@gmail.com', 'Activo', '2026-08-07 08:15:00'),
('Carlos Alberto', 'Ramirez Perez', '0003-0003', 'carlos.ramirez@gmail.com', 'Activo', '2026-08-07 08:30:00'),
('Ana Sofia', 'Morales Diaz', '0004-0004', 'ana.morales@gmail.com', 'Activo', '2026-08-07 08:45:00'),
('Luis Enrique', 'Castillo Gomez', '0005-0005', 'luis.castillo@gmail.com', 'Inactivo', '2026-08-07 09:00:00'),
('Daniela', 'Mendez Ruiz', '0006-0006', 'daniela.mendez@gmail.com', 'Activo', '2026-08-07 09:15:00'),
('Pedro Antonio', 'Velasquez Cruz', '0007-0007', 'pedro.velasquez@gmail.com', 'Activo', '2026-08-07 09:30:00'),
('Andrea Nicole', 'Santos Molina', '0008-0008', 'andrea.santos@gmail.com', 'Activo', '2026-08-07 09:45:00'),
('Miguel Angel', 'Chavez Ortiz', '0009-0009', 'miguel.chavez@gmail.com', 'Inactivo', '2026-08-07 10:00:00'),
('Karla Patricia', 'Flores Herrera', '0010-0010', 'karla.flores@gmail.com', 'Activo', '2026-08-07 10:15:00');

-- VEHICULOS (10 registros)
INSERT INTO vehiculos (cliente_id, tipo, marca, modelo, placa, anio) VALUES
(1, 'Carro Deportivo', 'Ford', 'Mustang GT', 'P-123ABC', 2021),
(2, 'Carro', 'Toyota', 'Corolla SE', 'P-234BCD', 2020),
(3, 'Carro', 'Toyota', 'Hilux SRV', 'P-345CDE', 2022),
(4, 'Moto', 'Honda', 'CBR 600RR', 'M-456DEF', 2022),
(5, 'Moto', 'Bajaj', 'Pulsar NS200', 'M-567EFG', 2023),
(6, 'Carro', 'Hyundai', 'Tucson GLS', 'P-678FGH', 2021),
(7, 'Moto', 'Kawasaki', 'Ninja 400', 'M-789GHI', 2020),
(8, 'Carro', 'Nissan', 'Sentra Advance', 'P-890HIJ', 2022),
(9, 'Moto', 'Yamaha', 'MT-07', 'M-901IJK', 2024),
(10, 'Carro Lujo', 'Audi', 'A4 Premium', 'P-012JKL', 2023);

-- MECANICOS (10 registros)
INSERT INTO mecanicos (nombres, apellidos, activo, especialidad) VALUES
('Joseph Alexis', 'Fernandez Estrada', TRUE, 'Mecanica de motos e hiperdeportivos'),
('Carlos Enrique', 'Ramirez Lopez', TRUE, 'Mecanica general'),
('Luis Fernando', 'Morales Garcia', TRUE, 'Sistema de frenos y suspension'),
('Miguel Angel', 'Santos Perez', TRUE, 'Electricidad automotriz'),
('Kevin Alejandro', 'Gomez Castillo', TRUE, 'Diagnostico computarizado'),
('Oscar Daniel', 'Hernandez Ruiz', TRUE, 'Motores gasolina y diesel'),
('Jorge Alberto', 'Mendez Flores', FALSE, 'Enderezado y pintura'),
('Victor Manuel', 'Cruz Diaz', TRUE, 'Transmisiones manuales y automaticas'),
('Andres Felipe', 'Lopez Herrera', TRUE, 'Mecanica de motocicletas'),
('Diego Estuardo', 'Velasquez Ortiz', TRUE, 'Alineacion y balanceo');

-- SERVICIOS (10 registros)
INSERT INTO servicios (nombre, categoria, precio_base, duracion_min, estado) VALUES
('Cambio de aceite', 'Mantenimiento', 250.00, 30, 'Disponible'),
('Servicio de frenos', 'Frenos', 450.00, 60, 'Disponible'),
('Alineacion y balanceo', 'Llantas', 180.00, 45, 'Disponible'),
('Cambio de llantas', 'Llantas', 150.00, 40, 'Disponible'),
('Diagnostico computarizado', 'Electronica', 300.00, 40, 'Disponible'),
('Afinacion de motor', 'Motor', 700.00, 120, 'Disponible'),
('Cambio de bateria', 'Electricidad', 850.00, 20, 'Disponible'),
('Revision de suspension', 'Suspension', 500.00, 90, 'Disponible'),
('Lavado completo', 'Estetica', 120.00, 60, 'Disponible'),
('Servicio mayor', 'Mantenimiento', 1200.00, 240, 'Disponible');

-- CITAS_SERVICIO (10 registros con estados estandarizados)
INSERT INTO citas_servicio (vehiculo_id, servicio_id, mecanico_id, fecha_programada, estado, precio_final, notas) VALUES
(1, 1, 1, '2026-08-07 15:30:00', 'pendiente', 250.00, 'Ajuste de valvulas y revision previa a carrera'),
(2, 2, 2, '2026-08-08 09:00:00', 'completada', 450.00, 'Cambio de aceite y filtro completado'),
(3, 3, 3, '2026-08-09 10:00:00', 'en_proceso', 180.00, 'Revision completa del sistema de frenos'),
(4, 4, 4, '2026-08-10 11:30:00', 'pendiente', 150.00, 'Cambio de bateria programado'),
(5, 5, 5, '2026-08-11 14:00:00', 'completada', 300.00, 'Balanceo de llantas delanteras'),
(6, 6, 6, '2026-08-12 16:00:00', 'en_proceso', 700.00, 'Diagnostico por falla electrica en pista'),
(7, 7, 1, '2026-08-13 08:30:00', 'pendiente', 850.00, 'Cambio de cadena de distribucion'),
(8, 8, 3, '2026-08-14 10:30:00', 'cancelada', 500.00, 'Cliente cancelo por viaje'),
(9, 9, 9, '2026-08-15 13:00:00', 'completada', 120.00, 'Afinacion completa de motor'),
(10, 10, 8, '2026-08-16 15:00:00', 'en_proceso', 1200.00, 'Servicio mayor de transmision');