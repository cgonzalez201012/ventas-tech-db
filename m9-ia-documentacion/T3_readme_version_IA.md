# RetailPro

> Proyecto integrador del curso de **Data Analytics (Coderhouse)**: análisis de ventas de una distribuidora de tecnología, construido módulo a módulo, desde la base de datos hasta el dashboard.

## Contenido

1. [Descripción del proyecto](#descripción-del-proyecto)
2. [Herramientas utilizadas](#herramientas-utilizadas)
3. [Estructura del repositorio](#estructura-del-repositorio)
4. [Modelo de datos](#modelo-de-datos)
5. [Cómo ejecutar los scripts SQL](#cómo-ejecutar-los-scripts-sql)
6. [Qué responde cada consulta](#qué-responde-cada-consulta)
7. [Notas para continuar el proyecto](#notas-para-continuar-el-proyecto)

---

## Descripción del proyecto

**RetailPro** es un caso de negocio sobre una distribuidora de tecnología (laptops, monitores, periféricos, audio y almacenamiento). El objetivo es responder preguntas comerciales a partir de sus datos de ventas: cuánto se factura por mes, qué productos generan más ingresos, qué clientes son recurrentes y qué clientes o productos no tienen movimiento.

El proyecto se construye con una entrega por módulo del curso, y cada módulo agrega una capa sobre el anterior:

| Módulo | Tema | Dónde está |
|--------|------|------------|
| M3 | Ingeniería de datos: creación y carga de la base `Ventas_Tech_DB` (checkpoint) | `ventas_tech_db.sql` |
| M4 | Consultas SQL de negocio (agregaciones, ranking, `HAVING`, subconsultas) | `m4_ventas_adicionales.sql`, `m4_consultas_negocio.sql` |
| M5 | Consultas con `JOIN` (`INNER`, `LEFT`) y `UNION ALL` | `m5_consultas_joins.sql` |
| M6 | Pipeline ETL en Power BI | `m6-pipeline-etl/` |
| M8 | Modelo de datos y medidas DAX en Power BI | `m8-modelo-dax/` |

Los módulos siguientes, hasta el dashboard final, se irán sumando al repositorio.

> **Importante:** los scripts SQL dependen unos de otros y hay que ejecutarlos en un orden fijo. Ver [Cómo ejecutar los scripts SQL](#cómo-ejecutar-los-scripts-sql).

---

## Herramientas utilizadas

| Herramienta | Uso en el proyecto |
|-------------|--------------------|
| **Microsoft SQL Server (T-SQL)** | Motor de la base de datos `Ventas_Tech_DB` |
| **DBeaver** | Cliente donde se probaron los scripts |
| **SQL Server Management Studio (SSMS)** | Los scripts están diseñados para que también corran en SSMS |
| **Power BI Desktop** | Pipeline ETL (M6) y modelo con medidas DAX (M8), archivos `.pbix` |
| **DAX** | Medidas del modelo en Power BI |
| **Git y GitHub** | Control de versiones y entrega del proyecto |

---

## Estructura del repositorio

```text
.
├── README.md
├── ventas_tech_db.sql
├── m4_ventas_adicionales.sql
├── m4_consultas_negocio.sql
├── m5_consultas_joins.sql
├── m6-pipeline-etl/
└── m8-modelo-dax/
```

| Archivo / carpeta | Qué hace |
|-------------------|----------|
| `README.md` | Este documento. |
| `ventas_tech_db.sql` | **Punto de partida (M3).** Crea la base `Ventas_Tech_DB` si no existe, borra y recrea las 4 tablas, define claves primarias y foráneas, y carga los datos iniciales (4 categorías, 6 clientes, 7 productos y 10 ventas). Termina con consultas de validación. |
| `m4_ventas_adicionales.sql` | Agrega las ventas 11 a 20 (abril a junio de 2024), porque las 10 ventas originales caían todas en marzo y las consultas por mes devolvían una sola fila. Usa clientes y productos ya existentes, por lo que no rompe ninguna clave foránea. Se puede ejecutar más de una vez: si la venta 11 ya existe, no hace nada. |
| `m4_consultas_negocio.sql` | 4 consultas de negocio sobre `ventas`: resumen mensual, ranking de productos, clientes recurrentes y meses por encima o por debajo del promedio. Incluye notas de diseño y hallazgos. |
| `m5_consultas_joins.sql` | 4 consultas con `JOIN`: vista base ventas + clientes + productos + categorías, clientes sin ventas, productos sin ventas y consolidado con `UNION ALL`. |
| `m6-pipeline-etl/` | Trabajo de M6 en Power BI: archivos `.pbix`, capturas de evidencia y un README propio con el detalle. Ver [`m6-pipeline-etl/README.md`](m6-pipeline-etl/README.md). |
| `m8-modelo-dax/` | Trabajo de M8 en Power BI: archivo `.pbix` y un README corto. Ver [`m8-modelo-dax/README.md`](m8-modelo-dax/README.md). |

---

## Modelo de datos

La base `Ventas_Tech_DB` tiene cuatro tablas. Una categoría tiene muchos productos, un cliente tiene muchas ventas y cada venta corresponde a un único producto y a un único cliente.

```mermaid
erDiagram
    categorias ||--o{ productos : "clasifica"
    productos  ||--o{ ventas    : "se vende en"
    clientes   ||--o{ ventas    : "realiza"

    categorias {
        INT id_categoria PK
        VARCHAR nombre_categoria
        VARCHAR descripcion
    }
    clientes {
        INT id_cliente PK
        VARCHAR nombre
        VARCHAR email UK
        VARCHAR ciudad
        DATE fecha_registro
    }
    productos {
        INT id_producto PK
        VARCHAR nombre_producto
        INT id_categoria FK
        DECIMAL precio
        INT stock
        BIT activo
    }
    ventas {
        INT id_venta PK
        INT id_cliente FK
        INT id_producto FK
        INT cantidad
        DECIMAL precio_unitario
        DATE fecha_venta
    }
```

### Detalle de las tablas

**`categorias`**

| Columna | Tipo | Restricciones |
|---------|------|---------------|
| `id_categoria` | `INT` | PK |
| `nombre_categoria` | `VARCHAR(50)` | `NOT NULL` |
| `descripcion` | `VARCHAR(200)` | admite `NULL` |

**`clientes`**

| Columna | Tipo | Restricciones |
|---------|------|---------------|
| `id_cliente` | `INT` | PK |
| `nombre` | `VARCHAR(100)` | `NOT NULL` |
| `email` | `VARCHAR(100)` | `UNIQUE`, admite `NULL` |
| `ciudad` | `VARCHAR(50)` | admite `NULL` |
| `fecha_registro` | `DATE` | `NOT NULL` |

**`productos`**

| Columna | Tipo | Restricciones |
|---------|------|---------------|
| `id_producto` | `INT` | PK |
| `nombre_producto` | `VARCHAR(100)` | `NOT NULL` |
| `id_categoria` | `INT` | FK → `categorias.id_categoria` |
| `precio` | `DECIMAL(10,2)` | `NOT NULL` |
| `stock` | `INT` | `NOT NULL`, por defecto `0` |
| `activo` | `BIT` | `NOT NULL`, por defecto `1` |

**`ventas`**

| Columna | Tipo | Restricciones |
|---------|------|---------------|
| `id_venta` | `INT` | PK |
| `id_cliente` | `INT` | FK → `clientes.id_cliente` |
| `id_producto` | `INT` | FK → `productos.id_producto` |
| `cantidad` | `INT` | `NOT NULL` |
| `precio_unitario` | `DECIMAL(10,2)` | `NOT NULL` |
| `fecha_venta` | `DATE` | `NOT NULL` |

Los precios usan `DECIMAL` y no `FLOAT` para evitar errores de redondeo con importes.

### Datos cargados

| Tabla | Filas | Comentario |
|-------|-------|------------|
| `categorias` | 4 | Computación, Accesorios, Audio, Almacenamiento |
| `clientes` | 6 | El cliente 6 (Sofia Medina) **no tiene ventas a propósito** |
| `productos` | 7 | El producto 7 (Webcam HD Pro) **no tiene ventas a propósito** |
| `ventas` | 10 tras el M3, **20** tras `m4_ventas_adicionales.sql` | Rango de fechas: marzo a junio de 2024 |

Son datos de ejemplo con fines didácticos, cargados a mano. El cliente 6 y el producto 7 existen solo para poder mostrar en M5 el patrón `LEFT JOIN ... IS NULL` con un caso real; no son errores de carga.

---

## Cómo ejecutar los scripts SQL

### Requisitos

- Una instancia de **SQL Server** accesible (local o remota).
- Un usuario con permiso para crear bases de datos: el primer script crea `Ventas_Tech_DB` si no existe.
- Un cliente SQL: **DBeaver** (donde se probaron los scripts), **SSMS** o `sqlcmd`.

### Orden de ejecución

| Paso | Script | Qué produce |
|------|--------|-------------|
| 1 | `ventas_tech_db.sql` | Base, tablas y datos iniciales (4 / 6 / 7 / 10 filas) |
| 2 | `m4_ventas_adicionales.sql` | Ventas 11 a 20 (total: 20 ventas) |
| 3 | `m4_consultas_negocio.sql` | 4 consultas de negocio (solo lectura) |
| 4 | `m5_consultas_joins.sql` | 4 consultas con JOINs (solo lectura) |

### Paso a paso

1. **Clonar el repositorio**

   ```bash
   git clone <URL-del-repositorio>
   cd <carpeta-del-repositorio>
   ```

2. **Conectarse a SQL Server** desde el cliente elegido. No hace falta que `Ventas_Tech_DB` exista todavía.

3. **Ejecutar `ventas_tech_db.sql` completo.**
   - En DBeaver: abrir el archivo y usar *Execute SQL Script* (`Alt + X`). `Ctrl + Enter` ejecuta solo la sentencia actual y no sirve para este caso.
   - En SSMS: abrir el archivo y presionar `F5` sin nada seleccionado.

   El archivo usa `GO` para separar lotes, así que hay que correrlo entero y no por partes.

   Verificación: la última consulta del script debe devolver `total_categorias = 4`, `total_clientes = 6`, `total_productos = 7` y `total_ventas = 10`.

4. **Ejecutar `m4_ventas_adicionales.sql`.**

   Verificación: el `SELECT COUNT(*)` final debe devolver `total_ventas = 20`.

5. **Ejecutar `m4_consultas_negocio.sql`.** Cada `SELECT` devuelve su propio conjunto de resultados.

6. **Ejecutar `m5_consultas_joins.sql`.**

**Alternativa por línea de comandos** (autenticación de Windows; con usuario y contraseña de SQL Server usar `-U` y `-P` en lugar de `-E`):

```bash
sqlcmd -S localhost -E -i ventas_tech_db.sql
sqlcmd -S localhost -E -i m4_ventas_adicionales.sql
sqlcmd -S localhost -E -i m4_consultas_negocio.sql
sqlcmd -S localhost -E -i m5_consultas_joins.sql
```

### Cuidados al re-ejecutar

- **`ventas_tech_db.sql` es destructivo para las tablas:** borra y recrea `ventas`, `productos`, `clientes` y `categorias` (la base en sí no se borra). Si se vuelve a correr, se pierden las ventas 11 a 20, y hay que repetir el paso 2.
- `m4_ventas_adicionales.sql` es seguro de repetir: si la venta 11 ya existe, no inserta nada.
- Los scripts de consultas (`m4_consultas_negocio.sql` y `m5_consultas_joins.sql`) solo leen datos y se pueden correr las veces que haga falta.
- Las consultas de M4 y M5 deben correrse **después** del paso 2. Con solo las 10 ventas originales los resultados no coinciden con los hallazgos documentados en los scripts.

### Resultados esperados (para validar el entorno)

**M4, Consulta 1: resumen mensual** (el ticket promedio puede mostrarse con más decimales)

| mes | total_facturado | cantidad_pedidos | ticket_promedio |
|-----|-----------------|------------------|-----------------|
| 3 | 6444.00 | 10 | 644.40 |
| 4 | 1952.00 | 4 | 488.00 |
| 5 | 2590.00 | 4 | 647.50 |
| 6 | 425.00 | 2 | 212.50 |

- **M4, Consulta 2:** el Top 5 por facturación es, en orden, los productos 1, 3, 6, 4 y 2 (el producto 5 queda fuera del Top 5).
- **M4, Consulta 3:** los 5 clientes con ventas aparecen con 4 pedidos cada uno.
- **M4, Consulta 4:** solo marzo figura como "Por encima" del promedio mensual (2852.75).
- **M5, Consulta 1:** devuelve 20 filas, una por venta.
- **M5, Consulta 2:** devuelve a Sofia Medina.
- **M5, Consulta 3:** devuelve a Webcam HD Pro.
- **M5, Consulta 4:** "Primer periodo" = 8396 y "Segundo periodo" = 3015.

---

## Qué responde cada consulta

### M4 — `m4_consultas_negocio.sql`

| # | Pregunta de negocio | Técnica |
|---|---------------------|---------|
| 1 | ¿Cuánto se facturó por mes, cuántos pedidos hubo y cuál fue el ticket promedio? | `GROUP BY` con `DATEPART(MONTH, ...)` |
| 2 | ¿Cuáles son los 5 productos que más facturan, y cuántas unidades vendieron? | `TOP 5` + `ORDER BY` |
| 3 | ¿Qué clientes compraron más de una vez y cuánto gastaron? | `GROUP BY` + `HAVING` |
| 4 | ¿Qué meses superan el promedio mensual de facturación? | Subconsultas + `CASE` |

### M5 — `m5_consultas_joins.sql`

| # | Pregunta de negocio | Técnica |
|---|---------------------|---------|
| 1 | Vista base: quién compró, qué compró, de qué categoría, desde qué ciudad y por cuánto | 3 `INNER JOIN` encadenados |
| 2 | ¿Qué clientes están registrados pero nunca compraron? | `LEFT JOIN` + `IS NULL` |
| 3 | ¿Qué productos del catálogo nunca se vendieron? | `LEFT JOIN` + `IS NULL` |
| 4 | Total de ventas por período (antes y desde el 1 de mayo de 2024) | `UNION ALL` + `GROUP BY` |

La Consulta 1 de M5 está pensada como la tabla principal para llevar a Power BI.

---

## Notas para continuar el proyecto

- **Una fila de `ventas` es una línea con un único producto.** No hay una tabla de cabecera y detalle de pedidos: en las consultas de M4, "pedido" significa "fila de `ventas`".
- **Los meses se agrupan por número, sin año.** M4 usa `DATEPART(MONTH, fecha_venta)`, que es válido mientras todos los datos sean de 2024. Si se cargan ventas de otros años, hay que agrupar también por año.
- **`DATEPART` en lugar de `EXTRACT`.** La consigna del módulo sugería `EXTRACT(MONTH FROM ...)`, que es sintaxis de PostgreSQL y no existe en SQL Server. Se usa `DATEPART`, su equivalente en T-SQL.
- **El "canal" de la Consulta 4 de M5 es ficticio.** La base no tiene una columna de canal ni de sucursal; el script lo simula con dos períodos de tiempo (antes y desde el 1 de mayo de 2024) para practicar `UNION ALL`.
- **La muestra es chica.** Con 20 ventas en 4 meses, marzo concentra el 56 % de la facturación porque la carga original se hizo en ese mes. Conviene leer las tendencias con cautela hasta contar con más períodos.
- **Antes de modificar el esquema o los datos**, revisar el impacto en los módulos posteriores, que se construyen sobre esta base. Recordar además que `ventas_tech_db.sql` recrea las tablas desde cero.
