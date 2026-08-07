# Analisis de entidades

### Tabla: `clientes`

| Campo              | Tipo de dato | Descripción                        |
| ------------------ | ------------ | ---------------------------------- |
| id                 | INT          | Identificador del cliente (PK).    |
| nombres            | VARCHAR(120) | Nombres del cliente.               |
| apellidos          | VARCHAR(120) | Apellidos del cliente.             |
| telefono           | VARCHAR(10)  | Número telefónico.                 |
| email              | VARCHAR(120) | Correo electrónico.                |
| estado             | VARCHAR(25)  | Estado del cliente.                |
| fecha_creacion     | DATE         | Fecha de registro.                 |
| cantidad_vehiculos | INT          | Cantidad de vehículos registrados. |

---

### Tabla: `vehiculos`

| Campo      | Tipo de dato | Descripción                       |
| ---------- | ------------ | --------------------------------- |
| id         | INT          | Identificador del vehículo (PK).  |
| nombre     | VARCHAR(120) | Nombre o referencia del vehículo. |
| tipo       | VARCHAR(25)  | Tipo del vehículo. |
| marca      | VARCHAR(80)  | Marca del vehículo.               |
| modelo     | VARCHAR(20)  | Modelo.                           |
| placa      | VARCHAR(120) | Placa del vehículo.               |
| anio       | DATE         | Año del vehículo.                 |
| cliente_id | INT          | Cliente propietario (FK).         |

---

### Tabla: `mecanicos`

| Campo        | Tipo de dato | Descripción                      |
| ------------ | ------------ | -------------------------------- |
| id           | INT          | Identificador del mecánico (PK). |
| nombres      | VARCHAR(120) | Nombres.                         |
| apellidos    | VARCHAR(120) | Apellidos.                       |
| activo       | BOOLEAN      | Indica si está activo.           |
| especialidad | VARCHAR(120) | Especialidad del mecánico.       |

---

### Tabla: `servicios`

| Campo      | Tipo de dato  | Descripción                      |
| ---------- | ------------- | -------------------------------- |
| id         | INT           | Identificador del servicio (PK). |
| nombre     | VARCHAR(120)  | Nombre del servicio.             |
| categoria  | VARCHAR(120)  | Categoría del servicio.          |
| precios    | DECIMAL(10,2) | Precio base del servicio.        |
| duracion   | VARCHAR(120)  | Duración estimada.               |
| estado     | VARCHAR(25)   | Estado del servicio.             |
| disponible | BOOLEAN       | Disponibilidad del servicio.     |

---

### Tabla: `detalles_reservacion`

| Campo        | Tipo de dato | Descripción                     |
| ------------ | ------------ | ------------------------------- |
| id           | INT          | Identificador del detalle (PK). |
| descripcion  | VARCHAR(180) | Descripción de la reservación.  |
| estado       | VARCHAR(120) | Estado de la reservación.       |
| vehiculos_id | INT          | Vehículo asociado (FK).         |

---

### Tabla: `citas_servicios`

| Campo                   | Tipo de dato  | Descripción                     |
| ----------------------- | ------------- | ------------------------------- |
| id_vehiculo             | INT           | Vehículo (FK).                  |
| id_mecanico             | INT           | Mecánico asignado (FK).         |
| id_servicio             | INT           | Servicio solicitado (FK).       |
| id_detalles_reservacion | INT           | Detalle de la reservación (FK). |
| fecha_programada        | DATE          | Fecha programada.               |
| precio_final            | DECIMAL(10,2) | Precio final del servicio.      |

---

## Relaciones

| Tabla padre          | Tabla hija           | Cardinalidad | Clave foránea           |
| -------------------- | -------------------- | ------------ | ----------------------- |
| clientes             | vehiculos            | 1 : N        | cliente_id              |
| vehiculos            | detalles_reservacion | 1 : N        | vehiculos_id            |
| vehiculos            | citas_servicios      | 1 : N        | id_vehiculo             |
| mecanicos            | citas_servicios      | 1 : N        | id_mecanico             |
| servicios            | citas_servicios      | 1 : N        | id_servicio             |
| detalles_reservacion | citas_servicios      | 1 : 1        | id_detalles_reservacion |
