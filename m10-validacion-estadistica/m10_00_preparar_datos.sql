-- Entrega 10: Validacion estadistica del proyecto
-- Script 0: dejo cargados los datos de RetailPro para poder calcular con SQL
-- Motor: SQL Server (T-SQL), probado en DBeaver
--
-- Los datos salen del Excel del curso (Pipeline_ETL_Dataset.xlsx), con la misma
-- limpieza que hice en M6 (Power Query):
--   - cliente 1 (Maria Lopez) y producto 103 (Monitor 4K) estaban repetidos: dejo uno solo
--   - producto 109 (SSD Externo) no tenia precio: pongo 130 (es el precio_unitario de sus 5 ventas)
--   - producto 111 (Laptop Gaming Pro) no tenia categoria: pongo Computacion (igual que 101 y 105)
-- Resultado: 11 clientes, 12 productos y 50 ventas (las mismas filas que Fact_Ventas en Power BI).
--
-- Armo una base nueva (RetailPro_Validacion) para no tocar Ventas_Tech_DB.
-- En Ventas_Tech_DB la tabla ventas no tiene total_venta ni canal, que son
-- las columnas que usa el boceto del dashboard (M7) y las que pide esta entrega.
-- Se puede correr de nuevo las veces que haga falta: borra y vuelve a cargar.
--
-- En DBeaver correrlo como script completo (Option + X), no sentencia por sentencia.

-- Creo la base de datos (con EXEC para que CREATE DATABASE quede en su propio lote, como en M3)
IF DB_ID('RetailPro_Validacion') IS NULL
    EXEC('CREATE DATABASE RetailPro_Validacion');
GO

USE RetailPro_Validacion;
GO


-- ==========================================
-- DROP TABLES
-- Orden inverso al de creacion: primero ventas (depende de las otras)
-- ==========================================

IF OBJECT_ID('dbo.ventas', 'U') IS NOT NULL DROP TABLE dbo.ventas;
IF OBJECT_ID('dbo.productos', 'U') IS NOT NULL DROP TABLE dbo.productos;
IF OBJECT_ID('dbo.clientes', 'U') IS NOT NULL DROP TABLE dbo.clientes;
GO


-- ==========================================
-- CREATE TABLES
-- Dinero siempre en DECIMAL (no FLOAT)
-- ==========================================

CREATE TABLE dbo.clientes (
    id_cliente      INT             NOT NULL,
    nombre_cliente  NVARCHAR(100)   NOT NULL,
    CONSTRAINT PK_clientes PRIMARY KEY (id_cliente)
);
GO

CREATE TABLE dbo.productos (
    id_producto     INT             NOT NULL,
    nombre_producto NVARCHAR(100)   NOT NULL,
    categoria       NVARCHAR(50)    NOT NULL,
    precio          DECIMAL(10,2)   NOT NULL,
    CONSTRAINT PK_productos PRIMARY KEY (id_producto)
);
GO

-- Cada fila de ventas es una linea de venta: un cliente, un producto, una cantidad.
-- No hay tabla de ordenes, por eso el "ticket" de esta entrega es el total_venta de cada linea.
CREATE TABLE dbo.ventas (
    id_venta        INT             NOT NULL,
    fecha_venta     DATE            NOT NULL,
    id_cliente      INT             NOT NULL,
    id_producto     INT             NOT NULL,
    cantidad        INT             NOT NULL,
    precio_unitario DECIMAL(10,2)   NOT NULL,
    descuento       DECIMAL(4,2)    NOT NULL,
    total_venta     DECIMAL(12,2)   NOT NULL,
    canal           VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_ventas PRIMARY KEY (id_venta),
    CONSTRAINT FK_ventas_clientes FOREIGN KEY (id_cliente)
        REFERENCES dbo.clientes (id_cliente),
    CONSTRAINT FK_ventas_productos FOREIGN KEY (id_producto)
        REFERENCES dbo.productos (id_producto)
);
GO


