#!/usr/bin/env bash
#
# verificar-composicion.sh
# Verifica la composición de los tres roles de Desearch:
# Principal, Validador y Crítico. Ejecuta cinco controles
# normativos sobre capacidades declaradas, momento de escritura
# del registro, activación condicional del modo aprendizaje e
# independencia de los dos contadores. Pensado para invocarse
# manualmente cuando cambia cualquiera de los tres roles o antes
# de cerrar una entrega que los afecte.
#
# Uso:
#   bash scripts/verificar-composicion.sh         # informe breve
#   bash scripts/verificar-composicion.sh --ampliado  # informe detallado
#
# Exit codes:
#   0 — los cinco controles pasan; la entrega puede cerrarse.
#   1 — al menos un control falló; la entrega queda bloqueada.
#   2 — uso incorrecto (flag desconocido).
#
# Paridad dev/prod:
#   La lógica es idéntica en cualquier entorno. La única
#   diferencia entre invocaciones es el nivel de detalle del
#   informe, controlado por el flag --ampliado.

set -euo pipefail

# Detección de TTY para colores ANSI
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  COLOR_OK=$'\033[32m'
  COLOR_FAIL=$'\033[31m'
  COLOR_RESET=$'\033[0m'
else
  COLOR_OK=""
  COLOR_FAIL=""
  COLOR_RESET=""
fi

# Bandera de modo ampliado
MODO_AMPLIADO=0
for arg in "$@"; do
  case "$arg" in
    --ampliado) MODO_AMPLIADO=1 ;;
    --help|-h)
      sed -n '2,16p' "$0"
      exit 0
      ;;
    *)
      echo "Flag desconocido: $arg" >&2
      exit 2
      ;;
  esac
done

# Rutas base
RAIZ_REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
AGENTES="$RAIZ_REPO/agentes"
OPENCODE="$RAIZ_REPO/.opencode/agents"

# Contadores de resultado
TOTAL_CONTROLES=5
CONTROLES_OK=0

imprimir_ok() {
  echo "${COLOR_OK}[OK]${COLOR_RESET} CONTROL $1 — $2"
}

imprimir_fallo() {
  echo "${COLOR_FAIL}[FALLO]${COLOR_RESET} CONTROL $1 — $2"
  echo "  rol:                $3"
  echo "  límite afectado:    $4"
  echo "  control incumplido: $5"
  if [[ "$MODO_AMPLIADO" -eq 1 ]]; then
    echo "  evidencia:          $6"
  fi
}

imprimir_resumen() {
  echo "----------------------------------------"
  if [[ "$CONTROLES_OK" -eq "$TOTAL_CONTROLES" ]]; then
    echo "${COLOR_OK}[OK]${COLOR_RESET} Composición verificada: $CONTROLES_OK de $TOTAL_CONTROLES controles pasan."
    echo "La entrega puede cerrarse."
  else
    echo "${COLOR_FAIL}[BLOQUEADO]${COLOR_RESET} Composición NO verificada: $CONTROLES_OK de $TOTAL_CONTROLES controles pasan; $((TOTAL_CONTROLES - CONTROLES_OK)) fallaron."
    echo "La entrega NO puede cerrarse como verificada."
  fi
}

# Verifica que el Validador declara permissions read-only en su
# fuente de verdad y que su mirror de integración coincide.
control_1() {
  local archivo_producto="$AGENTES/validador-dr.md"
  local archivo_integracion="$OPENCODE/validador-dr.md"

  # Evidencia inaccesible: archivo de producto ausente
  if [[ ! -f "$archivo_producto" ]]; then
    imprimir_fallo 1 "Validador" "Validador" "permiso de búsqueda o escritura" \
      "fuente de verdad no encontrada" "$archivo_producto ausente"
    return 1
  fi

  # Verificación de permisos declarados
  if ! grep -q "^  read: allow" "$archivo_producto" \
     || ! grep -q "^  edit: deny" "$archivo_producto" \
     || ! grep -q "^  bash: deny" "$archivo_producto" \
     || ! grep -q "^  webfetch: deny" "$archivo_producto" \
     || ! grep -q "^  websearch: deny" "$archivo_producto"; then
    imprimir_fallo 1 "Validador sin búsqueda ni escritura" "Validador" \
      "permiso de búsqueda o escritura" \
      "permisos esperados (read:allow + edit/bash/webfetch/websearch:deny) no declarados" \
      "$(grep -E '^  (read|edit|bash|webfetch|websearch):' "$archivo_producto" || echo ninguno)"
    return 1
  fi

  # Sincronización producto ↔ integración
  if [[ -f "$archivo_integracion" ]] && ! diff -q "$archivo_producto" "$archivo_integracion" >/dev/null 2>&1; then
    imprimir_fallo 1 "Validador sin búsqueda ni escritura" "Validador" \
      "paridad producto-integración" \
      "mirror de integración driftado respecto al producto" \
      "$(diff "$archivo_producto" "$archivo_integracion" | head -20)"
    return 1
  fi

  imprimir_ok 1 "Validador sin búsqueda ni escritura"
  CONTROLES_OK=$((CONTROLES_OK + 1))
  return 0
}

