# Casos — Cuestionamiento crítico (Crítico)

## Caso normal

**Input:** en modo aprendizaje, después de tener una
conclusión de aprendizaje guardada, plantear un cuestionamiento
contra esa conclusión con un argumento que compara trade-off
explícito. Por ejemplo: "creo que tu conclusión sobre el modo
investigación no considera el caso Y donde la consulta
requiere verificación de un hecho externo".

**Resultado esperado:**

- El Principal invoca al Crítico (subagente de solo lectura
  definido en `agentes/critico.md`).
- El Crítico aplica evaluación inicial al cuestionamiento.
- Si el cuestionamiento amerita evaluación extensa, el Crítico
  ejecuta el protocolo de 5 pasos (extracción de estructura,
  clasificación del caso, defensa previa del contraargumento,
  resolución, registro).
- El Crítico emite exactamente una de tres resoluciones:
  mantener la conclusión, recomendar cambiar, o declarar
  tensión abierta.
- Si la resolución es "recomendar cambiar", el Principal
  solicita confirmación explícita de la persona antes de
  actualizar el archivo de conclusión; el Crítico solo
  recomienda, no modifica.
- El Crítico no ejecuta búsquedas, no escribe archivos y no
  modifica conclusiones por cuenta propia.

**Criterios de aprobación:**

- [ ] Crítico invocado.
- [ ] Evaluación inicial aplicada.
- [ ] Resolución binaria presente entre las tres opciones.
- [ ] Si recomienda cambiar, se solicitó confirmación de la
  persona antes de modificar el archivo.
- [ ] El Crítico no modificó el archivo por su cuenta.

## Caso de límite o fallo

**Input:** cuestionar con insistencia sin razón, por ejemplo
"no estoy de acuerdo, cambialo" (sin argumento ni trade-off).

**Resultado esperado:**

- El Crítico aplica evaluación inicial.
- El Crítico reconoce que "la insistencia, por sí sola, no es
  razón válida para cambiar".
- El Crítico emite la resolución "mantener" con motivo breve.

**Criterios de aprobación:**

- [ ] Evaluación inicial ejecutada.
- [ ] Insistencia reconocida como no válida.
- [ ] Resolución "mantener" emitida con motivo breve.