-- ==========================================
-- INSERT DATA
-- Orden: clientes y productos primero, ventas al final (por las Foreign Keys)
-- ==========================================

INSERT INTO dbo.clientes (id_cliente, nombre_cliente) VALUES
    (1, N'María López'),
    (2, N'Carlos Ruiz'),
    (3, N'Ana Gómez'),
    (4, N'Pedro Sanz'),
    (5, N'Laura Torres'),
    (6, N'Diego Mora'),
    (7, N'Sofía Reyes'),
    (8, N'Martín Cruz'),
    (9, N'Valentina Paz'),
    (10, N'Lucía Vargas'),
    (11, N'Roberto Díaz');
GO

INSERT INTO dbo.productos (id_producto, nombre_producto, categoria, precio) VALUES
    (101, N'Laptop Pro 15', N'Computación', 1200.00),
    (102, N'Mouse Inalámbrico', N'Accesorios', 28.00),
    (103, N'Monitor 4K 27"', N'Computación', 450.00),
    (104, N'Teclado Mecánico', N'Accesorios', 95.00),
    (105, N'Laptop Basic 14', N'Computación', 650.00),
    (106, N'Auriculares BT Pro', N'Audio', 120.00),
    (107, N'Hub USB-C 7p', N'Accesorios', 45.00),
    (108, N'Webcam HD 1080p', N'Accesorios', 85.00),
    (109, N'SSD Externo 1TB', N'Almacenamiento', 130.00),
    (110, N'Parlante Bluetooth', N'Audio', 60.00),
    (111, N'Laptop Gaming Pro', N'Computación', 1800.00),
    (112, N'Pad Mouse XL', N'Accesorios', 22.00);
GO

