-- ============================================================
-- m4_ventas_adicionales.sql
-- Ventas 11 a 20 que agregue en el Modulo 4.
--
-- El script ventas_tech_db.sql (Modulo 3) carga solo 10 ventas, todas de
-- marzo de 2024. Con eso las consultas del Modulo 4 devolvian una sola
-- fila por mes, asi que agregue 10 ventas mas, de abril a junio, usando
-- clientes (1 al 5) y productos (1 al 6) que ya existian. No se rompe
-- ninguna Foreign Key.
--
-- Orden para correr los scripts:
--   1) ventas_tech_db.sql
--   2) m4_ventas_adicionales.sql  (este archivo)
--   3) m4_consultas_negocio.sql
--   4) m5_consultas_joins.sql
--
-- Se puede correr mas de una vez: si la venta 11 ya esta cargada,
-- no hace nada.
-- ============================================================

USE Ventas_Tech_DB;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ventas WHERE id_venta = 11)
BEGIN
    INSERT INTO dbo.ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
        (11, 2, 3, 1,  450.00, '2024-04-03'),
        (12, 1, 2, 4,   28.00, '2024-04-09'),
        (13, 4, 1, 1, 1200.00, '2024-04-18'),
        (14, 3, 6, 2,   95.00, '2024-04-25'),
        (15, 5, 4, 3,  120.00, '2024-05-02'),
        (16, 2, 5, 1,  130.00, '2024-05-11'),
        (17, 1, 1, 1, 1200.00, '2024-05-20'),
        (18, 4, 3, 2,  450.00, '2024-05-28'),
        (19, 3, 2, 5,   28.00, '2024-06-06'),
        (20, 5, 6, 3,   95.00, '2024-06-14');
END
GO

-- Verifico: deberia dar 20 ventas en total (10 del Modulo 3 + 10 de este archivo)
SELECT COUNT(*) AS total_ventas FROM dbo.ventas;
GO
