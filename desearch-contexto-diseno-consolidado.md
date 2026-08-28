# Desearch — Contexto de diseño consolidado (18 ago 2026)

Nota de uso: documento para reconstrucción de contexto de Claude, no para lectura humana lineal. Denso, no narrativo. Consolida las 4 sesiones de diseño en un solo archivo. Los archivos originales (v1, v2, v3) NO se eliminan — quedan como registro histórico crudo; este archivo es la fuente única de verdad hacia adelante.

## Historial de sesiones

- **Sesión 1** (16 ago 2026) — `research-agent-contexto-diseno.md`: scope, dos modos, protocolo de cuestionamiento (5 pasos), pivote a multi-subagente, diferidos (Engram, v2-del-sistema).
- **Sesión 2** (17 ago 2026) — `research-agent-contexto-diseno-v2.md`: mecanismos de stop (self-reflection, diminishing returns, cap de 8), 2 subagentes (Principal + Crítico/Validador fusionado).
- **Sesión 3** (17 ago 2026, misma fecha, continuación directa) — `research-agent-contexto-diseno-v3.md`: reapertura a 3 subagentes, único ejecutor/escritor, cascada DR, carryover cross-turno, criticidad de dominio.
- **Sesión 4** (18 ago 2026, esta conversación): frontmatter reclasificado a construcción, trigger del Crítico confirmado, Reality Filter mapeado por funcionalidad, personalidad por modo definida, nombre confirmado (Desearch), estructura de build en 6 sesiones, cierre de diseño y paso a construcción.

---

## 1. Objetivo y scope

Agente/sistema de investigación técnica, separado de FlowTask, para research NO ligado a un proyecto específico.

**Separación por scope, no por función** (sesión 1): research general sin proyecto → proyecto nuevo, carpeta propia, instalable independiente. Research ligado a proyecto → fuera de scope de este sistema, se resuelve a futuro como evolución de FlowTask Inspector (Evolution Mode, ya lee `.flowtask/`). Razonamiento original: el usuario había generalizado desde el caso más restrictivo (bug-diagnosis, necesita contexto de proyecto) al sistema completo sin justificarlo — se corrigió separando ejes.

## 2. Casos de uso

Mencionados en sesión 1 (no exhaustivos en su momento): cómo funciona cache en LLMs / cache para agentes, cómo se implementan RAGs, cómo está diseñada una funcionalidad X de un proyecto opensource, verificar si un problema ya está resuelto externamente por otro proyecto opensource.

**Exclusión explícita (sesión 2):** diagnóstico de bugs por incompatibilidad de dependencias queda **fuera de scope**. Estaba mencionado en sesión 1 como caso de uso, pero el usuario aclaró en sesión 2 que ningún mecanismo del sistema fue diseñado pensando en ese caso — no asumir que los mecanismos de stop/criticidad lo cubren.

## 3. Bases usadas como precedente

- `inspector.md` — FlowTask Inspector, subagente real en producción. Fuente de: estructura de frontmatter, patrón Reality Filter (sección aparte + incrustado), matriz de Tradeoffs/GAPs por modo de salida, CheckpointMixin/Engram (mem_search, mem_save, cp_save, cp_delete — no reusado aún, ver diferido de memoria).
- Prompt "tutor crítico" (proyecto "aprendizaje dev") — fuente de la personalidad y mecanismos del modo aprendizaje.

## 4. Modos de operación

- **Investigación** (default): directo, sin fricción socrática, sin forzar predicción/razonamiento previo del usuario.
- **Aprendizaje** (explícito, sesión 4: **solo cuando el usuario lo pide explícitamente — nunca asumido, nunca ofrecido de forma proactiva**): guía socrática hacia una conclusión que el agente ya diseñó y escribió de antemano en un archivo.

### Origen del mecanismo (diagnóstico de falla previa, sesión 1)

