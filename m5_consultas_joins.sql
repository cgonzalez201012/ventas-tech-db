-- ============================================================
-- m5_consultas_joins.sql
-- Proyecto RetailPro - Modulo 5: Consultas con JOINs
-- Trabajo sobre el esquema Ventas_Tech_DB creado en el Checkpoint del Modulo 3.
-- ============================================================

USE Ventas_Tech_DB;
GO

-- ------------------------------------------------------------
-- Consulta 1: vista base del proyecto
-- Cruzo ventas con clientes, productos y categorias para tener en una sola fila
-- todo lo que necesito: quien compro, que compro, cuanto y de que categoria/ciudad es.
-- Esta va a ser la tabla principal que despues uso en Power BI.
-- ------------------------------------------------------------
SELECT
    v.fecha_venta,
    v.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM dbo.ventas v
INNER JOIN dbo.clientes c ON v.id_cliente = c.id_cliente
INNER JOIN dbo.productos p ON v.id_producto = p.id_producto
INNER JOIN dbo.categorias cat ON p.id_categoria = cat.id_categoria;
GO

-- ------------------------------------------------------------
-- Antes de esta consulta agregue un cliente de prueba sin ventas
-- (ver INSERT documentado en ventas_tech_db.sql, seccion de clientes),
-- porque los 5 clientes originales tenian todos al menos una venta.
--
-- Consulta 2: clientes sin ventas
-- El area de CRM quiere saber que clientes estan registrados pero nunca compraron.
-- Hago LEFT JOIN desde clientes hacia ventas: asi conservo todos los clientes,
-- tengan o no ventas. Los que no tienen, quedan con id_venta en NULL, y con
-- ese filtro los aislo.
-- ------------------------------------------------------------
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM dbo.clientes c
LEFT JOIN dbo.ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO

-- ------------------------------------------------------------
-- Antes de esta consulta agregue un producto de prueba sin ventas
-- (ver INSERT documentado en ventas_tech_db.sql, seccion de productos),
-- porque los 6 productos originales tenian todos al menos una venta.
--
-- Consulta 3: productos sin ventas
-- El area de producto quiere saber que articulos del catalogo nunca se vendieron.
-- Mismo mecanismo que la Consulta 2: LEFT JOIN desde productos hacia ventas,
-- asi conservo todos los productos tengan o no ventas, y filtro los que
-- quedaron con id_venta en NULL (sin ninguna coincidencia).
-- ------------------------------------------------------------
SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM dbo.productos p
LEFT JOIN dbo.categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN dbo.ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
GO

-- ------------------------------------------------------------
-- Consulta 4: consolidado de ventas por canal
-- No tengo una columna real de canal ni sucursal en mi base, asi que la creo
-- yo mismo como valor literal dentro de cada SELECT, separando las ventas
-- en dos periodos de tiempo (antes y despues del 1 de mayo de 2024).
-- Uso UNION ALL y no UNION porque quiero contar cada venta una sola vez,
-- sin que se eliminen filas aunque coincidan en todos sus valores.
-- ------------------------------------------------------------
SELECT
    canal,
    SUM(total) AS total_por_canal
FROM (
    SELECT fecha_venta AS fecha, cantidad * precio_unitario AS total, 'Primer periodo' AS canal
    FROM dbo.ventas
    WHERE fecha_venta < '2024-05-01'
    UNION ALL
    SELECT fecha_venta AS fecha, cantidad * precio_unitario AS total, 'Segundo periodo' AS canal
    FROM dbo.ventas
    WHERE fecha_venta >= '2024-05-01'
) consolidado
GROUP BY canal;
GO
