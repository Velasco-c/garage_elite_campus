DROP DATABASE IF EXISTS garage_elite_campus;
CREATE DATABASE garage_elite_campus;
USE garage_elite_campus;
DROP TABLE IF EXISTS citas_servicios;
DROP TABLE IF EXISTS detalles_reservacion;
DROP TABLE IF EXISTS vehiculos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS mecanicos;
DROP TABLE IF EXISTS servicios;

CREATE TABLE clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombres VARCHAR(120) NOT NULL UNIQUE,
  apellidos VARCHAR(120) NOT NULL UNIQUE,
  telefono VARCHAR(10) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  estado VARCHAR(25),
  fecha_creacion DATE NOT NULL,
  cantidad_vehiculos INT NOT NULL CHECK(cantidad_vehiculos > 0 )
)ENGINE=InnoDB;

CREATE TABLE vehiculos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombres VARCHAR(120) NOT NULL,
  tipo VARCHAR(25) PRIMARY KEY,
  marca VARCHAR(80) NOT NULL,
  modelo VARCHAR(20) NOT NULL,
  placa VARCHAR(100) NOT NULL UNIQUE,
  anio DATE,
  cliente_id INT NOT NULL,
  FOREIGN KEY (cliente_id) REFERENCES clientes(id)
)ENGINE=InnoDB;

CREATE TABLE mecanicos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombres VARCHAR(120) NOT NULL UNIQUE,
  apellidos VARCHAR(120) NOT NULL UNIQUE,
  activo BOOLEAN DEFAULT TRUE,
  especialidad VARCHAR(120) NOT NULL UNIQUE
)ENGINE=InnoDB;

CREATE TABLE servicios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombres VARCHAR(120) NOT NULL,
  categoria VARCHAR(120) NOT NULL,
  precio DECIMAL(10.2) NOT NULL CHECK(precio > 1),
  duracion VARCHAR(120) NOT NULL,
  estado VARCHAR(25) NOT NULL,
  disponible BOOLEAN DEFAULT TRUE
)ENGINE=InnoDB;

CREATE TABLE detalle_reservacion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  descripcion VARCHAR(180) NOT NULL,
  estado VARCHAR(50) NOT NULL,
  vehiculo_id INT NOT NULL,
  FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id)
)ENGINE=InnoDB;

CREATE TABLE citas_servicios(
  id INT AUTO_INCREMENT PRIMARY KEY,
  fk_id_vehiculo INT NOT NULL,
  fk_id_mecanico INT NOT NULL,
  fk_id_servicio INT NOT NULL,
  fk_id_detalles_reservacion INT NOT NULL,
  fecha_programada DATE,
  precio_final DECIMAL(10.2),
  FOREIGN KEY (fk_id_vehiculo) REFERENCES vehiculos(id),
  FOREIGN KEY (fk_id_mecanico) REFERENCES mecanicos(id),
  FOREIGN KEY (fk_id_servicio) REFERENCES servicios(id),
  FOREIGN KEY (fk_id_detalles_reservacion) REFERENCES detalle_reservacion(id)
)ENGINE=InnoDB;