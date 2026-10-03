# Scripts de control de Desearch

Esta carpeta contiene herramientas de control ejecutables que
verifican propiedades del producto. No son parte del producto;
existen para que quien mantiene o revisa Desearch pueda
comprobar invariantes sin ejecutar el sistema completo.

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
| Flag desconocido | `bash scripts/verificar-composicion.sh --otro` | Error a stderr; exit 2 |

Exit codes:

- `0` — los cinco controles pasan; la entrega puede cerrarse.
- `1` — al menos un control falló; la entrega queda bloqueada.
- `2` — uso incorrecto (flag desconocido).

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

### Cuándo correr

- Cuando cambia cualquiera de los tres roles: Principal,
    Validador o Crítico.
- Antes de cerrar una entrega que afecte a cualquiera de
    los tres roles.

No está pensado para correr en cada commit. El control
protege los límites sin añadir vigilancia continua.

### Paridad dev/prod

La lógica del script es idéntica en cualquier entorno.
La única diferencia entre invocaciones es el nivel de
detalle del informe, controlado por el flag `--ampliado`.
El mayor detalle de diagnóstico no concede capacidades
adicionales: el script nunca relaja un control para
"ver mejor" en desarrollo.

### Cómo leer el resultado

- **5 [OK] + "Composición verificada"** → la entrega puede
    cerrarse como verificada.
- **Al menos un [FALLO]** → la entrega queda bloqueada.
    Revisar el `rol` y el `límite afectado` para localizar la
    regresión. El `control incumplido` indica qué propiedad
    normativa se violó. En modo `--ampliado`, la línea
    `evidencia:` muestra la salida exacta que motivó el fallo.
- **Exit 2** → uso incorrecto (flag desconocido). No es un
    fallo de control.

### Relación con otros elementos

El script valida la composición estática: lee archivos
declarativos, no ejecuta agentes. La validación del
comportamiento end-to-end del MVP es una verificación
distinta, que se materializa en el recorrido completo de
instalación y uso.

La persona usuaria final no recibe detalles internos de
los controles; si corresponde comunicarle el estado,
recibe únicamente un aviso general de validación
incompleta.
