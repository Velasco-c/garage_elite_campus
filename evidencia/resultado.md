# Evidencias de resultados

## 1. Objetivo

Este documento registra las pruebas realizadas sobre los procedimientos almacenados de la base de datos `garage_elite_campus`.

Las pruebas comprueban las operaciones CRUD de citas y las principales validaciones implementadas en los procedimientos.

## 2. Orden de ejecución

La solución debe ejecutarse en este orden:

1. `ddl/schema.sql`
2. `dml/inserts.sql`
3. `procedures/crud_citas.sql`
4. Pruebas mediante `CALL`
5. `dql/consultas.sql`

Antes de ejecutar los procedimientos:

```sql
USE garage_elite_campus;
```

## 3. Pruebas de funcionamiento

### 3.1 Crear una cita

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

SELECT @nueva_cita AS cita_creada_id;
```

El procedimiento valida que el vehículo exista, que el servicio esté disponible, que el mecánico esté activo, que la fecha sea válida y que el precio no sea negativo.

Si las validaciones son correctas, se crea la cita con estado `pendiente` y se devuelve el ID generado.

### 3.2 Consultar citas

```sql
CALL sp_listar_citas_servicio('pendiente');
```

Permite consultar las citas filtradas por estado y las ordena por fecha programada.

También puede utilizarse:

```sql
CALL sp_listar_citas_servicio(NULL);
```

para consultar todas las citas.

### 3.3 Actualizar una cita

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

El procedimiento valida que la cita exista, que no esté cancelada, que el estado sea válido, que el precio sea correcto y que el mecánico esté activo.

Si las validaciones se cumplen, actualiza la información de la cita.

### 3.4 Cancelar una cita

```sql
CALL sp_cancelar_cita_servicio(
    @nueva_cita,
    'Cliente reprogramara para el proximo mes'
);
```

La cancelación se realiza de forma lógica. La cita no se elimina de la base de datos, sino que cambia su estado a `cancelada` y se conserva el motivo en las notas.

### 3.5 Eliminar una cita pendiente

```sql
CALL sp_eliminar_cita_borrador(@nueva_cita);
```

Este procedimiento realiza una eliminación física, pero únicamente permite eliminar citas que todavía se encuentran en estado `pendiente`.

Las citas que ya fueron procesadas, completadas o canceladas no pueden eliminarse mediante este procedimiento.

## 4. Pruebas de errores controlados

Los procedimientos utilizan `SIGNAL SQLSTATE '45000'` para rechazar operaciones que no cumplen las reglas establecidas.

### 4.1 Precio negativo

```sql
CALL sp_crear_cita_servicio(
    1,
    1,
    1,
    '2026-08-18 10:00:00',
    -100.00,
    'Prueba precio negativo',
    @cita_err
);
```

Resultado esperado:

```text
Error: El precio final no puede ser negativo ni nulo.
```

La cita no debe ser creada.

### 4.2 Mecánico inactivo

El mecánico con ID `7` se encuentra inactivo.

```sql
CALL sp_crear_cita_servicio(
    1,
    1,
    7,
    '2026-08-18 10:00:00',
    250.00,
    'Prueba mecanico inactivo',
    @cita_err
);
```

Resultado esperado:

```text
Error: El mecanico asignado no se encuentra activo.
```

La cita no debe ser creada.

### 4.3 Modificar una cita cancelada

Después de cancelar una cita, se prueba nuevamente su actualización:

```sql
CALL sp_actualizar_cita_servicio(
    @nueva_cita,
    1,
    '2026-08-19 10:00:00',
    'en_proceso',
    500.00,
    'Intento ilegal de edicion'
);
```

Resultado esperado:

```text
Error: No se puede modificar una cita que ya ha sido cancelada.
```

La información de la cita debe permanecer sin cambios.

### 4.4 Cancelar una cita completada

La cita con ID `2` fue creada inicialmente como `completada`.

```sql
CALL sp_cancelar_cita_servicio(
    2,
    'Intento de cancelar cita completada'
);
```

Resultado esperado:

```text
Error: No se puede cancelar una cita que ya fue completada.
```

La cita debe conservar su estado `completada`.

### 4.5 Eliminar físicamente una cita que no está pendiente

```sql
CALL sp_eliminar_cita_borrador(2);
```

Resultado esperado:

```text
Error: Solo se pueden eliminar fisicamente citas en estado pendiente.
```

La cita no debe eliminarse.

## 5. Resultado general

Las pruebas permiten comprobar que los procedimientos almacenados cumplen las operaciones previstas para la gestión de citas.

La creación, consulta y actualización funcionan mediante operaciones controladas. La cancelación utiliza eliminación lógica para conservar el historial, mientras que la eliminación física queda limitada a citas pendientes.

Las validaciones mediante `SIGNAL SQLSTATE '45000'` impiden registrar o modificar información que incumpla las reglas definidas para el sistema.