Usuario reportó fallas recurrentes en sesiones de modo-tutor previas: "te vas por las ramas y damos vueltas para llegar al mismo punto". Se caracterizó entre dos hipótesis: (a) agente sin conclusión/objetivo predefinido → preguntas guía divergían sin destino; (b) agente reconocía avance parcial mal/tarde. **Usuario confirmó: es (a).** (b) NO fue el problema, no asumir que el reconocimiento de progreso estaba roto.

### Creación del archivo de conclusión (sesión 4, aclaración nueva)

El agente **crea el archivo de conclusión predefinida solo cuando el usuario pide explícitamente "cargarse"** (activación del modo aprendizaje). Fuera de ese pedido, el Principal solo crea el archivo de investigación (denso), que escribe siempre, en todo momento, independiente del modo.

## 5. Principio rector para actualizar la conclusión pre-escrita (sesión 1)

Dos interpretaciones evaluadas sobre qué pasa cuando el usuario cuestiona la conclusión guardada:
- (A) el usuario se desvía/diverge → NO debe cambiar la conclusión (misma falla "irse por las ramas", aplicada al agente).
- (B) el usuario cuestiona con criterio válido, comparando trade-off explícito → el agente debe investigar/analizar si aplica, no aceptar ni rechazar por defecto.

**Usuario confirmó: B es el caso relevante** (A sigue válido como principio separado, no se descarta).

**Principio final:** el análisis del agente es su fuente de verdad / punto de partida, modificable con criterio — nunca cambia solo porque el usuario insiste sin razón nueva.

## 6. Protocolo de cuestionamiento — texto completo (sesión 1, ejecutado por el Crítico)

```
PASO 1 — Extraer estructura del argumento del usuario (no reaccionar aún)
  - Claim: qué propone como alternativa
  - Razón: por qué dice que es mejor
  - Tipo de razón: [empírica] | [lógica/costo-beneficio] | [experiencia previa del usuario]

PASO 2 — Clasificar cómo se resuelve
  a) [Verificable por búsqueda] → hecho externo objetivo, resolver con ferris-search
  b) [Verificable por razonamiento] → comparación de trade-offs con los MISMOS
     criterios del análisis original (no inventar criterios nuevos ad-hoc)
  c) [Juicio sin resolución objetiva] → trade-off de diseño sin verdad única

PASO 3 — Generar el contraargumento ANTES de decidir (mitigación de sesgo)
  El agente debe escribir explícitamente la mejor defensa de SU conclusión
  original contra el punto del usuario, independiente de si luego la cambia.
  Si no puede generar una defensa con sustancia, es señal de que la
  conclusión original era débil.

PASO 4 — Resolver según el caso
  (a) → buscar, comparar, actualizar si la fuente contradice
  (b) → razonar con los criterios del análisis original
  (c) → NO forzar resolución; marcar como [Especulación] abierta en el
        archivo, con ambas posturas y sus razones — no fingir certeza

PASO 5 — Registrar el cambio (o no-cambio) con razón explícita
  "Conclusión original: X (razón). Cuestionamiento: Z (razón).
   Resolución: [actualiza a Z | mantiene X | tensión abierta]. Por qué: ..."
```

**Fundamento del Paso 3:** patrón Producer-Critic (reflection) — un mismo modelo que genera y evalúa su propio output tiende a sesgarse. Para un agente único, el proxy es forzar la generación explícita del contraargumento antes de decidir. En sesión 3 esto se resuelve arquitectónicamente: el Crítico es un subagente separado del Principal, no solo un paso dentro del mismo contexto.

**Fundamento del Paso 2 (reasonableness > truth):** la métrica no es verdad absoluta, es razonabilidad del argumento.

**Fundamento de la regla anti-complacencia:** estudio de debate multiagente — la presión de mayoría/insistencia suprime la corrección independiente; el razonamiento válido (no la insistencia) predice mejor la mejora del resultado.

### Delegación de búsqueda dentro del protocolo (sesión 3)

Si el caso (a) requiere una búsqueda puntual para verificar, **la ejecuta el Principal, no el Crítico**. El Crítico nunca ejecuta búsquedas, en ningún caso.

