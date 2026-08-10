# Garage Elite Campus

Sistema de gestión de servicios y citas para un taller automotriz especializado, desarrollado sobre MySQL.

El proyecto tiene como objetivo aplicar principios de modelado relacional, integridad de datos, consultas SQL, procedimientos almacenados y validaciones de reglas de negocio sobre un escenario práctico de gestión de un taller.

---

## 1. Descripción del proyecto

`garage_elite_campus` permite administrar la información principal de un taller:

* Clientes.
* Vehículos.
* Mecánicos.
* Servicios.
* Citas de servicio.

La estructura fue diseñada para mantener relaciones claras entre las entidades y evitar registros inconsistentes mediante claves primarias, claves foráneas, restricciones y procedimientos almacenados.

La gestión de citas constituye la parte principal del proyecto, ya que concentra las operaciones de creación, consulta, actualización, cancelación y eliminación controlada.

---

## 2. Objetivos

El proyecto busca demostrar el uso práctico de:

* Diseño de bases de datos relacionales.
* Claves primarias y foráneas.
* Relaciones `1:N`.
* Restricciones `NOT NULL`, `UNIQUE` y `CHECK`.
* `JOIN` entre múltiples tablas.
* Funciones de agregación.
* `GROUP BY`, `HAVING` y `ORDER BY`.
* Procedimientos almacenados.
* Parámetros `IN` y `OUT`.
* Control de transacciones.
* Validación de reglas de negocio.
* Manejo de errores mediante `SIGNAL SQLSTATE`.
* Eliminación lógica y eliminación física controlada.

---

## 3. Estructura del proyecto

Una organización recomendada para los archivos es:

```text
garage-elite-campus/
│
├── ddl/
│   └── schema.sql
│
├── dml/
│   └── inserts.sql
│
├── procedures/
│   └── crud_citas.sql
│
├── dql/
│   └── consultas.sql
│
├── evidencias/
│   └── resultado.md
│
├── requerimientos.md
└── README.md
```

### Descripción de los archivos

| Archivo                     | Función                                                                          |
| --------------------------- | -------------------------------------------------------------------------------- |
| `ddl/schema.sql`            | Crea la base de datos, tablas, relaciones y restricciones.                       |
| `dml/inserts.sql`           | Inserta los datos iniciales para realizar pruebas.                               |
| `procedures/crud_citas.sql` | Crea los procedimientos almacenados para gestionar citas y contiene sus pruebas. |
| `dql/consultas.sql`         | Contiene consultas para obtener información y estadísticas del sistema.          |
| `evidencias/resultado.md`   | Documenta las pruebas realizadas y los resultados esperados.                     |
| `requerimientos.md`         | Describe las entidades, relaciones y reglas implementadas.                       |

---

## 4. Modelo de datos

El sistema está compuesto por cinco entidades principales:

```text
clientes
    │
    │ 1:N
    ▼
vehiculos
    │
    │ 1:N
    ▼
citas_servicio
    ▲        ▲        ▲
    │        │        │
   N:1      N:1      N:1
    │        │        │
mecanicos servicios
```

### Relaciones principales

* Un cliente puede tener varios vehículos.
* Un vehículo puede tener varias citas.
* Un mecánico puede atender varias citas.
* Un servicio puede aparecer en varias citas.

Las relaciones se implementan mediante claves foráneas y utilizan `ON DELETE RESTRICT` y `ON UPDATE CASCADE` donde corresponde.

---

## 5. ¿Por qué se diseñó de esta forma?

El modelo separa la información en entidades independientes para evitar duplicación de datos y facilitar su mantenimiento.

Por ejemplo, los datos del cliente no se almacenan directamente en cada cita. La cita solamente referencia al vehículo, y el vehículo referencia a su propietario.

De esta forma:

```text
Cliente
   ↓
Vehículo
   ↓
Cita
   ├── Servicio
   └── Mecánico
```

Esto permite consultar la información relacionada mediante `JOIN` sin repetir los datos principales en diferentes registros.

La tabla `citas_servicio` funciona como el punto de relación entre el vehículo, el servicio y el mecánico.

---

## 6. Reglas principales del sistema

El diseño incorpora restricciones a nivel de base de datos y validaciones adicionales mediante procedimientos.

Entre las principales reglas se encuentran:

* Los correos de los clientes no pueden repetirse.
* Las placas de los vehículos son únicas.
* Un vehículo debe pertenecer a un cliente existente.
* Un servicio suspendido no puede utilizarse para crear una nueva cita.
* Un mecánico inactivo no puede ser asignado a una nueva cita.
* El precio final no puede ser negativo.
* Una cita debe tener una fecha programada.
* Una cita solamente puede utilizar los estados definidos.
* Una cita cancelada no puede modificarse.
* Una cita completada no puede cancelarse.
* Una cita solamente puede eliminarse físicamente cuando está pendiente.

---

## 7. Procedimientos almacenados

La gestión de citas se centraliza mediante cinco procedimientos.

### Crear cita

```sql
CALL sp_crear_cita_servicio(
    1,
    2,
    1,
    '2026-08-17 09:00:00',
    450.00,
    'Revision del sistema de frenos',
    @nueva_cita
);
```

El procedimiento valida los datos necesarios antes de insertar la cita.

Si todas las condiciones son correctas, la cita se crea con estado:

```text
pendiente
```

Además, mediante el parámetro `OUT`, devuelve el identificador generado.

---

### Consultar citas

```sql
CALL sp_listar_citas_servicio('pendiente');
```

Permite consultar las citas según su estado.

También puede utilizarse:

