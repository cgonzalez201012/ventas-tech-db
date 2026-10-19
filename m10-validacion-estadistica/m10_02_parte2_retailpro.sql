-- Entrega 10 - Parte 2: validacion estadistica de RetailPro (tabla ventas, columna total_venta)
-- Motor: SQL Server (T-SQL), probado en DBeaver
-- Antes hay que haber corrido m10_00_preparar_datos.sql (carga las 50 ventas).
--
-- Las consultas de la consigna estan escritas para PostgreSQL. En SQL Server cambian dos cosas:
--   - PERCENTILE_CONT necesita OVER () al final y devuelve un valor por fila,
--     por eso uso SELECT DISTINCT (o una tabla auxiliar q) para quedarme con una sola fila
--   - la desviacion estandar muestral es STDEV
-- El percentil es PERCENTILE_CONT (interpola entre valores), igual que QUARTILE.INC de Excel.
--
-- En DBeaver correrlo como script completo (Option + X). Cada SELECT sale en una pestana de resultados.

USE RetailPro_Validacion;
GO


-- ==========================================
-- 2a) TICKET PROMEDIO: media vs mediana
-- Ticket = total_venta de cada linea de venta (no hay tabla de ordenes)
-- Esperado: n 50 / total 47578 / media 951.56 / mediana 450.00
-- ==========================================

-- 2a-1) Media y mediana
SELECT DISTINCT
    COUNT(*)           OVER ()                                              AS n_ventas,
    SUM(total_venta)   OVER ()                                              AS total_facturado,
    CAST(AVG(total_venta) OVER () AS DECIMAL(12,2))                         AS media,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_venta) OVER ()
         AS DECIMAL(12,2))                                                  AS mediana
FROM dbo.ventas;
GO

-- 2a-2) Dispersion: minimo, maximo y desviacion estandar muestral
-- Esperado: minimo 140 / maximo 5400 / desvio 1041.76
SELECT
    MIN(total_venta)                          AS minimo,
    MAX(total_venta)                          AS maximo,
    CAST(STDEV(total_venta) AS DECIMAL(12,2)) AS desvio_muestral
FROM dbo.ventas;
GO

-- 2a-3) Media y mediana por canal (para saber si el ticket por canal es confiable)
-- Esperado: Online 29 ventas, media 1191.98, mediana 520.00
--           Presencial 21 ventas, media 619.55, mediana 420.00
SELECT DISTINCT
    canal,
    COUNT(*)         OVER (PARTITION BY canal)                              AS n_ventas,
    CAST(AVG(total_venta) OVER (PARTITION BY canal) AS DECIMAL(12,2))       AS media,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_venta)
         OVER (PARTITION BY canal) AS DECIMAL(12,2))                        AS mediana
FROM dbo.ventas
ORDER BY canal;
GO

-- 2a-4) Cuantas ventas quedan por debajo y por encima de la media
-- Sirve para ver si el ticket promedio describe a una venta tipica
-- Esperado: n 50 / 33 por debajo de la media (66.0 %) / 17 por encima
SELECT
    COUNT(*)                                                    AS n_ventas,
    SUM(CASE WHEN v.total_venta < m.media THEN 1 ELSE 0 END)    AS ventas_bajo_la_media,
    SUM(CASE WHEN v.total_venta > m.media THEN 1 ELSE 0 END)    AS ventas_sobre_la_media,
    CAST(100.0 * SUM(CASE WHEN v.total_venta < m.media THEN 1 ELSE 0 END) / COUNT(*)
         AS DECIMAL(5,1))                                       AS pct_bajo_la_media
FROM dbo.ventas v
CROSS JOIN (SELECT AVG(total_venta) AS media FROM dbo.ventas) m;
GO


-- ==========================================
-- 2b) OUTLIERS CON IQR
-- Esperado: Q1 340.50 / Q3 1283.75 / IQR 943.25 / limite inferior -1074.38 / limite superior 2698.63
-- ==========================================

-- 2b-1) Q1, Q3, IQR y limites
WITH q AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_venta) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_venta) OVER () AS q3
    FROM dbo.ventas
)
SELECT
    CAST(q1                  AS DECIMAL(12,2)) AS q1,
    CAST(q3                  AS DECIMAL(12,2)) AS q3,
    CAST(q3 - q1             AS DECIMAL(12,2)) AS iqr,
    CAST(q1 - 1.5*(q3 - q1)  AS DECIMAL(12,2)) AS limite_inferior,
    CAST(q3 + 1.5*(q3 - q1)  AS DECIMAL(12,2)) AS limite_superior
FROM q;
GO

-- 2b-2) Las ventas que caen fuera de los limites (version de la consigna, adaptada a SQL Server)
-- Esperado: 3 filas (ids 1030, 1048 y 1021)
WITH q AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_venta) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_venta) OVER () AS q3
    FROM dbo.ventas
)
SELECT v.*
FROM dbo.ventas v
CROSS JOIN q
WHERE v.total_venta < q.q1 - 1.5*(q.q3 - q.q1)
   OR v.total_venta > q.q3 + 1.5*(q.q3 - q.q1)
ORDER BY v.total_venta DESC;
GO

