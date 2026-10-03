# Recorrer el MVP — playbook del operador

## Introducción

Este playbook guía al operador en la validación end-to-end del
MVP de Desearch. Acompaña al script `scripts/recorrer-mvp.sh`,
que automatiza los checks determinísticos (presencia de archivos,
permisos, paridad, invocación del script de composición). El
operador ejecuta los pasos conversacionales de cada recorrido
(interacción con los agentes) y los registra en el template
`scripts/recorrer-mvp-informe.md`.

Esta validación **no es** una certificación exhaustiva; **no
corrige** hallazgos; **no agrega** funcionalidades. Integra los
resultados entregados y comprueba que una persona puede recorrer
el MVP de punta a punta. Los hallazgos se derivan al CA
responsable o a un cambio separado.

## Cuándo correr

- Antes de declarar una entrega del MVP lista.
- Después de un cambio relevante que afecte a cualquiera de los
    cinco recorridos cubiertos.
- Cuando se quiera re-ejecutar la validación de composición
    estática (control 7 del script).

No está pensado para correr en cada commit. El script protege
los límites y la composición sin añadir vigilancia continua.

## Cómo correr

1. Ejecutar el script: `bash scripts/recorrer-mvp.sh` (informe
   breve) o `bash scripts/recorrer-mvp.sh --ampliado`
   (detallado). Anotar el resultado por control.
2. Para cada recorrido marcado como `[PENDIENTE]`, abrir el caso
   en `scripts/casos/` y seguir los pasos manuales.
3. Anotar los resultados en `scripts/recorrer-mvp-informe.md`
   siguiendo la estructura del template.
4. Si algún control marca `[FALLO]` o `[BLOQUEADO]`, derivar el
   hallazgo al CA responsable o a un cambio separado.

## Los cinco recorridos

### Recorrido 1 — Instalación limpia

**Objetivo**: verificar que el sistema arranca desde un entorno
limpio siguiendo la experiencia de instalación prevista para
quien lo opera.

**Caso normal**: ver `scripts/casos/instalacion.md`. Caso único
(la instalación es binaria: o el sistema arranca o no).

**Pasos manuales**:

1. Instalar OpenCode CLI si no está disponible (verificar con
   `command -v opencode`).
2. Desde la raíz del repositorio, ejecutar `opencode` para
   iniciar la interfaz.
3. Verificar que el agente `desearch` aparece como disponible.
4. Hacer una consulta de prueba: "saluda y confirma que estás en
   modo investigación".

**Qué observar**: OpenCode arranca sin errores; el agente
Desearch está visible; la consulta de prueba devuelve una
respuesta coherente con el modo investigación (prosa directa,
declaración breve de criticidad).

**Qué anotar en el informe**: comando `opencode --version`
(verificar versión), estado del agente `desearch` (visible/no
visible), resultado de la consulta de prueba.

### Recorrido 2 — Investigación (modo investigación)

**Objetivo**: verificar que el modo investigación del Principal
funciona de punta a punta, incluyendo la escritura del registro
de investigación y el manejo de fuentes inaccesibles.

**Caso normal**: ver `scripts/casos/investigacion.md` (sección
"Caso normal"). Consulta técnica representativa.