# Verifica que el Crítico declara permissions read-only en su
# fuente de verdad y que su mirror de integración coincide.
control_2() {
  local archivo_producto="$AGENTES/critico.md"
  local archivo_integracion="$OPENCODE/critico.md"

  # Evidencia inaccesible: archivo de producto ausente
  if [[ ! -f "$archivo_producto" ]]; then
    imprimir_fallo 2 "Critico" "Crítico" "permiso de búsqueda o escritura" \
      "fuente de verdad no encontrada" "$archivo_producto ausente"
    return 1
  fi

  # Verificación de permisos declarados
  if ! grep -q "^  read: allow" "$archivo_producto" \
     || ! grep -q "^  edit: deny" "$archivo_producto" \
     || ! grep -q "^  bash: deny" "$archivo_producto" \
     || ! grep -q "^  webfetch: deny" "$archivo_producto" \
     || ! grep -q "^  websearch: deny" "$archivo_producto"; then
    imprimir_fallo 2 "Crítico sin búsqueda ni escritura" "Crítico" \
      "permiso de búsqueda o escritura" \
      "permisos esperados (read:allow + edit/bash/webfetch/websearch:deny) no declarados" \
      "$(grep -E '^  (read|edit|bash|webfetch|websearch):' "$archivo_producto" || echo ninguno)"
    return 1
  fi

  # Sincronización producto ↔ integración
  if [[ -f "$archivo_integracion" ]] && ! diff -q "$archivo_producto" "$archivo_integracion" >/dev/null 2>&1; then
    imprimir_fallo 2 "Crítico sin búsqueda ni escritura" "Crítico" \
      "paridad producto-integración" \
      "mirror de integración driftado respecto al producto" \
      "$(diff "$archivo_producto" "$archivo_integracion" | head -20)"
    return 1
  fi

  imprimir_ok 2 "Crítico sin búsqueda ni escritura"
  CONTROLES_OK=$((CONTROLES_OK + 1))
  return 0
}

# Verifica que el Principal documenta el momento de escritura
# del registro de investigación: al menos al final de cada turno
# y antes de invocar al Validador.
control_3() {
  local archivo="$AGENTES/desearch.md"

  if [[ ! -f "$archivo" ]]; then
    imprimir_fallo 3 "Registro antes del Validador" "Principal" \
      "disponibilidad del registro de investigación" \
      "fuente de verdad del Principal no encontrada" \
      "$archivo ausente"
    return 1
  fi

  # Strings clave en la sección de registro (sin anclaje rígido a líneas)
  if ! grep -q "final de cada turno" "$archivo" \
     || ! grep -q "antes de invocar al Validador" "$archivo"; then
    imprimir_fallo 3 "Registro antes del Validador" "Principal" \
      "disponibilidad del registro de investigación" \
      "el Principal no documenta ambos momentos de escritura" \
      "$(grep -n -E 'final de cada turno|antes de invocar al Validador' "$archivo" || echo ninguno)"
    return 1
  fi

  imprimir_ok 3 "Registro antes del Validador"
  CONTROLES_OK=$((CONTROLES_OK + 1))
  return 0
}

