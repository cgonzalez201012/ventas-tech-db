# Ventas Tech DB

Proyecto de la carrera de Data Analytics en Coderhouse. Es la base de datos que fui armando a lo largo de los checkpoints de SQL, usando SQL Server (probado con DBeaver y Docker).

## Qué hay en este repo

- `ventas_tech_db.sql` → Checkpoint Módulo 3. Crea la base `Ventas_Tech_DB` con 4 tablas (`categorias`, `clientes`, `productos`, `ventas`), sus relaciones (Foreign Keys) y carga los datos de prueba iniciales.
- `m4_consultas_negocio.sql` → Checkpoint Módulo 4. Son consultas de análisis sobre la tabla `ventas` (resumen mensual, ranking de productos, clientes recurrentes, comparación contra el promedio), pensadas para responder preguntas de negocio a partir de los datos ya cargados en el módulo anterior.

## Modelo de datos

```
categorias (1) ──< productos (1) ──< ventas >── (1) clientes
```

- Una categoría puede tener muchos productos.
- Un producto puede aparecer en muchas ventas.
- Un cliente puede tener muchas ventas.

## Cómo correrlo

1. Tener un motor SQL Server corriendo (yo lo probé con un contenedor Docker + DBeaver).
2. Abrir `ventas_tech_db.sql` primero y ejecutarlo completo (crea la base, las tablas y los datos iniciales). El script es repetible: si la base ya existe, no la vuelve a crear, y si las tablas ya existen las borra y las vuelve a crear antes de cargar los datos.
3. Una vez que la base está creada y cargada, abrir `m4_consultas_negocio.sql` y ejecutarlo sobre la misma base (`Ventas_Tech_DB`) para ver las consultas de análisis.

Ambos scripts están comentados por secciones para que se entienda qué hace cada parte.