**Caso de límite (fuente inaccesible)**: ver
`scripts/casos/investigacion.md` (sección "Caso de límite o
fallo"). URL deliberadamente rota o enlace inexistente.

**Pasos manuales**:

1. Iniciar chat con el Principal Desearch desde OpenCode.
2. Hacer la consulta técnica representativa del caso normal.
3. Verificar que se crea un archivo de registro en
   `resultados/investigaciones/{YYYY-MM-DD}-{slug}.md`.
4. Verificar que el registro tiene las secciones obligatorias
   (Pregunta investigada, Criticidad inferida, Hallazgos,
   Fuentes, Marcas de certeza).
5. Para el caso de límite: introducir una URL rota en una
   consulta de seguimiento y verificar que el Principal
   comunica `fuente inaccesible: <enlace>` en una línea breve
   y que el hallazgo lleva `[Fuente inaccesible]`.
6. Verificar que los contadores se respetan (cap de 8 por turno,
   no acumulación más allá del turno).

**Qué observar**: registro creado con secciones obligatorias;
al menos una fuente citada en el caso normal; marca
`[Fuente inaccesible]` cuando aplica; contadores respetados.

**Qué anotar en el informe**: nombre del archivo de registro
creado, secciones presentes, fuentes citadas, comportamiento
ante fuente inaccesible, contadores observados.

### Recorrido 3 — Modo aprendizaje

**Objetivo**: verificar que la skill `modo-aprendizaje` se activa
solo por pedido explícito, guía hacia una conclusión de
aprendizaje y produce un registro separado del de investigación.

**Caso normal**: ver `scripts/casos/aprendizaje.md` (sección
"Caso normal"). Pedido explícito de aprender sobre un tema con
conclusión de investigación previa disponible.

**Caso de límite (tema sin conclusión previa)**: ver
`scripts/casos/aprendizaje.md` (sección "Caso de límite o
fallo"). Pedido de aprender sobre un tema sin investigación
previa.

**Pasos manuales**:

1. Iniciar chat con el Principal Desearch desde OpenCode.
2. Hacer el pedido explícito del caso normal (ej. "cargame
   sobre el modo investigación de Desearch").
3. Verificar que la skill `modo-aprendizaje` se carga (el
   Principal debe invocar `skill({ name: "modo-aprendizaje" })`).
4. Seguir la guía socrática hasta el cierre de la sesión.
5. Verificar que se crea un archivo en
   `resultados/conclusiones-aprendizaje/{YYYY-MM-DD}-{slug}-aprendizaje.md`.
6. Verificar que el archivo tiene las secciones obligatorias
   (Conclusión de aprendizaje, Comprensión demostrada, Práctica
   de transferencia, Errores o correcciones, Criterio
   transferible, Marcas de certeza).
7. Para el caso de límite: pedir aprender sobre un tema sin
   conclusión previa y verificar que la skill informa "no hay
   conclusión de investigación previa sobre X" sin simular una
   conclusión.

**Qué observar**: skill cargada por equivalencia semántica;
registro separado del de investigación; práctica de
transferencia ejecutada antes del cierre; respuesta breve de
limitación en el caso de límite.

**Qué anotar en el informe**: comportamiento de activación
(equivalencia semántica detectada), nombre del archivo de
aprendizaje creado, secciones presentes, práctica de
transferencia, comportamiento del caso de límite.

### Recorrido 4 — Evaluación de suficiencia (Validador)

**Objetivo**: verificar que el Validador se invoca al cruzar el
umbral cross-turno (5 consultas válidas acumuladas antes de la
sexta) y emite una recomendación cualitativa entre cuatro
opciones.

**Caso normal**: ver `scripts/casos/validador.md` (sección
"Caso normal"). Investigación que acumula 5 consultas válidas.

**Caso de límite (registro insuficiente)**: ver
`scripts/casos/validador.md` (sección "Caso de límite o fallo").
Registro con menos de 3 hallazgos o triviales.

**Pasos manuales**:

1. Iniciar una investigación con el Principal Desearch.
2. Hacer 5 consultas válidas acumuladas en la misma operación.
3. Al intentar la sexta consulta, verificar que el Principal
   solicita evaluación al Validador antes de ejecutar.
4. Observar la recomendación del Validador (continuar /
   suficiencia de exploración / continuar reorientando / no
   evaluable).
5. Verificar que el contador acumulado vuelve a 0 tras la
   invocación.
6. Para el caso de límite: con un registro mínimo, provocar la
   invocación del Validador y verificar que emite "no
   evaluable" con motivo breve.

**Qué observar**: invocación al cruzar el umbral cross-turno;
recomendación presente; contador reseteado; caso de límite
tratado como "no evaluable" sin simular suficiencia.

**Qué anotar en el informe**: número de consultas válidas
antes del disparo, recomendación emitida, comportamiento del
caso de límite.

### Recorrido 5 — Cuestionamiento crítico (Crítico)

**Objetivo**: verificar que el Crítico se invoca ante un
cuestionamiento contra una conclusión de aprendizaje guardada y
emite una de tres resoluciones (mantener / recomendar cambiar /
tensión abierta).

**Caso normal**: ver `scripts/casos/critico.md` (sección "Caso
normal"). Cuestionamiento con trade-off explícito.

**Caso de límite (cuestionamiento inválido)**: ver
`scripts/casos/critico.md` (sección "Caso de límite o fallo").
Insistencia sin razón ("no estoy de acuerdo, cambialo").

**Pasos manuales**:

1. En modo aprendizaje, después de tener una conclusión de
   aprendizaje guardada, plantear el cuestionamiento del caso
   normal (argumento que compara trade-off explícito).
2. Verificar que el Principal invoca al Crítico (subagente de
   solo lectura).
3. Observar la resolución emitida.
4. Si la resolución es "recomendar cambiar", verificar que el
   Principal pide confirmación explícita antes de actualizar el
   archivo de conclusión.
5. Para el caso de límite: plantear el cuestionamiento inválido
   y verificar que el Crítico aplica evaluación inicial,
   reconoce la insistencia como no válida y emite "mantener".

**Qué observar**: invocación del Crítico; resolución binaria
presente; archivo de conclusión no modificado por el Crítico;
insistencia reconocida como no válida en el caso de límite.

**Qué anotar en el informe**: cuestionamiento planteado,
resolución emitida, confirmación de la persona (si aplica),
comportamiento del caso de límite.

## Paridad dev/master

La lógica del script bash es idéntica en cualquier entorno. La
única diferencia entre invocaciones es el nivel de detalle del
informe, controlado por el flag `--ampliado`. El mayor detalle
de diagnóstico no concede capacidades adicionales: el script
nunca relaja un control para "ver mejor" en desarrollo.

## Cómo leer el resultado

- **7 [OK] / [PENDIENTE] + "Recorrido E2E"** → el script pasa;
    el operador completa los pasos manuales y los registra en
    el informe. Si no hay FALLO en los pasos manuales, el MVP
    puede declararse listo.
- **Al menos un [FALLO]** → el recorrido afectado no puede
    completarse; el MVP no se declara listo. Derivar el
    hallazgo al CA responsable o a un cambio separado.
- **Al menos un [BLOQUEADO]** → un recurso imprescindible
    está ausente. Resolver la dependencia pendiente (típicamente
    mergear una CA cerrada) antes de continuar.
- **Exit 2** → uso incorrecto (flag desconocido). No es un
    fallo de control.

## Relación con `verificar-composicion.sh`

El script `verificar-composicion.sh` (entregado anteriormente)
valida la composición estática de los 3 roles (5 controles
sobre archivos declarativos). El script `recorrer-mvp.sh`
valida el recorrido E2E del MVP (5 recorridos manuales + la
invocación del script de composición como control 7). Ambos se
complementan: composición + recorrido = MVP listo.

El control 7 de este script invoca al de composición si el
archivo `scripts/verificar-composicion.sh` existe en master. Si
no existe, este script marca el recorrido como BLOQUEADO por
dependencia pendiente (sin presentarlo como FALLO).

## Cuándo derivar hallazgos

Si un recorrido falla, el operador:

1. Registra el hallazgo en `scripts/recorrer-mvp-informe.md`
   siguiendo la estructura del template (sección "Hallazgos").
2. Deriva el hallazgo al CA responsable (por ejemplo: drift en
   `.opencode/agents/` → composición estática; comportamiento
   inesperado del Principal → comportamiento del Principal).
3. NO corrige el hallazgo dentro de esta validación. La
   corrección y su nueva comprobación pertenecen al CA
   responsable o a un cambio separado.
