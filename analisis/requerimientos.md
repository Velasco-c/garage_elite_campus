# Requerimientos y análisis de entidades

## 1. Descripción general

El sistema `garage_elite_campus` representa la gestión de un taller automotriz especializado. La base de datos permite administrar clientes, vehículos, mecánicos, servicios y citas de servicio.

El diseño utiliza relaciones mediante claves foráneas para mantener la integridad de los datos y restricciones `CHECK` para controlar valores permitidos.

---

## 2. Entidades del sistema

### Tabla: `clientes`

Almacena la información de los clientes registrados en el taller.

| Campo       | Tipo de dato | Restricciones      | Descripción                                |
| ----------- | ------------ | ------------------ | ------------------------------------------ |
| `id`        | INT          | PK, AUTO_INCREMENT | Identificador único del cliente.           |
| `nombres`   | VARCHAR(120) | NOT NULL           | Nombres del cliente.                       |
| `apellidos` | VARCHAR(120) | NOT NULL           | Apellidos del cliente.                     |
| `telefono`  | VARCHAR(20)  | NOT NULL           | Número telefónico del cliente.             |
| `email`     | VARCHAR(120) | NOT NULL, UNIQUE   | Correo electrónico del cliente.            |
| `estado`    | VARCHAR(25)  | NOT NULL, CHECK    | Estado del cliente: `Activo` o `Inactivo`. |
| `creado_en` | DATETIME     | NOT NULL, DEFAULT  | Fecha y hora de registro.                  |

### Tabla: `vehiculos`

Registra los vehículos pertenecientes a los clientes.

| Campo        | Tipo de dato | Restricciones      | Descripción                       |
| ------------ | ------------ | ------------------ | --------------------------------- |
| `id`         | INT          | PK, AUTO_INCREMENT | Identificador único del vehículo. |
| `cliente_id` | INT          | FK, NOT NULL       | Cliente propietario del vehículo. |
| `tipo`       | VARCHAR(50)  | NOT NULL           | Tipo de vehículo.                 |
| `marca`      | VARCHAR(80)  | NOT NULL           | Marca del vehículo.               |
| `modelo`     | VARCHAR(80)  | NOT NULL           | Modelo del vehículo.              |
| `placa`      | VARCHAR(20)  | NOT NULL, UNIQUE   | Placa o matrícula del vehículo.   |
| `anio`       | INT          | NOT NULL           | Año del vehículo.                 |

### Tabla: `mecanicos`

Contiene los mecánicos disponibles para atender los servicios.

| Campo          | Tipo de dato | Restricciones          | Descripción                                       |
| -------------- | ------------ | ---------------------- | ------------------------------------------------- |
| `id`           | INT          | PK, AUTO_INCREMENT     | Identificador único del mecánico.                 |
| `nombres`      | VARCHAR(120) | NOT NULL               | Nombres del mecánico.                             |
| `apellidos`    | VARCHAR(120) | NOT NULL               | Apellidos del mecánico.                           |
| `especialidad` | VARCHAR(120) | NOT NULL               | Área de especialización.                          |
| `activo`       | BOOLEAN      | NOT NULL, DEFAULT TRUE | Indica si el mecánico puede recibir nuevas citas. |

### Tabla: `servicios`

Define los servicios que ofrece el taller.

| Campo          | Tipo de dato  | Restricciones      | Descripción                          |
| -------------- | ------------- | ------------------ | ------------------------------------ |
| `id`           | INT           | PK, AUTO_INCREMENT | Identificador único del servicio.    |
| `nombre`       | VARCHAR(120)  | NOT NULL           | Nombre del servicio.                 |
| `categoria`    | VARCHAR(100)  | NOT NULL           | Categoría del servicio.              |
| `precio_base`  | DECIMAL(10,2) | NOT NULL, CHECK    | Precio base del servicio.            |
| `duracion_min` | INT           | NOT NULL, CHECK    | Duración estimada en minutos.        |
| `estado`       | VARCHAR(25)   | NOT NULL, CHECK    | Estado: `Disponible` o `Suspendido`. |

### Tabla: `citas_servicio`

Representa las citas programadas para realizar un servicio sobre un vehículo.

| Campo              | Tipo de dato  | Restricciones      | Descripción                             |
| ------------------ | ------------- | ------------------ | --------------------------------------- |
| `id`               | INT           | PK, AUTO_INCREMENT | Identificador único de la cita.         |
| `vehiculo_id`      | INT           | FK, NOT NULL       | Vehículo asociado a la cita.            |
| `servicio_id`      | INT           | FK, NOT NULL       | Servicio solicitado.                    |
| `mecanico_id`      | INT           | FK, NOT NULL       | Mecánico asignado.                      |
| `fecha_programada` | DATETIME      | NOT NULL           | Fecha y hora programada.                |
| `estado`           | VARCHAR(20)   | NOT NULL, CHECK    | Estado de la cita.                      |
| `precio_final`     | DECIMAL(10,2) | NOT NULL, CHECK    | Precio final de la cita.                |
| `notas`            | VARCHAR(255)  | NULL               | Observaciones relacionadas con la cita. |
| `creado_en`        | DATETIME      | NOT NULL, DEFAULT  | Fecha y hora de creación.               |

