-- =========================================================
-- M4 - Consultas SQL de negocio - RetailPro
-- Base: Ventas_Tech_DB (creada en M3), tabla ventas
-- =========================================================

USE Ventas_Tech_DB;
GO

-- =========================================================
-- NOTAS DE DISENO Y AJUSTES TECNICOS
-- =========================================================
-- 1) EXTRACT -> DATEPART/MONTH: la consigna del entregable
--    sugiere EXTRACT(MONTH FROM fecha_venta), que es sintaxis
--    de PostgreSQL. La base Ventas_Tech_DB corre en SQL Server
--    (mismo motor usado en M3), donde EXTRACT no existe.
--    Se reemplaza por DATEPART(MONTH, fecha_venta), la funcion
--    equivalente en T-SQL, para que el script sea valido tanto
--    en DBeaver como en SSMS real (mismo criterio aplicado en
--    el script de M3: probar en DBeaver pero disenar pensando
--    en SSMS).
--
-- 2) Ampliacion del DML de ventas (+10 filas, id_venta 11-20):
--    los 10 registros originales cargados en M3 caian todos en
--    marzo/2024, lo que impedia comparar meses distintos en las
--    consultas de este modulo (la Consulta 1 y la Consulta 4
--    hubieran devuelto una unica fila, sin valor analitico).
--    Se agregaron 10 ventas mas en la tabla ventas, usando los
--    mismos id_cliente (1-5) e id_producto (1-6) ya existentes
--    en la base (sin romper ninguna Foreign Key), con fechas
--    distribuidas en abril, mayo y junio de 2024, para ampliar
--    la muestra y enriquecer el resultado del analisis mensual.
-- =========================================================


-- =========================================================
-- Consulta 1 - Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio,
-- agrupados por mes.
-- =========================================================
SELECT
    DATEPART(MONTH, fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(id_venta) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) / COUNT(id_venta) AS ticket_promedio
FROM ventas
GROUP BY DATEPART(MONTH, fecha_venta)
ORDER BY mes;


-- =========================================================
-- Consulta 2 - Ranking de productos
-- Top 5 de id_producto por total facturado, con unidades
-- vendidas y total generado.
-- =========================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;


-- =========================================================
-- Consulta 3 - Clientes recurrentes
-- id_cliente con mas de un pedido, con cantidad de pedidos
-- y total gastado.
-- =========================================================
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- =========================================================
-- Consulta 4 - Meses por encima/por debajo del promedio
-- Total facturado por mes, etiquetado segun si supera o no
-- el promedio mensual general.
-- =========================================================
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (
            SELECT AVG(total_facturado) FROM (
                SELECT DATEPART(MONTH, fecha_venta) AS mes,
                       SUM(cantidad * precio_unitario) AS total_facturado
                FROM ventas
                GROUP BY DATEPART(MONTH, fecha_venta)
            ) AS promedio_mensual
        )
        THEN 'Por encima'
        ELSE 'Por debajo'
    END AS performance
FROM (
    SELECT DATEPART(MONTH, fecha_venta) AS mes,
           SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY DATEPART(MONTH, fecha_venta)
) AS ventas_por_mes
ORDER BY mes;


-- =========================================================
-- HALLAZGOS
-- =========================================================
-- 1) El producto 1 (Laptop, $1200) genero el mayor total facturado
--    ($6.000) vendiendo solo 5 unidades, mientras que el producto 2
--    (Mouse, $28) vendio 22 unidades -la mayor cantidad- pero quedo
--    ultimo en facturacion ($616). El volumen de ventas no es un
--    buen indicador de impacto en los ingresos: conviene priorizar
--    el analisis por facturacion, no por unidades.
--
-- 2) Los 5 clientes activos en la base realizaron 4 pedidos cada
--    uno, sin ningun caso de compra unica. La totalidad de la
--    cartera de clientes es recurrente, lo que sugiere una buena
--    tasa de retencion con la base de datos actual.
--
-- 3) De los 4 meses analizados, marzo es el unico que supero el
--    promedio mensual de facturacion ($2.852), representando el
--    56% del total del periodo. Esto se debe a que el volumen de
--    datos cargado para ese mes es mayor al de los meses
--    siguientes, por lo que conviene interpretar la tendencia con
--    cautela hasta contar con mas periodos de datos reales.
-- =========================================================