```sql
CALL sp_listar_citas_servicio(NULL);
```

para obtener todas las citas.

Los resultados se ordenan por fecha programada.

---

### Actualizar cita

```sql
CALL sp_actualizar_cita_servicio(
    @nueva_cita,
    2,
    '2026-08-17 10:00:00',
    'en_proceso',
    500.00,
    'Cliente autorizo ajuste de ultima hora'
);
```

Permite actualizar información de una cita existente.

Antes de realizar la modificación se verifica que:

* La cita exista.
* No esté cancelada.
* El estado sea válido.
* El precio sea válido.
* El mecánico exista y esté activo.
* La fecha esté definida.

---

### Cancelar cita

```sql
CALL sp_cancelar_cita_servicio(
    @nueva_cita,
    'Cliente reprogramara para el proximo mes'
);
```

La cancelación utiliza una eliminación lógica.

En lugar de eliminar el registro, se modifica:

```text
estado = 'cancelada'
```

y se conserva el motivo en las notas.

Esto permite mantener el historial de la cita.

---

### Eliminar cita pendiente

```sql
CALL sp_eliminar_cita_borrador(@cita_borrador);
```

La eliminación física está restringida a citas pendientes.

Una cita que ya está:

* `en_proceso`
* `completada`
* `cancelada`

no puede eliminarse mediante este procedimiento.

Esto evita borrar información que ya forma parte del historial operativo del taller.

---

## 8. Consultas SQL

El proyecto incluye cinco consultas de análisis.

### Citas pendientes

Obtiene las citas pendientes y las ordena desde la fecha más próxima.

### Resumen por estado

Calcula:

* Cantidad de citas.
* Monto total estimado.
* Precio promedio.

Los resultados se agrupan por estado.

### Ranking de mecánicos

Muestra la cantidad de citas atendidas por cada mecánico considerando los estados:

```text
en_proceso
completada
```

Se utiliza `LEFT JOIN` para conservar también mecánicos que todavía no tienen citas atendidas.

### Vehículos con múltiples citas

Identifica vehículos que tienen más de una cita registrada utilizando:

```sql
GROUP BY
HAVING COUNT(c.id) > 1
```

### Servicios más solicitados

Muestra los servicios según la cantidad de solicitudes y calcula el precio final promedio.

---

## 9. Manejo de errores

Los procedimientos utilizan `SIGNAL SQLSTATE '45000'` para controlar errores de negocio.

Por ejemplo, si se intenta registrar un precio negativo:

```sql
CALL sp_crear_cita_servicio(
    1,
    1,
    1,
    '2026-08-18 10:00:00',
    -100.00,
    'Prueba precio negativo',
    @cita_error
);
```

El procedimiento detiene la operación y devuelve:

```text
Error: El precio final no puede ser negativo ni nulo.
```

La misma estrategia se utiliza para validar mecánicos inactivos, servicios no disponibles, citas inexistentes y transiciones de estado no permitidas.

---

## 10. Transacciones

Las operaciones que modifican las citas utilizan:

```sql
START TRANSACTION;
```

seguido de la operación correspondiente y:

```sql
COMMIT;
```

Esto permite tratar la modificación como una operación controlada y facilita mantener la consistencia de los datos.

---

## 11. Instalación y ejecución

La ejecución debe realizarse siguiendo el orden de dependencias:

### 1. Crear la estructura

Ejecutar:

```text
ddl/schema.sql
```

Este archivo crea la base de datos y todas las tablas.

### 2. Insertar datos

Ejecutar:

```text
dml/inserts.sql
```

Esto proporciona registros iniciales para realizar consultas y pruebas.

### 3. Crear los procedimientos

Ejecutar:

```text
procedures/crud_citas.sql
```

Este archivo crea los procedimientos almacenados y contiene las pruebas mediante `CALL`.

### 4. Ejecutar las consultas

Finalmente:

```text
dql/consultas.sql
```

permite consultar y analizar los datos almacenados.

La base de datos utilizada es:

```sql
USE garage_elite_campus;
```

---

## 12. Evidencias

Las pruebas de funcionamiento se encuentran documentadas en:

```text
evidencias/resultado.md
```

Se incluyen pruebas de:

* Creación de citas.
* Consulta por estado.
* Actualización.
* Cancelación lógica.
* Eliminación física controlada.
* Precio negativo.
* Mecánico inactivo.
* Modificación de citas canceladas.
* Cancelación de citas completadas.
* Eliminación de citas que no están pendientes.

Las pruebas permiten comprobar tanto el funcionamiento esperado como el rechazo de operaciones que incumplen las reglas establecidas.

---

## 13. Consideraciones de diseño

El proyecto prioriza la integridad y consistencia de los datos.

Las restricciones de las tablas proporcionan una primera capa de protección, mientras que los procedimientos almacenados agregan validaciones relacionadas directamente con las reglas de negocio.

La combinación de ambas capas permite que las operaciones sobre las citas no dependan únicamente de las validaciones realizadas desde una aplicación externa.

El uso de cancelación lógica permite conservar el historial, mientras que la eliminación física se limita a registros que todavía se encuentran en estado `pendiente`.

---

## 14. Tecnologías

* MySQL
* SQL
* Procedimientos almacenados
* Transacciones
* Integridad referencial

---

## 15. Estado del proyecto

El proyecto cuenta con:

* Modelo relacional implementado.
* Datos de prueba.
* Consultas SQL de análisis.
* Procedimientos almacenados para la gestión de citas.
* Validaciones de reglas de negocio.
* Manejo de errores controlados.
* Pruebas de funcionamiento y errores documentadas.
