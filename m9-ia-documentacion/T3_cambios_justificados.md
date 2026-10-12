# T3 · Cambios que le hice al README generado por la IA

Le pasé a la IA los 4 scripts SQL y le pedí el README del repositorio. Lo leí afirmación por afirmación contra el repo y contra mi entorno. Las cifras, las tablas y los tipos de datos estaban bien: los verifiqué contra los scripts. Lo que cambié es lo que la IA no podía saber de mi entorno o de mis carpetas M6 y M8.

## Cambios en el README

| # | Qué cambié | Por qué (hecho de mi proyecto) |
|---|------------|--------------------------------|
| 1 | Atajos de DBeaver: puse `Option + X` y `Cmd + Enter` (Mac), además de los de Windows. Agregué cómo revisar que el script tenga conexión asignada. | La IA puso `Alt + X` y `Ctrl + Enter`, que son de Windows, y yo trabajo en Mac. Además, al correr los scripts DBeaver me mostró el error *No active connection* porque el archivo abierto no tenía conexión (el selector decía `N/A`). |
| 2 | Conexión real: SQL Server 2022 en Docker (contenedor `sql-coderhouse`, puerto 1401, usuario `sa`). Corregí los comandos de `sqlcmd` y dejé la contraseña afuera. | La IA proponía `sqlcmd -S localhost -E`: la opción `-E` es autenticación de Windows y mi servidor es un contenedor Linux. Además usaba el puerto por defecto y mi contenedor usa el 1401. El repo es público, por eso no va la contraseña. |
| 3 | Aclaré que Power BI (M6 y M8) parte del Excel del curso y no de SQL Server. Agregué Excel, Power Query y Docker a las herramientas. | La IA repitió el comentario de mi M5 ("la tabla principal que después uso en Power BI"), pero en la práctica `Fact_Ventas` tiene 50 filas del Excel y mi base SQL tiene 20 ventas. |
| 4 | Descripción real de M6 y M8, y el nombre de la empresa (TechStore). | La IA no vio esas carpetas y las describió de forma genérica. Usé lo que dicen sus propios README: 4 consultas limpias en M6, y 4 relaciones 1:N, `Dim_Fechas` y 5 medidas en M8. |
| 5 | Límites de los datos: marzo es la carga inicial (5 al 15), junio llega hasta el 14/06 y cada cliente tiene 4 ventas en 4 fechas distintas. | Lo verifiqué con consultas en DBeaver. La IA ya decía que marzo concentra el 56 % por la carga original, pero no mencionaba que junio llega solo hasta el 14/06 ni el patrón de 4 ventas por cliente. |
| 6 | Datos de Sofia Medina (registrada el 2024-02-10) y de la Webcam HD Pro (activa, precio 85, stock 10) en la tabla de datos cargados. | Los confirmé con consultas a `clientes` y `productos`. |
| 7 | Sección "Sobre el uso de IA en este README", referencia a la Entrega 9 y marcadores `<URL-del-repositorio>` reemplazados por la URL real. | Dejar claro qué partió de la IA y qué corregí yo, y que el repo apunte a esta carpeta. Los marcadores no tenían sentido en un README ya publicado. |

## Cambios en los scripts

| Archivo | Qué cambié | Por qué |
|---------|------------|---------|
| `ventas_tech_db.sql` | El comentario de la línea 171 decía "deberia dar 4, 5, 6 y 10" y ahora dice "4, 6, 7 y 10". | **Esto lo detectó la IA y lo verifiqué yo:** después de agregar a Sofia Medina y la Webcam HD Pro, las tablas tienen 4 categorías, 6 clientes, 7 productos y 10 ventas. |
| `m4_consultas_negocio.sql` | Reescribí el hallazgo 2. | Decía que "la totalidad de la cartera de clientes es recurrente" y que había "buena tasa de retención". Pero la base tiene 6 clientes, Sofia nunca compró, y que los 5 restantes tengan exactamente 4 compras parece un patrón de los datos de ejemplo. |

## Lo que la IA hizo bien y dejé como estaba

- Todas las cifras de referencia: resumen mensual, Top 5, resultados de M5 (8.396 y 3.015) y los conteos 4 / 6 / 7 / 10 y 20.
- La definición de las 4 tablas (tipos, `NOT NULL`, claves) y el diagrama del modelo.
- El orden de ejecución de los scripts y la advertencia de que `ventas_tech_db.sql` borra y recrea las tablas.
- Fue honesta sobre lo que no pudo probar (`sqlcmd`) y lo que no vio (las carpetas M6 y M8).