Los estados permitidos para una cita son:

* `pendiente`
* `en_proceso`
* `completada`
* `cancelada`

---

## 3. Relaciones

| Tabla padre | Tabla hija       | Cardinalidad | Clave foránea                |
| ----------- | ---------------- | ------------ | ---------------------------- |
| `clientes`  | `vehiculos`      | 1 : N        | `vehiculos.cliente_id`       |
| `vehiculos` | `citas_servicio` | 1 : N        | `citas_servicio.vehiculo_id` |
| `mecanicos` | `citas_servicio` | 1 : N        | `citas_servicio.mecanico_id` |
| `servicios` | `citas_servicio` | 1 : N        | `citas_servicio.servicio_id` |

Un cliente puede tener varios vehículos.

Un vehículo puede registrar varias citas a lo largo del tiempo.

Un mecánico puede atender múltiples citas.

Un servicio puede ser solicitado en múltiples citas.

---

## 4. Reglas de integridad

La base de datos incorpora las siguientes reglas:

### Clientes

* El correo electrónico debe ser único.
* El cliente debe tener un estado válido:

  * `Activo`
  * `Inactivo`

### Vehículos

* Cada vehículo debe pertenecer a un cliente existente.
* La placa debe ser única.
* No se puede eliminar un cliente que tenga vehículos relacionados debido a `ON DELETE RESTRICT`.

### Mecánicos

* Un mecánico puede estar activo o inactivo.
* Los procedimientos de citas solamente permiten asignar mecánicos activos.

### Servicios

* El precio base no puede ser negativo.
* La duración debe ser mayor que cero.
* El servicio solamente puede encontrarse en uno de estos estados:

  * `Disponible`
  * `Suspendido`

### Citas

* El vehículo debe existir.
* El servicio debe existir y encontrarse disponible.
* El mecánico debe existir y encontrarse activo.
* La fecha programada es obligatoria.
* El precio final no puede ser negativo.
* El estado de la cita debe pertenecer al conjunto permitido.

---

## 5. Operaciones de citas

La gestión de citas se implementa mediante procedimientos almacenados.

### Crear cita

`sp_crear_cita_servicio`

Permite registrar una nueva cita después de validar:

* Existencia del vehículo.
* Existencia y disponibilidad del servicio.
* Existencia y estado del mecánico.
* Fecha programada.
* Precio final.

La nueva cita se registra inicialmente como `pendiente`.

### Consultar citas

`sp_listar_citas_servicio`

Permite consultar las citas filtrando opcionalmente por estado.

```sql
CALL sp_listar_citas_servicio('pendiente');
```

Para consultar todas:

```sql
CALL sp_listar_citas_servicio(NULL);
```

### Actualizar cita

`sp_actualizar_cita_servicio`

Permite modificar:

* Mecánico.
* Fecha programada.
* Estado.
* Precio final.
* Notas.

No permite modificar una cita que ya fue cancelada.

### Cancelar cita

`sp_cancelar_cita_servicio`

Realiza una eliminación lógica.

La cita permanece almacenada y cambia a estado `cancelada`, conservando el motivo de cancelación dentro de las notas.

### Eliminar cita pendiente

`sp_eliminar_cita_borrador`

Realiza una eliminación física controlada.

Solamente permite eliminar citas cuyo estado sea `pendiente`.

---

## 6. Consultas de análisis

El proyecto incorpora consultas orientadas al análisis de la información:

1. Citas pendientes ordenadas por fecha programada.
2. Total de citas y montos acumulados por estado.
3. Ranking de mecánicos según citas atendidas.
4. Vehículos con más de una cita registrada.
5. Servicios más solicitados y promedio del precio final.

Estas consultas utilizan `JOIN`, funciones de agregación, `GROUP BY`, `HAVING` y `ORDER BY`.

---

## 7. Manejo de errores

Los procedimientos almacenados utilizan:

```sql
SIGNAL SQLSTATE '45000'
```

para detener operaciones que incumplan las reglas de negocio.

Entre las validaciones implementadas se encuentran:

* Datos obligatorios ausentes.
* Precios negativos.
* Vehículos inexistentes.
* Servicios inexistentes.
* Servicios suspendidos.
* Mecánicos inexistentes.
* Mecánicos inactivos.
* Citas inexistentes.
* Estados inválidos.
* Modificación de citas canceladas.
* Cancelación de citas completadas.
* Eliminación física de citas que no están pendientes.
