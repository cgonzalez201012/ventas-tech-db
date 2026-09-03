-- Checkpoint: Script SQL de Ingenieria de Datos
-- Base de datos Ventas_Tech_DB para TechStore
-- Motor: SQL Server (probado en DBeaver)
--
-- Modelo: categorias -> productos -> ventas <- clientes
-- (una categoria tiene muchos productos, un cliente tiene muchas ventas,
-- cada venta es de un producto y un cliente puntual)

-- Creo la base de datos
-- (el IF y el CREATE DATABASE van en lotes separados por GO,
-- porque SQL Server no permite CREATE DATABASE mezclado con
-- otras sentencias en el mismo lote)
IF DB_ID('Ventas_Tech_DB') IS NULL
BEGIN
    EXEC('CREATE DATABASE Ventas_Tech_DB');
END
GO

USE Ventas_Tech_DB;
GO


-- ==========================================
-- DROP TABLES
-- Borro las tablas si ya existen, para poder correr el script
-- de nuevo sin errores. El orden es al reves de como las creo:
-- primero ventas (que depende de las otras), al final categorias
-- (de la que no depende nadie). Si no respeto este orden, SQL
-- Server no me deja borrar una tabla mientras otra la esta usando
-- como Foreign Key.
-- ==========================================

IF OBJECT_ID('dbo.ventas', 'U') IS NOT NULL DROP TABLE dbo.ventas;
IF OBJECT_ID('dbo.productos', 'U') IS NOT NULL DROP TABLE dbo.productos;
IF OBJECT_ID('dbo.clientes', 'U') IS NOT NULL DROP TABLE dbo.clientes;
IF OBJECT_ID('dbo.categorias', 'U') IS NOT NULL DROP TABLE dbo.categorias;
GO


-- ==========================================
-- CREATE TABLES
-- Las creo en orden: primero las que no dependen de nadie
-- (categorias y clientes), despues productos (que necesita
-- que categorias ya exista), y al final ventas (que necesita
-- que clientes y productos ya existan).
-- ==========================================

-- Categorias de productos
CREATE TABLE dbo.categorias (
    id_categoria    INT             NOT NULL,
    nombre_categoria VARCHAR(50)    NOT NULL,
    descripcion     VARCHAR(200)    NULL,
    CONSTRAINT PK_categorias PRIMARY KEY (id_categoria)
);
GO

-- Clientes
CREATE TABLE dbo.clientes (
    id_cliente      INT             NOT NULL,
    nombre          VARCHAR(100)    NOT NULL,
    email           VARCHAR(100)    NULL,
    ciudad          VARCHAR(50)     NULL,
    fecha_registro  DATE            NOT NULL,
    CONSTRAINT PK_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_clientes_email UNIQUE (email)
);
GO

-- Productos (usa DECIMAL para el precio en vez de FLOAT,
-- porque FLOAT puede dar problemas de redondeo con dinero)
CREATE TABLE dbo.productos (
    id_producto     INT             NOT NULL,
    nombre_producto VARCHAR(100)    NOT NULL,
    id_categoria    INT             NOT NULL,
    precio          DECIMAL(10,2)   NOT NULL,
    stock           INT             NOT NULL DEFAULT 0,
    activo          BIT             NOT NULL DEFAULT 1,
    CONSTRAINT PK_productos PRIMARY KEY (id_producto),
    CONSTRAINT FK_productos_categorias FOREIGN KEY (id_categoria)
        REFERENCES dbo.categorias (id_categoria)
);
GO

-- Ventas: la tabla principal, conecta clientes con productos.
-- Tiene dos Foreign Keys, por eso la creo al final.
CREATE TABLE dbo.ventas (
    id_venta        INT             NOT NULL,
    id_cliente      INT             NOT NULL,
    id_producto     INT             NOT NULL,
    cantidad        INT             NOT NULL,
    precio_unitario DECIMAL(10,2)   NOT NULL,
    fecha_venta     DATE            NOT NULL,
    CONSTRAINT PK_ventas PRIMARY KEY (id_venta),
    CONSTRAINT FK_ventas_clientes FOREIGN KEY (id_cliente)
        REFERENCES dbo.clientes (id_cliente),
    CONSTRAINT FK_ventas_productos FOREIGN KEY (id_producto)
        REFERENCES dbo.productos (id_producto)
);
GO


-- ==========================================
-- INSERT DATA
-- Cargo los datos en el mismo orden que cree las tablas:
-- primero categorias y clientes, despues productos, al final
-- ventas. Si lo hago al reves, SQL Server rechaza el INSERT
-- porque estaria violando una Foreign Key (por ejemplo, no
-- puedo cargar un producto de una categoria que no existe).
-- ==========================================

-- categorias (4 registros)
INSERT INTO dbo.categorias (id_categoria, nombre_categoria, descripcion) VALUES
    (1, 'Computacion',    'Laptops, PCs y monitores'),
    (2, 'Accesorios',     'Perifericos y complementos'),
    (3, 'Audio',          'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');
GO

-- clientes (5 registros)
INSERT INTO dbo.clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
    (1, 'Maria Lopez', 'maria@mail.com', 'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz',  'carlos@mail.com', 'Cordoba',      '2024-01-10'),
    (3, 'Ana Gomez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
    (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
    (5, 'Laura Torres', 'laura@mail.com',  'Tucuman',      '2024-03-01');
GO

-- productos (6 registros)
INSERT INTO dbo.productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
    (1, 'Laptop Pro 15',        1, 1200.00, 15, 1),
    (2, 'Mouse Inalambrico',    2,   28.00, 80, 1),
    (3, 'Monitor 4K 27"',       1,  450.00, 12, 1),
    (4, 'Auriculares BT Pro',   3,  120.00, 35, 1),
    (5, 'SSD Externo 1TB',      4,  130.00, 18, 1),
    (6, 'Teclado Mecanico',     2,   95.00, 40, 1);
GO

-- ventas (10 registros)
INSERT INTO dbo.ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    (1,  1, 1, 2, 1200.00, '2024-03-05'),
    (2,  2, 2, 5,   28.00, '2024-03-06'),
    (3,  3, 3, 1,  450.00, '2024-03-07'),
    (4,  1, 4, 2,  120.00, '2024-03-08'),
    (5,  4, 5, 3,  130.00, '2024-03-10'),
    (6,  2, 6, 4,   95.00, '2024-03-11'),
    (7,  5, 1, 1, 1200.00, '2024-03-12'),
    (8,  3, 2, 8,   28.00, '2024-03-13'),
    (9,  4, 4, 1,  120.00, '2024-03-14'),
    (10, 5, 3, 2,  450.00, '2024-03-15');
GO


-- ==========================================
-- VALIDACION
-- Reviso que cada tabla haya cargado bien
-- ==========================================

SELECT * FROM dbo.categorias;
SELECT * FROM dbo.clientes;
SELECT * FROM dbo.productos;
SELECT * FROM dbo.ventas;

-- Cuento cuantas filas tiene cada tabla (deberia dar 4, 5, 6 y 10)
SELECT
    (SELECT COUNT(*) FROM dbo.categorias) AS total_categorias,
    (SELECT COUNT(*) FROM dbo.clientes)   AS total_clientes,
    (SELECT COUNT(*) FROM dbo.productos)  AS total_productos,
    (SELECT COUNT(*) FROM dbo.ventas)     AS total_ventas;
GO
