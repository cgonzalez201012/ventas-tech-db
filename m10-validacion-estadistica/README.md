# M10 · Validación estadística del proyecto

En este módulo validé con estadística los datos de RetailPro antes de seguir con el dashboard: primero un caso guiado de dos sucursales (Parte 1) y después las 50 ventas del proyecto (Parte 2): media contra mediana, outliers con el método IQR y revisión del boceto del dashboard de M7. El análisis completo, con tablas, interpretación y capturas, está en el documento de la entrega.

## Archivos

| Archivo | Qué hace |
|---------|----------|
| [`m10_00_preparar_datos.sql`](m10_00_preparar_datos.sql) | Crea la base `RetailPro_Validacion` y carga 11 clientes, 12 productos y 50 ventas. Se puede correr de nuevo: borra las tablas y las vuelve a cargar. |
| [`m10_01_parte1_sucursales.sql`](m10_01_parte1_sucursales.sql) | Parte 1: media, rango y desviación estándar muestral de las sucursales Norte y Sur. |
| [`m10_02_parte2_retailpro.sql`](m10_02_parte2_retailpro.sql) | Parte 2: media y mediana del ticket (2a), outliers con IQR (2b) y los meses con más ventas (2c). |

## Cómo ejecutarlos

1. Levantar SQL Server (en mi caso, el contenedor Docker `sql-coderhouse`) y conectarse.
2. Correr los scripts **en orden**: `m10_00`, `m10_01` y `m10_02`. En DBeaver, como script completo (`Option + X` en Mac, `Alt + X` en Windows), no sentencia por sentencia.
3. Cada `SELECT` sale en una pestaña de resultados. En los comentarios de los scripts dejé el valor esperado de cada consulta.

## De dónde salen los datos

Son los del Excel del curso (`Pipeline_ETL_Dataset.xlsx`) con la misma limpieza de M6: sin duplicados, precio del producto 109 en 130 y categoría del producto 111 en Computación. Son las mismas 50 ventas (47.578 en total) que `Fact_Ventas` en el modelo de Power BI de M8.

Uso una base nueva y no `Ventas_Tech_DB` porque la tabla `ventas` de esa base no tiene `total_venta` ni `canal`, que son las columnas que usa el boceto del dashboard de M7.

## Diferencias con las consultas de la consigna

La consigna está escrita para PostgreSQL. En SQL Server cambian dos cosas: `PERCENTILE_CONT` necesita `OVER ()` al final y devuelve un valor por fila (por eso uso `SELECT DISTINCT` o una tabla auxiliar), y la desviación estándar muestral se llama `STDEV` en vez de `STDDEV_SAMP`.

## Resultados de referencia

| Qué | Resultado |
|-----|-----------|
| Parte 1 | Norte y Sur tienen media 500. Norte: rango 20, desvío 7,91. Sur: rango 1.150, desvío 518,41. |
| Ticket (2a) | Media 951,56 y mediana 450,00 (50 ventas). |
| Outliers (2b) | Q1 340,50, Q3 1.283,75, IQR 943,25, límites −1.074,38 y 2.698,63. 3 ventas outlier (1030, 1048 y 1021), todas legítimas: 12.240 de 47.578 (25,7 %). |
| Meses (2c) | 3 de los 4 meses con más ventas dependen de una sola venta outlier. |