-- 2b-3) Los mismos outliers, con cliente y producto, para decidir si son error o evento legitimo
-- total_recalculado = cantidad x precio_unitario x (1 - descuento)
-- Si coincide con total_venta, no hay error de carga
WITH q AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_venta) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_venta) OVER () AS q3
    FROM dbo.ventas
)
SELECT
    v.id_venta,
    v.fecha_venta,
    c.nombre_cliente,
    p.nombre_producto,
    p.categoria,
    v.canal,
    v.cantidad,
    v.precio_unitario,
    v.descuento,
    v.total_venta,
    CAST(v.cantidad * v.precio_unitario * (1 - v.descuento) AS DECIMAL(12,2)) AS total_recalculado
FROM dbo.ventas v
CROSS JOIN q
JOIN dbo.clientes  c ON c.id_cliente  = v.id_cliente
JOIN dbo.productos p ON p.id_producto = v.id_producto
WHERE v.total_venta < q.q1 - 1.5*(q.q3 - q.q1)
   OR v.total_venta > q.q3 + 1.5*(q.q3 - q.q1)
ORDER BY v.total_venta DESC;
GO

-- 2b-4) Controles de calidad sobre TODA la tabla
-- Si alguno da distinto de 0, hay un error de carga
-- Esperado: todo 0, fechas del 2023-01-10 al 2024-07-22
SELECT
    SUM(CASE WHEN ABS(v.total_venta - v.cantidad * v.precio_unitario * (1 - v.descuento)) > 0.01
             THEN 1 ELSE 0 END)                              AS total_distinto_al_calculo,
    SUM(CASE WHEN v.precio_unitario <> p.precio
             THEN 1 ELSE 0 END)                              AS precio_distinto_al_catalogo,
    COUNT(*) - COUNT(DISTINCT v.id_venta)                    AS ids_repetidos,
    SUM(CASE WHEN v.cantidad <= 0 OR v.total_venta <= 0
             THEN 1 ELSE 0 END)                              AS cantidades_o_totales_invalidos,
    MIN(v.fecha_venta)                                       AS primera_fecha,
    MAX(v.fecha_venta)                                       AS ultima_fecha
FROM dbo.ventas v
JOIN dbo.productos p ON p.id_producto = v.id_producto;
GO

-- 2b-5) Cuanto pesan los outliers en la facturacion
-- Esperado: 3 outliers / 12240 de 47578 = 25.7 %
WITH q AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_venta) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_venta) OVER () AS q3
    FROM dbo.ventas
)
SELECT
    COUNT(*)                                                            AS n_outliers,
    SUM(v.total_venta)                                                  AS monto_outliers,
    (SELECT SUM(total_venta) FROM dbo.ventas)                           AS total_facturado,
    CAST(100.0 * SUM(v.total_venta) / (SELECT SUM(total_venta) FROM dbo.ventas)
         AS DECIMAL(5,1))                                               AS pct_del_total
FROM dbo.ventas v
CROSS JOIN q
WHERE v.total_venta < q.q1 - 1.5*(q.q3 - q.q1)
   OR v.total_venta > q.q3 + 1.5*(q.q3 - q.q1);
GO

-- 2b-6) Media y mediana SIN los outliers (para ver cuanto distorsionan)
-- Esperado: n 47 / media 751.87 / mediana 432.00
WITH q AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_venta) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_venta) OVER () AS q3
    FROM dbo.ventas
),
sin_outliers AS (
    SELECT v.total_venta
    FROM dbo.ventas v
    CROSS JOIN q
    WHERE v.total_venta BETWEEN q.q1 - 1.5*(q.q3 - q.q1) AND q.q3 + 1.5*(q.q3 - q.q1)
)
SELECT DISTINCT
    COUNT(*) OVER ()                                                    AS n_sin_outliers,
    CAST(AVG(total_venta) OVER () AS DECIMAL(12,2))                     AS media_sin_outliers,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_venta) OVER ()
         AS DECIMAL(12,2))                                              AS mediana_sin_outliers
FROM sin_outliers;
GO


-- ==========================================
-- 2c) CONEXION CON EL DASHBOARD (boceto de M7)
-- Los 5 meses con mas ventas y cuanto de cada mes viene de ventas outlier
-- Esperado (de mayor a menor total_mes):
--   2023-12 (7055, 76.5 %), 2024-06 (4530, 79.5 %), 2024-03 (4200, 0 %),
--   2023-08 (4170, 77.7 %), 2024-05 (3750, 0 %)
-- ==========================================
WITH q AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_venta) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_venta) OVER () AS q3
    FROM dbo.ventas
),
marcadas AS (
    SELECT
        FORMAT(v.fecha_venta, 'yyyy-MM') AS mes,
        v.total_venta,
        CASE WHEN v.total_venta < q.q1 - 1.5*(q.q3 - q.q1)
               OR v.total_venta > q.q3 + 1.5*(q.q3 - q.q1)
             THEN 1 ELSE 0 END AS es_outlier
    FROM dbo.ventas v
    CROSS JOIN q
)
SELECT TOP 5
    mes,
    COUNT(*)                                                            AS ventas_del_mes,
    SUM(total_venta)                                                    AS total_mes,
    SUM(CASE WHEN es_outlier = 1 THEN total_venta ELSE 0 END)           AS total_outliers,
    CAST(100.0 * SUM(CASE WHEN es_outlier = 1 THEN total_venta ELSE 0 END) / SUM(total_venta)
         AS DECIMAL(5,1))                                               AS pct_outliers_del_mes
FROM marcadas
GROUP BY mes
ORDER BY SUM(total_venta) DESC;
GO