## 7. Mecanismos de "cuándo parar de investigar" (sesión 2, reforzado en sesión 3)

Eje distinto de scope-creep. Scope-creep = dirección incorrecta. Este eje = profundidad excesiva en la dirección correcta. Requisito: el agente puede sugerir parar, pero nunca es hard-stop — el usuario decide seguir si quiere.

### Mecanismos adoptados

1. **Self-Reflection**: preguntarle explícitamente al agente si el contexto actual alcanza para actuar (confirma la idea "¿puedo escribir el plan ya?" de sesión 1).
2. **Diminishing returns (DR)** — el mecanismo que más aporta según el usuario. Cascada resuelta en sesión 3 (ver sección 7bis).
3. **Cap de búsquedas por turno, con decaimiento gobernado por DR** — diseño propio del usuario, [Especulación del usuario, no encontrado en fuentes externas]. El decaimiento NO es por calendario fijo de turno, es emergente de la señal real de DR. Número de partida: **8 búsquedas máximo por turno** [a ajustar empíricamente, no viene de benchmark], inspirado (no basado) en el tope de 5 de LangChain para research single-shot — unidades no equivalentes (single-shot vs. multi-turno), es ancla de orden de magnitud, no equivalencia validada.
4. **Confianza calibrada por criticidad de dominio** — ver sección 9.

### Mecanismos descartados explícitamente (no reconsiderar sin razón nueva)

- **Política de stopping aprendida vía RL (Stop-RAG)**: requiere datos de entrenamiento y trayectorias offline, no aplica a un subagente que llama a un modelo por API.
- **Señal de suficiencia vía activaciones internas del modelo (attention heads)**: requiere acceso a internals del modelo, no disponible por API.

### Advertencia con impacto arquitectónico (RGAR paper, citando Kumar et al. 2024)

La auto-evaluación de un modelo sobre si necesita más retrieval frecuentemente NO coincide con la necesidad real. Consecuencia directa: el chequeo de suficiencia no debe vivir como auto-chequeo del agente que busca — debe vivir en un subagente separado (Validador).

## 7bis. Cascada de señales DR (sesión 3, resuelve las 3 formalizaciones sin elegir de sesión 2)

Las 3 formalizaciones de sesión 2 —(a) dato nuevo por búsqueda bajo umbral, (b) alta similitud entre búsquedas sucesivas, (c) volumen de info nueva deja de crecer— no son independientes:

- **(a) por-búsqueda**: señal primaria, evaluada en cada búsqueda desde que se dispara el Validador.
- **(c) = lectura de tendencia de la serie de (a)**: confirmación pasiva, no un chequeo aparte, se deriva de trackear (a) en serie.
- **(b) similitud entre búsquedas sucesivas**: única señal genuinamente distinta (mide redundancia de contenido, no cantidad) — usada como desempate cuando (a) es ambiguo.

Pendiente de implementación (nivel construcción, no diseño): umbral concreto de (a) y qué constituye "alta similitud" en (b).

## 8. Arquitectura de subagentes — evolución completa

### Debate inicial (sesión 1)

Dos razones para pivotar de agente único a multi-subagente: (1) precedente interno de FlowTask validator (separar rol mitiga sesgo de auto-revisión, más robusto que el Paso 3 del protocolo dentro del mismo contexto); (2) mitigar saturación de contexto delegando análisis a subagente separado. Advertencia de fuente: más subagentes = más costo de orquestación, no gratis (Medium, Patterns for Democratic Multi-Agent AI).

### Sesión 2 — cierre inicial en 2 subagentes

Propuesta de Claude: 2 subagentes — Principal (Investigador) + Crítico/Validador fusionado (comparten causa raíz de sesgo: auto-evaluación, y misma mitigación: separar rol). Contraargumento generado contra la propia propuesta: la razón real para separar en 3 sería frecuencia de invocación (chequeo de suficiencia se dispara muy seguido, protocolo de cuestionamiento es raro) — pero esto no justifica por sí solo agentes con nombres/roles distintos, salvo necesidad de paralelismo o context windows separadas (no identificada en sesión 2). **Usuario confirmó 2 subagentes en sesión 2.**

