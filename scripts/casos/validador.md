# Casos — Evaluación de suficiencia (Validador)

## Caso normal

**Input:** iniciar una investigación con el Principal y hacer
5 consultas válidas acumuladas en la misma operación. Al
intentar la sexta consulta, el sistema debe solicitar
evaluación al Validador antes de ejecutarla.

**Resultado esperado:**

- El Principal invoca al Validador al cruzar el umbral
  cross-turno (5 consultas válidas acumuladas antes de iniciar
  la sexta).
- El Validador emite una de cuatro recomendaciones:
  continuar, suficiencia de exploración, continuar
  reorientando, o no evaluable.
- El contador acumulado del Validador vuelve a 0 tras la
  invocación real.
- La recomendación del Validador es orientativa; la persona
  conserva la decisión de continuar o cerrar la investigación.

**Criterios de aprobación:**

- [ ] Validador invocado al cruzar el umbral cross-turno.
- [ ] Recomendación presente entre las cuatro opciones.
- [ ] Contador acumulado reseteado a 0 tras la invocación.

## Caso de límite o fallo

**Input:** investigación con un registro mínimo (menos de 3
hallazgos triviales o registro incoherente) que dispara la
invocación del Validador.

**Resultado esperado:**

- El Validador emite "no evaluable" con motivo breve.
- El Validador declara la limitación sin simular una señal de
  suficiencia.
- El Validador no ejecuta búsquedas ni escribe archivos.

**Criterios de aprobación:**

- [ ] Recomendación "no evaluable" emitida.
- [ ] Motivo breve presente en la respuesta.
- [ ] No se simula señal de suficiencia.