# Verifica que ni el Principal ni la skill condicional activan
# modo aprendizaje sin pedido explícito de la persona.
control_4() {
  local archivo_principal="$AGENTES/desearch.md"
  local archivo_skill="$AGENTES/modo-aprendizaje.md"

  if [[ ! -f "$archivo_principal" ]] || [[ ! -f "$archivo_skill" ]]; then
    local presente_principal="ausente"
    [[ -f "$archivo_principal" ]] && presente_principal="presente"
    local presente_skill="ausente"
    [[ -f "$archivo_skill" ]] && presente_skill="presente"
    imprimir_fallo 4 "Modo aprendizaje condicional" "Principal o skill modo-aprendizaje" \
      "activación condicional" \
      "uno de los archivos normativos no se encontró" \
      "principal: $archivo_principal ($presente_principal); skill: $archivo_skill ($presente_skill)"
    return 1
  fi

  # El Principal debe mencionar activación explícita
  if ! grep -qi "pedido explícito" "$archivo_principal"; then
    imprimir_fallo 4 "Modo aprendizaje condicional" "Principal" \
      "activación condicional" \
      "el Principal no menciona activación por pedido explícito" \
      "$(grep -n -i -E 'pedido|activaci|explícito' "$archivo_principal" | head -5 || echo ninguno)"
    return 1
  fi

  # La skill debe mencionar activación explícita y NO auto-activación
  if ! grep -qi "pedido explícito" "$archivo_skill" \
     || ! grep -qi "nunca se asume" "$archivo_skill" \
     || ! grep -qi "proactivamente" "$archivo_skill"; then
    imprimir_fallo 4 "Modo aprendizaje condicional" "skill modo-aprendizaje" \
      "activación condicional" \
      "la skill no documenta activación exclusiva por pedido explícito sin auto-activación" \
      "$(grep -n -i -E 'activación|asum|proactiv|explícito' "$archivo_skill" | head -5 || echo ninguno)"
    return 1
  fi

  imprimir_ok 4 "Modo aprendizaje condicional"
  CONTROLES_OK=$((CONTROLES_OK + 1))
  return 0
}

# Verifica que el Principal documenta dos contadores
# independientes: cap de ejecución (8 por turno) y contador
# acumulado del Validador (cross-turno, dispara al cruzar 5
# acumulado antes de iniciar la sexta).
control_5() {
  local archivo="$AGENTES/desearch.md"

  if [[ ! -f "$archivo" ]]; then
    imprimir_fallo 5 "Contadores 8 y 6 independientes" "Principal" \
      "contadores de presupuesto y disparo" \
      "fuente de verdad del Principal no encontrada" \
      "$archivo ausente"
    return 1
  fi

  # Cap de ejecución 8 por turno
  if ! grep -qE "8( por turno)?[,)]|máximo.*8|cap.*8" "$archivo"; then
    imprimir_fallo 5 "Contadores 8 y 6 independientes" "Principal" \
      "cap de ejecución por turno" \
      "el Principal no documenta el cap de 8 por turno" \
      "$(grep -n -E '8|presupuesto|cap' "$archivo" | head -5 || echo ninguno)"
    return 1
  fi

  # Contador cross-turno del Validador (acumulado, antes de la sexta)
  if ! grep -qE "acumulad|cross-turno|cross turno" "$archivo" \
     || ! grep -qE "iniciar(se)? (la )?sexta|antes de (la|iniciar(se)? (la )?)?sexta|previo a la sexta" "$archivo"; then
    imprimir_fallo 5 "Contadores 8 y 6 independientes" "Principal" \
      "contador acumulado de disparo del Validador" \
      "el Principal no documenta el contador cross-turno y su umbral antes de la sexta" \
      "$(grep -n -E 'acumulad|cross|sexta|quint' "$archivo" | head -5 || echo ninguno)"
    return 1
  fi

  # Independencia: el cap y el cross-turno deben aparecer como
  # dos líneas/secciones distintas (no en la misma frase que los confunda)
  if grep -qE "8.*cross-turno.*6.*un solo|cross-turno.*8.*un solo|contador único" "$archivo"; then
    imprimir_fallo 5 "Contadores 8 y 6 independientes" "Principal" \
      "independencia de contadores" \
      "los contadores aparecen fusionados o como uno solo" \
      "$(grep -n -E 'un solo|único|fusion' "$archivo" || echo ninguno)"
    return 1
  fi

  imprimir_ok 5 "Contadores 8 y 6 independientes"
  CONTROLES_OK=$((CONTROLES_OK + 1))
  return 0
}

main() {
  echo "Verificación de composición de Desearch"
  echo "Modo: $([[ "$MODO_AMPLIADO" -eq 1 ]] && echo ampliado || echo breve)"
  echo "----------------------------------------"

  # Cada control se ejecuta; el primero que falla aborta
  # (composición binaria: pasa todo o no se declara verificada).
  control_1 || exit 1
  control_2 || exit 1
  control_3 || exit 1
  control_4 || exit 1
  control_5 || exit 1

  imprimir_resumen
  exit 0
}

main "$@"

# Fin del script. Sin secciones ceremoniales. El código es la
# documentación. El contrato de invocación y el formato de
# informe viven en scripts/README.md.