### Sesión 3 — reapertura a 3 subagentes (contradice explícitamente sesión 2, con razón NUEVA)

Razón distinta a la ya descartada en sesión 2 (frecuencia de invocación): **modo distinto + fuente de información distinta** para cada función. El Crítico opera sobre el archivo de conclusión (modo aprendizaje); el Validador opera sobre resultados de búsqueda en serie (ligado a existencia de serie, no a modo). **Confirmado: 3 subagentes, decisión vigente.**

### Estructura final (sesión 3, con aclaración de trigger en sesión 4)

1. **Principal (Investigador)**: conversa con el usuario; **ejecuta TODAS las búsquedas del sistema, sin excepción, nunca delega ejecución**; cuenta el cap de 8 (soft, es un contador, no un juicio, no necesita separación de rol); decide modo investigación/aprendizaje; **es el único escritor del archivo del sistema, en ambos modos** (denso en investigación — siempre — de conclusión en aprendizaje — solo si el usuario pide "cargarse", sesión 4); actualiza el archivo de conclusión tras resolución del Crítico (Paso 5); infiere criticidad de dominio y la declara inline sin bloquear.
2. **Validador de suficiencia (DR)**: **nunca ejecuta búsquedas, nunca escribe archivo — solo lee y evalúa**. Fuente única: el archivo que escribió el Principal (stateless, sin handshake, se invoca en frío cada vez). Disparador: contador de búsquedas acumulado cross-turno llega a 6+ (ver sección 10). Doble salida: (a) señal advisory de stop del turno actual (nunca hard-stop), (b) número sugerido de búsquedas para el turno siguiente (carryover). Agnóstico de modo — se invoca igual si la serie ocurre en investigación o dentro del caso (a) del protocolo del Crítico en aprendizaje, si escala a serie real.
3. **Crítico de cuestionamiento**: protocolo de 5 pasos (sección 6), ancla en archivo de conclusión. **Trigger (sesión 4, confirmado): evento — se dispara cuando el usuario empuja contra la conclusión guardada, exclusivamente en modo aprendizaje** (no existe archivo de conclusión en investigación, no hay contra qué operar). No es un contador ni umbral tipo Validador — es binario: usuario cuestiona o no. Si el caso (a) del protocolo requiere búsqueda puntual, la ejecuta el Principal, nunca el Crítico.

### Único ejecutor y único escritor (sesión 3, cierra ambigüedad de una sugerencia intermedia descartada)

Se había sugerido que el Validador ejecutara las búsquedas 6-7 — **descartado**. El Principal ejecuta todas las búsquedas del sistema, sin excepción, en ambos modos. Ni Validador ni Crítico ejecutan nada ni escriben nada. Elimina todo punto de handoff de resultados crudos entre subagentes — un solo ejecutor, un solo escritor, cero transferencia de información cruda entre subagentes. Razón: evita pérdida de información en el traspaso (objeción del usuario a la alternativa).

## 9. Criticidad de dominio (sesión 3)

Niveles, anclados en consecuencia downstream de la conclusión (no en el tema del research):

- **Alto**: informa directamente una decisión de implementación real → exige múltiples fuentes concordantes, `[No verificado]` agresivo ante desacuerdo entre fuentes.
- **Medio**: uso conceptual sin decisión inmediata atada → una fuente sólida alcanza, cross-check opcional.
- **Bajo**: curiosidad o modo aprendizaje sin acción inminente → prioriza velocidad sobre rigor de fuentes.

**Quién asigna**: el Principal infiere el nivel por defecto a partir del fraseo de la pregunta, lo declara inline breve al arrancar (ej. "asumo nivel medio") sin bloquear ni exigir respuesta. El usuario corrige solo si está mal. Punto intermedio elegido explícitamente entre "puramente automático sin declarar" y "preguntar siempre" (descartado por reintroducir fricción en un modo diseñado para no tenerla).

