# Casos — Modo aprendizaje

## Caso normal

**Input:** pedido explícito de aprender sobre un tema con
conclusión de investigación previa disponible, por ejemplo
"cargame sobre el modo investigación de Desearch".

**Resultado esperado:**

- El Principal detecta la intención de aprendizaje por
  equivalencia semántica (sin requerir coincidencia literal
  con una frase fija) y carga la skill
  `modo-aprendizaje`.
- La sesión se guía con preguntas, pistas, ejemplos y
  correcciones directas hacia la conclusión preparada.
- Al cierre de la sesión, se crea un archivo en
  `resultados/conclusiones-aprendizaje/{YYYY-MM-DD}-{slug}-aprendizaje.md`
  con las secciones obligatorias: Conclusión de aprendizaje,
  Comprensión demostrada por la persona, Práctica de
  transferencia realizada, Errores o correcciones relevantes,
  Criterio transferible a situaciones futuras, Marcas de
  certeza.
- Antes del cierre, se ejecuta una práctica de transferencia
  breve en un caso comparable pero distinto al original.
- El registro de investigación previo queda intacto; los dos
  registros persisten como archivos independientes.

**Criterios de aprobación:**

- [ ] Skill `modo-aprendizaje` cargada por equivalencia
  semántica.
- [ ] Archivo de aprendizaje presente en
  `resultados/conclusiones-aprendizaje/`.
- [ ] Secciones obligatorias presentes en el archivo.
- [ ] Práctica de transferencia ejecutada antes del cierre.
- [ ] Registro de investigación previo intacto.

## Caso de límite o fallo

**Input:** pedir aprender sobre un tema sin conclusión de
investigación previa registrada, por ejemplo "cargame sobre la
técnica X" cuando no existe ninguna investigación previa sobre
X en `resultados/investigaciones/`.

**Resultado esperado:**

- La skill informa en una línea breve: "no hay conclusión de
  investigación previa sobre X; no puedo sostener una
  conclusión de aprendizaje fundada".
- La skill no simula una conclusión fundada.
- La skill no escribe un registro de aprendizaje como si la
  sesión hubiera quedado resuelta.

**Criterios de aprobación:**

- [ ] Respuesta breve explicando la limitación.
- [ ] Ningún archivo de aprendizaje escrito.
- [ ] No se simula una conclusión fundada.
