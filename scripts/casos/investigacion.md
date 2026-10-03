# Casos — Investigación

## Caso normal

**Input:** consulta técnica representativa, por ejemplo
"¿cómo funciona el caching en LLMs?" (caso mencionado en la
sección 2 del documento de diseño consolidado).

**Resultado esperado:**

- Respuesta del Principal en prosa directa, sobria y
  proporcional a la criticidad.
- Registro creado en
  `resultados/investigaciones/{YYYY-MM-DD}-{slug}.md` con las
  secciones obligatorias: Pregunta investigada, Criticidad
  inferida, Hallazgos, Fuentes, Marcas de certeza.
- Al menos una fuente citada y verificada.
- Contadores respetados (cap de 8 búsquedas por turno, no
  acumulación más allá del turno).

**Criterios de aprobación:**

- [ ] Archivo de registro presente en `resultados/investigaciones/`.
- [ ] Secciones obligatorias presentes en el registro.
- [ ] Al menos una fuente citada en el registro.
- [ ] Marcas de certeza presentes cuando aplica
  (`[Inferencia]`, `[Especulación]`, `[No verificado]`).
- [ ] Contadores respetados (≤ 8 búsquedas por turno).

## Caso de límite o fallo

**Input:** incluir una URL deliberadamente rota en una
consulta de seguimiento o solicitar verificación de un enlace
inexistente, por ejemplo "verifica este enlace:
https://ejemplo.invalido/articulo-inexistente".

**Resultado esperado:**

- El Principal comunica `fuente inaccesible: <enlace>` en una
  línea breve de la respuesta conversacional.
- El hallazgo correspondiente en el registro lleva la marca
  `[Fuente inaccesible]`.
- Si la fuente era central para la conclusión, la conclusión
  final incluye la salvedad explícita.
- La operación no aborta; puede continuar con otras fuentes.

**Criterios de aprobación:**

- [ ] Marca `[Fuente inaccesible]` presente en el registro.
- [ ] Respuesta incluye `fuente inaccesible: <enlace>` en una
  línea breve.
- [ ] La operación no se aborta.
- [ ] Si la fuente era central, la conclusión incluye salvedad
  explícita.
