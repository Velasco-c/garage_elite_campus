  -- CLIENTES
  INSERT INTO clientes (nombres,apellidos,telefono,email,
  estado,fecha_creacion,cantidad_vehiculos) VALUES
  ('Jose Luis','Hernandez Hernandez','0001-0001','joseluis@gmail.com','Activo','2026-08-07',1),
  ('Maria Fernanda','Lopez Garcia','0002-0002','maria.lopez@gmail.com','Activo','2026-08-07',2),
  ('Carlos Alberto','Ramirez Perez','0003-0003','carlos.ramirez@gmail.com','Activo','2026-08-07',1),
  ('Ana Sofia','Morales Diaz','0004-0004','ana.morales@gmail.com','Activo','2026-08-07',3),
  ('Luis Enrique','Castillo Gomez','0005-0005','luis.castillo@gmail.com','Inactivo','2026-08-07',1),
  ('Daniela','Mendez Ruiz','0006-0006','daniela.mendez@gmail.com','Activo','2026-08-07',2),
  ('Pedro Antonio','Velasquez Cruz','0007-0007','pedro.velasquez@gmail.com','Activo','2026-08-07',1),
  ('Andrea Nicole','Santos Molina','0008-0008','andrea.santos@gmail.com','Activo','2026-08-07',2),
  ('Miguel Angel','Chavez Ortiz','0009-0009','miguel.chavez@gmail.com','Inactivo','2026-08-07',1),
  ('Karla Patricia','Flores Herrera','0010-0010','karla.flores@gmail.com','Activo','2026-08-07',1);

  -- VEHICULOS
  INSERT INTO vehiculos (nombres, tipo, marca,modelo,placa,anio,cliente_id) VALUES
  ('Mustang GT','Carro Deportivo','Ford','GT Premium','P-123ABC','2021-02-15',1),
  ('Corolla','Carro','Toyota','SE','P-234BCD','2020-05-18',2),
  ('Hilux','Carro','Toyota','SRV','P-345CDE','2022-08-10',3),
  ('CBR 600RR','Moto','Honda','CBR 600RR','M-456DEF','2022-03-10',4),
  ('Pulsar NS200','Moto','Bajaj','NS200','M-567EFG','2023-01-12',5),
  ('Tucson','Carro','Hyundai','GLS','P-678FGH','2021-07-30',6),
  ('Ninja 400','Moto','Kawasaki','Ninja 400','M-789GHI','2020-03-14',7),
  ('Sentra','Carro','Nissan','Advance','P-890HIJ','2022-09-05',8),
  ('MT-07','Moto','Yamaha','MT-07','M-901IJK','2024-04-20',9),
  ('A4','Carro','Audi','Premium','P-012JKL','2023-06-08',10);

  -- MECANISMO
  INSERT INTO mecanicos (nombres, apellidos,activo,especialidad) 
  VALUES
  ('Joseph Alexis','Fernandez Estrada',TRUE,'Mecanico de motos y servicios de llantas'),
  ('Carlos Enrique','Ramirez Lopez',TRUE,'Mecanica general'),
  ('Luis Fernando','Morales Garcia',TRUE,'Sistema de frenos y suspension'),
  ('Miguel Angel','Santos Perez',TRUE,'Electricidad automotriz'),
  ('Kevin Alejandro','Gomez Castillo',TRUE,'Diagnostico computarizado'),
  ('Oscar Daniel','Hernandez Ruiz',TRUE,'Motores gasolina y diesel'),
  ('Jorge Alberto','Mendez Flores',TRUE,'Enderezado y pintura'),
  ('Victor Manuel','Cruz Diaz',TRUE,'Transmisiones manuales y automaticas'),
  ('Andres Felipe','Lopez Herrera',TRUE,'Mecanico de motocicletas'),
  ('Diego Estuardo','Velasquez Ortiz',TRUE,'Alineacion, balanceo y cambio de llantas');

-- SERVICIOS
INSERT INTO servicios (nombres,categoria,precio,duracion,estado) 
VALUES
('Cambio de aceite','Mantenimiento',250.00,'30 minutos','Disponible'),
('Servicio de frenos','Frenos',450.00,'1 hora','Disponible'),
('Alineacion y balanceo','Llantas',180.00,'45 minutos','Disponible'),
('Cambio de llantas','Llantas',150.00,'40 minutos','Disponible'),
('Diagnostico computarizado','Electronica',300.00,'40 minutos','Disponible'),
('Afinacion de motor','Motor',700.00,'2 horas','Disponible'),
('Cambio de bateria','Electricidad',850.00,'20 minutos','Disponible'),
('Revision de suspension','Suspension',500.00,'1 hora 30 minutos','Disponible'),
('Lavado completo','Estetica',120.00,'1 hora','Disponible'),
('Servicio mayor','Mantenimiento',1200.00,'4 horas','Disponible');


-- DETALLE_RESERVACION
INSERT INTO detalles_reservacion (descripcion,estado,vehiculo_id) VALUES
('Se realizo ajuste de valvulas.','Pendiente',1),
('Cambio de aceite y filtro.','Finalizado',2),
('Revision completa del sistema de frenos.','En proceso',3),
('Cambio de bateria.','Pendiente',4),
('Balanceo de llantas delanteras.','Finalizado',5),
('Diagnostico por falla electrica.','En proceso',6),
('Cambio de cadena de distribucion.','Pendiente',7),
('Revision de suspension delantera.','Pendiente',8),
('Afinacion completa del motor.','Finalizado',9),
('Cambio de llantas traseras.','En proceso',10);

-- CITAS_SERVICIOS
INSERT INTO citas_servicios (fk_id_vehiculo,fk_id_mecanico,fk_id_servicio,
    fk_id_detalles_reservacion,fecha_programada,precio_final) VALUES
(1,1,1,1,'2026-08-07',250.00),
(2,2,2,2,'2026-08-08',450.00),
(3,3,3,3,'2026-08-09',180.00),
(4,4,4,4,'2026-08-10',150.00),
(5,5,5,5,'2026-08-11',300.00),
(6,6,6,6,'2026-08-12',700.00),
(7,7,7,7,'2026-08-13',850.00),
(8,8,8,8,'2026-08-14',500.00),
(9,9,9,9,'2026-08-15',120.00),
(10,10,10,10,'2026-08-16',1200.00);