# Scripts de validación y control de Desearch

## Introducción

Esta carpeta contiene scripts y documentación para validar la
composición estática y el recorrido end-to-end del MVP de
Desearch. Se ejecutan manualmente antes de declarar una entrega
lista o después de un cambio relevante.

Ninguno de estos scripts es parte del producto. Existen para que
quien mantiene o revisa Desearch pueda comprobar invariantes sin
ejecutar el sistema completo.

## Requisitos previos

- Bash 3.2+ (probado en macOS y Linux estándar).
- OpenCode CLI disponible en PATH (`command -v opencode`).
- Ejecución desde la raíz del repositorio.

## Scripts de validación

Además del script de control de composición, esta carpeta
incluye scripts de validación end-to-end del MVP. Se ejecutan
antes de declarar una entrega del MVP lista o después de un
cambio relevante que afecte a cualquiera de los cinco
recorrimientos cubiertos.

| Script | Función | Cuándo correr |
|---|---|---|
| `verificar-composicion.sh` | Verifica los 5 controles normativos sobre la composición estática de los 3 roles | Cambio de cualquier rol o antes del cierre |
| `recorrer-mvp.sh` | Verifica los 7 controles del recorrido E2E (1 precondiciones + 5 recorridos + 1 composición); invoca `verificar-composicion.sh` si está mergeado a master | Antes de declarar una entrega del MVP lista o después de un cambio relevante |
| `recorrer-mvp.md` | Playbook del operador para los pasos manuales de cada recorrido | Cuando se ejecuta `recorrer-mvp.sh` |
| `recorrer-mvp-informe.md` | Template del informe con resumen, estado por recorrido, hallazgos y aprobación | Al completar la validación E2E |
| `casos/*.md` | Casos representativos de cada recorrido (caso normal + caso de límite cuando aplique) | Referenciados por el playbook |

## Relación entre los scripts

`verificar-composicion.sh` valida la composición estática: lee
los archivos declarativos de los 3 roles y ejecuta 5 controles
normativos sobre permisos, registro y contadores. Es un check
rápido y determinístico.

`recorrer-mvp.sh` valida el recorrido end-to-end: ejecuta 7
controles (1 precondiciones + 5 recorridos + 1 composición) y
emite un informe por recorrido. Los 5 controles de recorrido
incluyen pasos manuales que el operador ejecuta siguiendo el
playbook; el script automatiza los checks determinísticos
(presencia, permisos, paridad) y la invocación del script de
composición.

Ambos se complementan: composición estática + recorrido
end-to-end = MVP listo. El control 7 de `recorrer-mvp.sh`
invoca a `verificar-composicion.sh` si el archivo existe en
master; si no, marca el recorrido como BLOQUEADO por
dependencia pendiente.

## Cuándo correr cada uno

| Situación | Script a correr |
|---|---|
| Cambia cualquiera de los 3 roles (Principal, Validador, Crítico) | `verificar-composicion.sh` |
| Cambia la skill `modo-aprendizaje` o su fuente de verdad | `verificar-composicion.sh` (control 4) |
| Antes de cerrar una entrega que afecte a los 3 roles | `verificar-composicion.sh` |
| Antes de declarar una entrega del MVP lista | `recorrer-mvp.sh` (que invoca al de composición) |
| Después de un cambio relevante en cualquiera de los 5 recorridos | `recorrer-mvp.sh` |
| Para re-ejecutar la validación completa del MVP | `recorrer-mvp.sh` |

Los controles protegen límites sin añadir vigilancia continua:
no están pensados para correr en cada commit.

## Estructura de archivos

```
scripts/
├── verificar-composicion.sh   # Script de composición estática
├── recorrer-mvp.sh            # Script de validación E2E
├── recorrer-mvp.md            # Playbook del operador
├── recorrer-mvp-informe.md    # Template del informe
├── README.md                  # Este archivo
└── casos/
    ├── instalacion.md         # Casos de instalación limpia
    ├── investigacion.md       # Casos de investigación
    ├── aprendizaje.md         # Casos de modo aprendizaje
    ├── validador.md           # Casos de evaluación de suficiencia
    └── critico.md             # Casos de cuestionamiento crítico
```

## verificar-composicion.sh

Verifica la composición de los tres roles de Desearch:
Principal, Validador y Crítico. Ejecuta cinco controles
normativos sobre las capacidades declaradas, el momento de
escritura del registro, la activación condicional del modo
aprendizaje y la independencia de los dos contadores.

Pensado para invocarse manualmente cuando cambia cualquiera de
los tres roles o antes de cerrar una entrega que los afecte.
No es una herramienta de vigilancia continua.

### Contrato de invocación

| Modo | Comando | Salida |
|---|---|---|
| Informe breve (default) | `bash scripts/verificar-composicion.sh` | Resumen accionable; qué rol falló, qué límite se afectó, qué control no pasó |
| Informe ampliado | `bash scripts/verificar-composicion.sh --ampliado` | Breve + diffs, líneas exactas y contexto de la evidencia |
| Ayuda | `bash scripts/verificar-composicion.sh --help` | Mensaje de uso |
| Flag desconocido | `bash scripts/verificar-composicion.sh --otro` | Error a stderr; código de salida 2 |

### Códigos de salida

- `0` — los cinco controles pasan; la entrega puede cerrarse.
- `1` — al menos un control falló; la entrega queda bloqueada.
- `2` — uso incorrecto (flag desconocido).

Los controles se ejecutan en orden y el primero que falla
aborta la ejecución: la composición es binaria, pasa todo o no
se declara verificada.