INSERT INTO dbo.ventas (id_venta, fecha_venta, id_cliente, id_producto, cantidad, precio_unitario, descuento, total_venta, canal) VALUES
    (1001, '2023-01-10', 1, 101, 2, 1200.00, 0.00, 2400.00, 'Online'),
    (1002, '2023-01-15', 2, 102, 5, 28.00, 0.00, 140.00, 'Presencial'),
    (1003, '2023-01-22', 3, 103, 1, 450.00, 0.05, 427.50, 'Online'),
    (1004, '2023-02-05', 4, 104, 3, 95.00, 0.00, 285.00, 'Presencial'),
    (1005, '2023-02-14', 5, 105, 2, 650.00, 0.00, 1300.00, 'Online'),
    (1006, '2023-02-28', 1, 106, 4, 120.00, 0.10, 432.00, 'Online'),
    (1007, '2023-03-08', 6, 107, 6, 45.00, 0.00, 270.00, 'Presencial'),
    (1008, '2023-03-15', 7, 108, 2, 85.00, 0.00, 170.00, 'Online'),
    (1009, '2023-03-22', 8, 109, 3, 130.00, 0.05, 370.50, 'Presencial'),
    (1010, '2023-04-03', 9, 110, 5, 60.00, 0.00, 300.00, 'Online'),
    (1011, '2023-04-18', 10, 111, 1, 1800.00, 0.00, 1800.00, 'Online'),
    (1012, '2023-04-25', 2, 101, 1, 1200.00, 0.00, 1200.00, 'Presencial'),
    (1013, '2023-05-06', 3, 102, 8, 28.00, 0.00, 224.00, 'Online'),
    (1014, '2023-05-20', 4, 103, 2, 450.00, 0.10, 810.00, 'Presencial'),
    (1015, '2023-05-30', 5, 104, 4, 95.00, 0.00, 380.00, 'Online'),
    (1016, '2023-06-08', 6, 105, 2, 650.00, 0.00, 1300.00, 'Presencial'),
    (1017, '2023-06-15', 7, 106, 3, 120.00, 0.05, 342.00, 'Online'),
    (1018, '2023-06-28', 8, 109, 2, 130.00, 0.00, 260.00, 'Online'),
    (1019, '2023-07-05', 9, 110, 6, 60.00, 0.00, 360.00, 'Presencial'),
    (1020, '2023-07-19', 10, 108, 3, 85.00, 0.00, 255.00, 'Online'),
    (1021, '2023-08-02', 1, 111, 2, 1800.00, 0.10, 3240.00, 'Online'),
    (1022, '2023-08-14', 2, 102, 10, 28.00, 0.00, 280.00, 'Presencial'),
    (1023, '2023-08-25', 3, 105, 1, 650.00, 0.00, 650.00, 'Online'),
    (1024, '2023-09-10', 4, 106, 5, 120.00, 0.05, 570.00, 'Presencial'),
    (1025, '2023-09-22', 5, 103, 3, 450.00, 0.00, 1350.00, 'Online'),
    (1026, '2023-10-04', 6, 101, 1, 1200.00, 0.00, 1200.00, 'Presencial'),
    (1027, '2023-10-18', 7, 107, 8, 45.00, 0.00, 360.00, 'Online'),
    (1028, '2023-11-06', 8, 104, 6, 95.00, 0.10, 513.00, 'Presencial'),
    (1029, '2023-11-20', 9, 109, 4, 130.00, 0.00, 520.00, 'Online'),
    (1030, '2023-12-05', 10, 111, 3, 1800.00, 0.00, 5400.00, 'Online'),
    (1031, '2023-12-15', 1, 110, 7, 60.00, 0.00, 420.00, 'Presencial'),
    (1032, '2023-12-28', 2, 105, 2, 650.00, 0.05, 1235.00, 'Online'),
    (1033, '2024-01-08', 3, 101, 2, 1200.00, 0.00, 2400.00, 'Online'),
    (1034, '2024-01-15', 4, 102, 6, 28.00, 0.00, 168.00, 'Presencial'),
    (1035, '2024-01-25', 5, 103, 1, 450.00, 0.00, 450.00, 'Online'),
    (1036, '2024-02-03', 6, 104, 4, 95.00, 0.10, 342.00, 'Presencial'),
    (1037, '2024-02-14', 7, 106, 3, 120.00, 0.00, 360.00, 'Online'),
    (1038, '2024-02-22', 8, 109, 2, 130.00, 0.05, 247.00, 'Online'),
    (1039, '2024-03-05', 9, 111, 1, 1800.00, 0.00, 1800.00, 'Presencial'),
    (1040, '2024-03-18', 10, 105, 3, 650.00, 0.00, 1950.00, 'Online'),
    (1041, '2024-03-28', 1, 107, 10, 45.00, 0.00, 450.00, 'Presencial'),
    (1042, '2024-04-06', 2, 108, 4, 85.00, 0.00, 340.00, 'Online'),
    (1043, '2024-04-20', 3, 110, 8, 60.00, 0.05, 456.00, 'Presencial'),
    (1044, '2024-05-04', 4, 101, 2, 1200.00, 0.00, 2400.00, 'Online'),
    (1045, '2024-05-18', 5, 103, 3, 450.00, 0.00, 1350.00, 'Presencial'),
    (1046, '2024-06-02', 6, 106, 5, 120.00, 0.10, 540.00, 'Online'),
    (1047, '2024-06-15', 7, 109, 3, 130.00, 0.00, 390.00, 'Presencial'),
    (1048, '2024-06-28', 8, 111, 2, 1800.00, 0.00, 3600.00, 'Online'),
    (1049, '2024-07-10', 9, 102, 12, 28.00, 0.00, 336.00, 'Presencial'),
    (1050, '2024-07-22', 10, 105, 2, 650.00, 0.05, 1235.00, 'Online');
GO


-- ==========================================
-- VALIDACION
-- Tiene que dar: 11 clientes, 12 productos, 50 ventas, total 47578.00
-- ==========================================

SELECT
    (SELECT COUNT(*) FROM dbo.clientes)        AS clientes,
    (SELECT COUNT(*) FROM dbo.productos)       AS productos,
    (SELECT COUNT(*) FROM dbo.ventas)          AS ventas,
    (SELECT SUM(total_venta) FROM dbo.ventas)  AS total_facturado;
GO
