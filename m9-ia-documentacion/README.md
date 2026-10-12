# M9 · Uso de IA para documentar y optimizar el análisis

En este módulo usé IA (Claude, en chats nuevos) como copiloto sobre el proyecto que ya tenía armado, y revisé cada respuesta contra mis datos reales antes de aceptarla. Acá queda lo que corresponde al repositorio. El análisis completo de las 4 tareas (prompts, respuestas de la IA y mi evaluación) va en el documento de la entrega.

| Archivo | Qué es |
|---------|--------|
| [`T3_readme_version_IA.md`](T3_readme_version_IA.md) | El README del repositorio tal como lo generó la IA, **sin modificar**. |
| [`T3_cambios_justificados.md`](T3_cambios_justificados.md) | Los cambios que le hice y por qué. El resultado es el [`README.md`](../README.md) de la raíz. |

## Qué hice en cada tarea

- **T1 · Optimización SQL.** Le pedí a la IA que revisara la consulta base de M5 (el `INNER JOIN` de 4 tablas). Comprobé en DBeaver que su versión mejorada devuelve lo mismo que mi consulta: 20 filas y un total de 11.411.
- **T2 · Insights.** Le pasé los resultados de las consultas de M4 y le pedí los 3 hallazgos más importantes para el equipo comercial. Verifiqué sus cifras contra la base: estaban bien, pero encontré conclusiones que no se sostenían. Por ejemplo, tomó marzo (la carga inicial de datos) como un pico comercial, y junio como un mes completo cuando los datos llegan solo hasta el 14/06. Los límites de los datos que salieron de esta revisión quedaron anotados en el README principal y en los comentarios de `m4_consultas_negocio.sql`.
- **T3 · README.** Está en esta carpeta: la versión de la IA y mis cambios.
- **T4 · Reflexión.** Va en el documento de la entrega.