### Los cinco controles

| # | Control | Rol afectado | Límite verificado | Exigencia normativa |
|---|---|---|---|---|
| 1 | Validador sin búsqueda ni escritura | Validador | Sin permiso de búsqueda (webfetch/websearch) ni de escritura (edit/bash) | Permisos declarados en `agentes/validador-dr.md`; mirror en `.opencode/agents/validador-dr.md` sincronizado |
| 2 | Crítico sin búsqueda ni escritura | Crítico | Sin permiso de búsqueda ni de escritura | Permisos declarados en `agentes/critico.md`; mirror en `.opencode/agents/critico.md` sincronizado |
| 3 | Registro disponible antes del Validador | Principal | El registro de investigación se actualiza al menos al final de cada turno y antes de invocar al Validador | Documentado en la sección "Registro de investigación" de `agentes/desearch.md` |
| 4 | Modo aprendizaje condicional | Principal y skill `modo-aprendizaje` | El modo aprendizaje solo se activa por pedido explícito de la persona; no hay auto-activación ni sugerencia proactiva | Documentado en `agentes/desearch.md` (sección Modo aprendizaje) y `agentes/modo-aprendizaje.md` (sección Activación) |
| 5 | Contadores 8 y 6 independientes | Principal | Cap de ejecución (8 por turno) y contador acumulado de disparo del Validador (cross-turno, dispara antes de iniciar la sexta acumulada) son dos contadores distintos | Documentado en `agentes/desearch.md` (sección Contadores y evaluación de suficiencia) |

### Formato del informe

**Breve** (default):

```
Verificación de composición de Desearch
Modo: breve
----------------------------------------
[OK] CONTROL 1 — Validador sin búsqueda ni escritura
[OK] CONTROL 2 — Crítico sin búsqueda ni escritura
[OK] CONTROL 3 — Registro antes del Validador
[OK] CONTROL 4 — Modo aprendizaje condicional
[OK] CONTROL 5 — Contadores 8 y 6 independientes
----------------------------------------
[OK] Composición verificada: 5 de 5 controles pasan.
La entrega puede cerrarse.
```

Cuando un control falla:

```
[FALLO] CONTROL 1 — Validador sin búsqueda ni escritura
  rol:                Validador
  límite afectado:    permiso de búsqueda o escritura
  control incumplido: permisos esperados no declarados
```

**Ampliado** (`--ampliado`): agrega a cada fallo una línea
`evidencia:` con la salida exacta de `grep`/`diff` que motivó
el fallo (primeras 20 líneas).

### Paridad dev/prod

La lógica del script es idéntica en cualquier entorno.
La única diferencia entre invocaciones es el nivel de
detalle del informe, controlado por el flag `--ampliado`.
El mayor detalle de diagnóstico no concede capacidades
adicionales: el script nunca relaja un control para
"ver mejor" en desarrollo.

### Cómo leer el resultado

- **5 `[OK]` + "Composición verificada"** → la entrega puede
    cerrarse como verificada.
- **Al menos un `[FALLO]`** → la entrega queda bloqueada.
    Revisar el `rol` y el `límite afectado` para localizar la
    regresión. El `control incumplido` indica qué propiedad
    normativa se violó. En modo `--ampliado`, la línea
    `evidencia:` muestra la salida exacta que motivó el fallo.
- **Exit 2** → uso incorrecto (flag desconocido). No es un
    fallo de control.

### Comunicación del estado

La persona usuaria final no recibe detalles internos de los
controles. Si corresponde comunicarle el estado, recibe
únicamente un aviso general de validación incompleta.

## recorrer-mvp.sh

Valida que el MVP se puede recorrer de punta a punta desde una
instalación limpia. Ejecuta 7 controles: precondiciones,
instalación, investigación, modo aprendizaje, Validador,
Crítico y composición.

Los 5 controles de recorrido incluyen pasos manuales que el
operador ejecuta y registra en `recorrer-mvp-informe.md`
siguiendo el playbook de `recorrer-mvp.md`. El script no
corrige hallazgos: un control fallado o un drift detectado se
registra en el informe y se deriva al CA responsable o a un
cambio separado.

### Códigos de salida

- `0` — ningún control falló. Los controles pendientes se
    cuentan como no ejecutados a nivel de script y los
    bloqueados tampoco producen salida 1; el registro de los
    resultados vive en el informe.
- `1` — al menos un control FALLO; el MVP no se declara listo.
- `2` — uso incorrecto (flag desconocido).

Estos códigos son propios de `recorrer-mvp.sh`. Los de
`verificar-composicion.sh` están documentados en su sección.

### Marcadores de salida

El informe impreso usa marcadores por recorrido:

- `[OK]` — el recorrido pasó los checks determinísticos.
- `[FALLO]` — el recorrido tiene un control incumplido.
- `[BLOQUEADO]` — falta un recurso necesario para ejecutar el
    recorrido; no es un fallo del recorrido.
- `[PENDIENTE]` — quedan pasos manuales por completar.

`--ampliado` agrega detalle (líneas `evidencia:`, `acción:` y
`siguiente paso:`) sin relajar ningún control.

## Limitaciones conocidas

- Los pasos conversacionales (interacción con los agentes) no
  se automatizan; el operador los ejecuta siguiendo el playbook.
- Si `verificar-composicion.sh` no está mergeado a master,
  el control 7 se marca como BLOQUEADO, no como FALLO.
- Esta validación no es una certificación exhaustiva: integra
  resultados entregados y comprueba que el MVP se puede recorrer
  de punta a punta.