## 10. Presupuesto de búsquedas entre turnos (carryover) y acumulación cross-turno (sesión 3)

**Problema:** si el cap de 8 resetea igual cada turno sin memoria del anterior, el "decaimiento progresivo" (mecanismo #3, sección 7) no tiene forma de manifestarse — sería descriptivo, no funcional.

**Resuelto:** el Validador, en su invocación (disparada al cruzar el umbral), calcula y devuelve también el número sugerido de búsquedas para el turno siguiente, no solo la señal de stop. Mantiene el análisis fuera del Principal (razón original de separarlos).

**Qué pasa si el turno actual no llega a 6 búsquedas — 3 opciones evaluadas:**
- (A) umbral único en 6, sin fallback — dejaba hueco.
- (B) doble umbral (2+ carryover, 6+ stop) — descartada, segunda condición innecesaria, carryover ruidoso con pocos datos.
- (C) A + fallback "hereda último carryover real" — cerraba el hueco pero dejaba carryover desactualizado en tramos de turnos cortos seguidos.
- **(D) elegida** — el contador que dispara al Validador deja de resetearse por turno y **se acumula cross-turno hasta juntar 6**, sin importar cuántos turnos tome.

**Dos contadores distintos, no confundir:**
- **Cap de ejecución (8)**: estrictamente por turno, sin cambios — limita cuánto ejecuta el Principal dentro de un turno dado.
- **Contador de disparo del Validador (umbral 6)**: acumulado cross-turno. Ejemplo: turno 1 con 3 búsquedas (acumulado 3, no dispara), turno 2 con 2 más (acumulado 5, no dispara), turno 3 con 2 más (acumulado 7, cruza 6 → se invoca al Validador con las 7 acumuladas).

**El Validador es agnóstico de este mecanismo** — no necesita saber que el acumulado viene de varios turnos, evalúa igual.

**Reset del contador acumulado:** tras cada invocación REAL del Validador, vuelve a 0 y empieza a acumular de nuevo. Se descartó ventana deslizante por complejidad sin necesidad identificada.

**Turnos cortos sin dato fresco:** asumido como comportamiento esperado del mecanismo, no como vacío de diseño — es la lectura correcta de "aún no hay suficiente información para juzgar suficiencia".

**Nota de scope-creep:** si turnos distintos acumulados tocan subtemas distintos (pivote legítimo dentro del scope), no rompe la lógica de DR — se lee como dato novedoso, no como falsa señal de agotamiento.

## 11. Reality Filter incrustado — mapeo por funcionalidad (sesión 4)

Inspector confirma con evidencia directa (revisado en sesión 4) el patrón ya descrito en sesión 1: RF en dos capas — sección aparte (tabla central/periférico-barato/periférico-caro/output-propio + degradación) Y RF incrustado en el flujo (rol: mención directa de etiquetar hallazgos; Paso 2: "busca en Engram primero, obligatorio"; Paso 4 + Restricciones: "no inventes Tradeoffs o GAPs", repetido dos veces).

Mapeo para Desearch, por funcionalidad:

| Funcionalidad | Estado | Etiquetas/mecanismo |
|---|---|---|
| **Crítico — protocolo de cuestionamiento (Pasos 2-4)** | Ya resuelto en sesión 1, es RF incrustado con nombre distinto | `[Especulación]` para caso (c); búsqueda real para caso (a); sin etiqueta para (b), se resuelve con criterios ya declarados |
| **Principal — ejecución de ferris-search** | Borrador sesión 4, hereda tabla de Inspector con eje "caro" redefinido en sesión 1 (caro = scope-creep, no costo de tokens) | Central → verificar siempre. Periférico + dentro de scope → verificar. Periférico + fuera de scope → `[No verificado]`, no perseguir. Síntesis propia del Principal → sin etiqueta (output propio) |
| **Principal — escritura del archivo (denso y de conclusión)** | Borrador sesión 4, analogía directa con "no inventes Tradeoffs o GAPs" de Inspector → "no inventes conclusiones que las fuentes no sostienen" | `[Inferencia]` = conexión razonada entre fuentes no dicha literalmente por ninguna. `[Especulación]` = plausible sin apoyo de evidencia actual. `[No verificado]` = claim descartado por scope-creep. Sin etiqueta = hecho con fuente citada |
| **Validador — señal de stop + carryover** | [Especulación mía, sin precedente directo en ningún archivo previo — la celda más floja de este mapeo, sujeta a revisión] | La propia salida del Validador se trata como heurística/advisory, no como hecho — el Principal la recibe como sugerencia, nunca como orden (consistente con "nunca hard-stop" ya definido en sesión 3, nunca antes conectado explícitamente con RF) |
| **Analogía "Engram primero" (Paso 2 Inspector)** | No mapeable todavía | Depende de memoria Engram, diferida (sección 13) |

## 12. Personalidad por modo (sesión 4, ítem nuevo, nunca estuvo en ningún checklist previo)

### Investigación — basada en Inspector

Inspector no declara tono explícito, se infiere de reglas funcionales dispersas:
- Respuesta directa siempre primero, sin preámbulo.
- Cero relleno: nunca secciones vacías ni "no se detectaron GAPs".
- Verbosidad proporcional a materialidad — mismo principio que el eje de criticidad (sección 9).
- Nunca asume que el usuario quiere actuar sobre lo investigado — espera confirmación antes del siguiente paso.
- [Inferencia mía]: tono "sobrio, sin lenguaje emocional" no está declarado como regla explícita, se deduce de la ausencia total de ese registro en Inspector.

**Traducción para Desearch, modo investigación:** sobrio, sin relleno, respuesta antes que proceso, sin pedir permiso para investigar (coincide con "sin fricción socrática" de sección 4).

### Aprendizaje — basada en el prompt "tutor crítico"

Menos que adaptar: buena parte del prompt ya es genérico (detección de uso pasivo, detección de búsqueda de validación, Reality Filter, modo "pr") — coincide casi calco con las reglas de interacción del propio usuario en estas sesiones de diseño, hereda solo.

**Tensión real que sí requiere reconciliación** — dos protocolos de 5 pasos, fácil confundirlos:

| | Protocolo del tutor (genérico) | Protocolo del Crítico (sección 6) |
|---|---|---|
| Cuándo se dispara | Cualquier consulta de aprendizaje, desde el inicio | Solo cuando el usuario empuja contra la conclusión ya escrita |
| Qué hace | Diagnóstico → mapear problema → elegir profundidad → forzar procesamiento activo → verificar | Extraer estructura del argumento → clasificar a/b/c → generar contraargumento → resolver → registrar |
| Rol | Guía toda la sesión de principio a fin | Se activa puntualmente dentro de una sesión con conclusión-objetivo ya predefinida |

**Resolución de la tensión:** el tutor asume que la sesión arranca sin conclusión predefinida (diagnóstico → mapear → construir). Desearch en modo aprendizaje arranca al revés — la conclusión ya existe antes de empezar, específicamente para evitar el fallo diagnosticado en sección 4 ("agente sin conclusión predefinida → preguntas divergían sin destino"). Usar el protocolo genérico del tutor tal cual reintroduciría ese fallo ya descartado.

**Lo que sí traslada:** técnicas puntuales del tutor (worked examples con fading, self-explanation, error analysis, transfer practice, comparative analysis, retrieval practice, formative feedback, metacognición) como *herramientas* dentro de la guía hacia la conclusión ya escrita — no como el flujo que decide hacia dónde ir.

**Lo que probablemente NO traslada** [Inferencia mía, marcado para confirmar en construcción]: la sección "Reglas para desarrollo de software y arquitectura" del prompt tutor (equipo de 4 devs/2 practicantes, decisiones de liderazgo técnico) — se lee como contexto específico de otro proyecto del usuario, no genérico a Desearch.

## 13. Archivo denso — draft de formato (ABIERTO, nivel diseño, explícitamente pendiente)

Contenido y escritor: **cerrado** (Principal, único escritor, ver sección 8). Momento de escritura: al menos al final de cada turno, necesariamente antes de invocar al Validador (que lee stateless, sin recibir nada por prompt). Granularidad más fina (tras cada búsqueda individual) no evaluada como necesaria, tampoco descartada formalmente.

**Formato interno (estructura del contenido denso, cómo conviven ahí las referencias de búsqueda con la marca inline de ClipLab) — marcado explícitamente por el usuario como pendiente de nivel DISEÑO, no de construcción.** Distinto del formato/contenido exacto de la marca inline de ClipLab en sí, que sí se clasificó como construcción (no bloquea diseño). El usuario decidió terminar de definir esto durante la fase de construcción, no en esta sesión — dejar como placeholder en el archivo de acciones, sin bloquear el arranque del build.

## 14. Frontmatter (sesión 4 — reclasificado)

Contenía las decisiones sustantivas (quién es cada agente, qué tools tiene cada uno) que ya estaban resueltas en sección 8. El acto de escribir el YAML (`name`, `description`, `mode`, `permission`, `tools`) con esos valores ya decididos es traducción directa, no decisión nueva. **Reclasificado de "diseño abierto" a "construcción"** en sesión 4 — no es un pendiente de diseño, se ejecuta en la Sesión 5 del archivo de acciones.

## 15. Diferido — Memoria persistente Engram

El sistema tendrá memoria propia en Engram, posiblemente reusando o adaptando skills que ya usa FlowTask (memory-protocol, checkpoint-mixin — patrones mem_search/mem_save/cp_save/cp_delete de Inspector). Objetivo doble: (1) mitigar saturación de contexto entre pasos/subagentes, (2) permitir que Desearch acceda a lo que hayan guardado agentes distintos en sesiones anteriores (continuidad cross-session, cross-agent).

**Diferido explícitamente por el usuario** desde sesión 1, reafirmado en sesión 3 — no desarrollar hasta fase de construcción, solo tenerlo en cuenta en el diseño general.

## 16. Diferido — Versión 2 del proyecto (analítica de patrones de usuario)

Guardar los casos donde el usuario cuestiona/corrige al agente con criterio válido (casos "B" del protocolo, sección 6) como feedback histórico, para — a futuro, con volumen suficiente y mecanismo de extracción de patrones — encontrar patrones de pensamiento/razonamiento propios del usuario. Etiquetado explícitamente por el usuario como "evolución interesante para una segunda versión", fuera de scope de v1. No confundir con el checkpoint/flow-state de Inspector (continuidad de sesión, no analítica de patrones).

**Este ítem, junto con el de memoria Engram (sección 15), se piensa recién cuando la beta/v1 esté funcionando.** No entra al archivo de acciones de construcción — se documenta solo acá para no perderlo.

## 17. Fuentes externas consolidadas

### Sesión 1 (web_search, 16 ago 2026)
1. arxiv.org/pdf/2511.07784 — "Can LLM Agents Really Debate? A Controlled Study" → razonamiento válido predice mejora más que presión de mayoría; sostiene regla anti-complacencia del protocolo.
2. arxiv.org/pdf/2402.06634 — SocraSynth, método CRIT → evaluar "reasonableness" sobre "truth" absoluta; resuelve el Paso 2 del protocolo.
3. labo-llm.fr — Reflection / Producer-Critic pattern → separar generación y evaluación reduce sesgo de auto-revisión; origen del Paso 3 y del pivote a multi-subagente.
4. medium.com/@edoardo.schepis — Patterns for Democratic Multi-Agent AI → mejor razonamiento vs. mayor costo de orquestación; advertencia de costo.
- Otras fuentes de la misma búsqueda (ChatEval, MADRAG, SDRL, Semantic Quorum Assurance) aparecieron pero no se usaron para ninguna conclusión — no asumir revisión en profundidad.

### Sesión 2 (web_search, 17 ago 2026)
1. LangChain — docs.langchain.com/oss/python/deepagents/deep-research → origen del budget de 2-3/5 búsquedas y criterios "stop immediately when".
2. Patente Copilot / RAG recursivo (image-ppubs.uspto.gov, US 12399907) → origen de las 3 formalizaciones de diminishing returns.
3. RGAR paper (arxiv.org/pdf/2502.13361), citando Kumar et al. 2024 → advertencia de no confiabilidad de auto-evaluación de suficiencia.
4. Google Research — "Sufficient Context" (research.google/blog, arxiv.org/abs/2411.06037) → autorater externo, 93%+ precisión vs. estándar humano; confirmó infraestructura pesada, no adoptado como agente aparte, absorbido en el Validador.
5. Supernodes blog (supernodes.ai/blogs/deepsearch-inside-agents) → origen de confianza calibrada por criticidad de dominio.
6. Stop-RAG (arxiv.org/pdf/2510.14337), "Knowing When to Stop" (arxiv.org/pdf/2502.01025) → mecanismos investigados y descartados (RL, activaciones internas).

### Sesión 3
Sin búsquedas nuevas — todas las conclusiones son diseño interno.

### Sesión 4 (esta conversación)
Sin búsquedas externas nuevas — trabajo de consolidación y mapeo interno sobre archivos ya existentes (inspector.md, prompt tutor crítico).

## 18. Reglas de interacción del usuario activas (meta, aplican a futuras sesiones de diseño con Claude)

- Modo pensamiento crítico, no complacencia — cuestionar supuestos, no validar por defecto.
- Detección de uso pasivo: si el usuario llega sin razonar primero, devolver la pregunta — excepto al abrir sesión con estos archivos de contexto ya cargados, donde "con qué continuamos" es la forma esperada de arrancar.
- Detección de búsqueda de validación: si ya tiene la respuesta y busca que se la repitan, no dar el alivio.
- Reality Filter siempre activo: etiquetar `[Inferencia]`, `[Especulación]`, `[No verificado]` explícitamente.
- Modo respuesta rápida ("pr"): mensaje termina en "pr" → directo, sin detección de uso pasivo, sin preguntas de vuelta, Reality Filter sigue activo.

## 19. Checklist final de estado (fin de fase de diseño, sesión 4)

| # | Ítem | Estado |
|---|---|---|
| 1 | Eje de "stop" en investigación | RESUELTO (sección 7, 7bis) |
| 2 | Roles y disparadores de subagentes | RESUELTO (sección 8) |
| 3 | Frontmatter de los 3 agentes | RECLASIFICADO a construcción (sección 14) |
| 4 | Nombre del proyecto/carpeta e instalación | RESUELTO — Desearch (sección 20) |
| 5 | Diseño de memoria Engram | DIFERIDO (sección 15) |
| 6 | Guardado de casos "B" / analítica de patrones | DIFERIDO a v2 del proyecto (sección 16) |
| 7 | Marca inline ClipLab | Construcción, no bloquea diseño |
| 8 | Formato/estructura interna del archivo denso | ABIERTO, nivel diseño, pendiente para fase de construcción (sección 13) |
| 9 | Umbrales concretos de la cascada DR | ABIERTO, nivel construcción (sección 7bis) |
| 10 | Presupuesto cross-turno cuando el turno no llega a 6 | RESUELTO (sección 10) |
| 11 | Reality Filter incrustado en el resto del flujo | RESUELTO (sección 11) |
| 12 | Personalidad por modo | RESUELTO (sección 12) |

**Estado de diseño: cerrado para pasar a construcción.** Quedan 2 puntos genuinamente abiertos a nivel diseño (ítem 8, formato de archivo denso — explícitamente diferido por el usuario a la fase de construcción) y el resto son pendientes de nivel construcción (números concretos, YAML, marca inline). Ver `desearch-acciones-construccion.md` para el documento accionable.

## 20. Nombre del proyecto

**Desearch** (combinación de "deep" + "research"). Confirmado por el usuario en sesión 4. Ver cierre de esta conversación para 3 alternativas adicionales generadas, no elegidas.
