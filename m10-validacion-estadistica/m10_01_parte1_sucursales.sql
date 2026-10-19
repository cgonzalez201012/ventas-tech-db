-- Entrega 10 - Parte 1: caso guiado de las dos sucursales (Norte y Sur)
-- Motor: SQL Server (T-SQL), probado en DBeaver
--
-- Datos de la consigna (ventas diarias de 5 dias laborales, en USD):
--   Norte: 500, 510, 490, 505, 495
--   Sur:   100, 900, 50, 1200, 250
-- Las dos sucursales venden lo mismo en promedio. Lo que quiero ver es cual es mas estable.
--
-- En SQL Server la desviacion estandar muestral es STDEV (en PostgreSQL es STDDEV_SAMP).
-- Se toma como muestra (divide por n-1) porque la consigna dice que son una muestra
-- de la operacion anual.
--
-- En DBeaver correrlo como script completo (Option + X). Cada SELECT sale en una pestana de resultados.

USE RetailPro_Validacion;
GO

IF OBJECT_ID('dbo.ventas_semana', 'U') IS NOT NULL DROP TABLE dbo.ventas_semana;
GO

CREATE TABLE dbo.ventas_semana (
    sucursal    VARCHAR(20)     NOT NULL,
    dia         INT             NOT NULL,
    venta       DECIMAL(10,2)   NOT NULL,
    CONSTRAINT PK_ventas_semana PRIMARY KEY (sucursal, dia)
);
GO

INSERT INTO dbo.ventas_semana (sucursal, dia, venta) VALUES
    ('Norte', 1, 500.00),
    ('Norte', 2, 510.00),
    ('Norte', 3, 490.00),
    ('Norte', 4, 505.00),
    ('Norte', 5, 495.00),
    ('Sur', 1, 100.00),
    ('Sur', 2, 900.00),
    ('Sur', 3, 50.00),
    ('Sur', 4, 1200.00),
    ('Sur', 5, 250.00);
GO


-- Validacion de la carga: tienen que ser 5 filas por sucursal
SELECT sucursal, COUNT(*) AS dias_cargados
FROM dbo.ventas_semana
GROUP BY sucursal;
GO


-- ==========================================
-- 1) Media y rango
-- Esperado: Norte media 500 y rango 20 / Sur media 500 y rango 1150
-- ==========================================
SELECT
    sucursal,
    CAST(AVG(venta) AS DECIMAL(12,2))  AS media,
    MAX(venta) - MIN(venta)            AS rango
FROM dbo.ventas_semana
GROUP BY sucursal;
GO


-- ==========================================
-- 2) Desviacion estandar muestral
-- Esperado: Norte 7.91 / Sur 518.41
-- ==========================================
SELECT
    sucursal,
    CAST(STDEV(venta) AS DECIMAL(12,2))  AS desvio_muestral
FROM dbo.ventas_semana
GROUP BY sucursal;
GO


-- ==========================================
-- 3) Todo junto, para la tabla del informe
-- coef_variacion = desvio / media (en %): cuanto se mueve la venta respecto de su promedio
-- ==========================================
SELECT
    sucursal,
    MIN(venta)                                                  AS minimo,
    MAX(venta)                                                  AS maximo,
    CAST(AVG(venta) AS DECIMAL(12,2))                           AS media,
    MAX(venta) - MIN(venta)                                     AS rango,
    CAST(STDEV(venta) AS DECIMAL(12,2))                         AS desvio_muestral,
    CAST(100.0 * STDEV(venta) / AVG(venta) AS DECIMAL(6,2))     AS coef_variacion_pct
FROM dbo.ventas_semana
GROUP BY sucursal;
GO
