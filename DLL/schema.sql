DROP DATABASE IF EXISTS campuslands_mysql;
CREATE DATABASE campuslands_mysql;
USE campuslands_mysql;

DROP TABLE IF EXISTS citas_servicio;
DROP TABLE IF EXISTS vehiculos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS mecanicos;
DROP TABLE IF EXISTS servicios;

-- 1. TABLA CLIENTES
CREATE TABLE clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombres VARCHAR(120) NOT NULL,
  apellidos VARCHAR(120) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  estado VARCHAR(25) NOT NULL DEFAULT 'Activo' CHECK(estado IN ('Activo', 'Inactivo')),
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. TABLA VEHICULOS
CREATE TABLE vehiculos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT NOT NULL,
  tipo VARCHAR(50) NOT NULL, -- Moto, Carro deportivo, Hiperdeportivo, etc.
  marca VARCHAR(80) NOT NULL,
  modelo VARCHAR(80) NOT NULL,
  placa VARCHAR(20) NOT NULL UNIQUE,
  anio INT NOT NULL,
  FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. TABLA MECANICOS
CREATE TABLE mecanicos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombres VARCHAR(120) NOT NULL,
  apellidos VARCHAR(120) NOT NULL,
  especialidad VARCHAR(120) NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- 4. TABLA SERVICIOS
CREATE TABLE servicios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  categoria VARCHAR(100) NOT NULL,
  precio_base DECIMAL(10,2) NOT NULL CHECK(precio_base >= 0),
  duracion_min INT NOT NULL CHECK(duracion_min > 0),
  estado VARCHAR(25) NOT NULL DEFAULT 'Disponible' CHECK(estado IN ('Disponible', 'Suspendido'))
) ENGINE=InnoDB;

-- 5. TABLA CITAS_SERVICIO
CREATE TABLE citas_servicio (
  id INT AUTO_INCREMENT PRIMARY KEY,
  vehiculo_id INT NOT NULL,
  servicio_id INT NOT NULL,
  mecanico_id INT NOT NULL,
  fecha_programada DATETIME NOT NULL,
  estado VARCHAR(20) NOT NULL DEFAULT 'pendiente' 
    CHECK(estado IN ('pendiente', 'en_proceso', 'completada', 'cancelada')),
  precio_final DECIMAL(10,2) NOT NULL CHECK(precio_final >= 0),
  notas VARCHAR(255) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (servicio_id) REFERENCES servicios(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (mecanico_id) REFERENCES mecanicos(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;