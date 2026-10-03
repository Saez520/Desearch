#!/usr/bin/env bash
#
# recorrer-mvp.sh
# Verifica que el MVP de Desearch se puede recorrer de punta a
# punta desde una instalación limpia. Ejecuta siete controles:
# precondiciones, instalación, investigación, modo aprendizaje,
# Validador, Crítico y composición (invoca verificar-composicion.sh
# del script de composición si está mergeado a master; si no, marca
# como BLOQUEADO por dependencia pendiente).
#
# Uso:
#   bash scripts/recorrer-mvp.sh             # informe breve
#   bash scripts/recorrer-mvp.sh --ampliado  # informe detallado
#
# Exit codes:
#   0 — los siete controles pasan (los pendientes manuales se
#       cuentan como OK a nivel de script; el informe es donde se
#       registran los resultados de los pasos manuales).
#   1 — al menos un control FALLO; el MVP no se declara listo.
#   2 — uso incorrecto (flag desconocido).
#
# Recorridos manuales: este script automatiza los checks donde la
# respuesta es determinística (presencia, permisos, paridad). El
# operador ejecuta los pasos conversacionales (interacción con los
# agentes) y los registra en scripts/recorrer-mvp-informe.md
# siguiendo el playbook en scripts/recorrer-mvp.md.
#
# Derivación de hallazgos: este script NO corrige hallazgos. Si
# un control falla o se detecta un drift, el hallazgo se registra
# en el informe y se deriva al CA responsable o a un cambio
# separado.

set -euo pipefail

# Detección de TTY para colores ANSI
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  COLOR_OK=$'\033[32m'
  COLOR_FAIL=$'\033[31m'
  COLOR_BLOCK=$'\033[33m'
  COLOR_PEND=$'\033[36m'
  COLOR_RESET=$'\033[0m'
else
  COLOR_OK=""
  COLOR_FAIL=""
  COLOR_BLOCK=""
  COLOR_PEND=""
  COLOR_RESET=""
fi

# Bandera de modo ampliado
MODO_AMPLIADO=0
for arg in "$@"; do
  case "$arg" in
    --ampliado) MODO_AMPLIADO=1 ;;
    --help|-h)
      sed -n '2,18p' "$0"
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
OPENCODE="$RAIZ_REPO/.opencode"
RESULTADOS="$RAIZ_REPO/resultados"

# Contadores de resultado
TOTAL_CONTROLES=7
CONTROLES_OK=0
CONTROLES_FALLO=0
CONTROLES_BLOQUEADO=0
CONTROLES_PENDIENTE=0

imprimir_ok() {
  echo "${COLOR_OK}[OK]${COLOR_RESET} CONTROL $1 — $2"
}

imprimir_fallo() {
  echo "${COLOR_FAIL}[FALLO]${COLOR_RESET} CONTROL $1 — $2"
  echo "  recorrido:         $3"
  echo "  control incumplido: $4"
  if [[ "$MODO_AMPLIADO" -eq 1 ]]; then
    echo "  evidencia:          $5"
  fi
  CONTROLES_FALLO=$((CONTROLES_FALLO + 1))
}

imprimir_bloqueado() {
  echo "${COLOR_BLOCK}[BLOQUEADO]${COLOR_RESET} CONTROL $1 — $2"
  echo "  recurso ausente:    $3"
  echo "  recorrido afectado: $4"
  if [[ "$MODO_AMPLIADO" -eq 1 ]]; then
    echo "  acción:             $5"
  fi
  CONTROLES_BLOQUEADO=$((CONTROLES_BLOQUEADO + 1))
}

imprimir_pendiente() {
  echo "${COLOR_PEND}[PENDIENTE]${COLOR_RESET} CONTROL $1 — $2"
  if [[ "$MODO_AMPLIADO" -eq 1 ]]; then
    echo "  siguiente paso:     revisar el caso en scripts/casos/$3.md y ejecutar los pasos manuales del playbook"
  fi
  CONTROLES_PENDIENTE=$((CONTROLES_PENDIENTE + 1))
}

imprimir_resumen() {
  echo "----------------------------------------"
  if [[ "$CONTROLES_FALLO" -eq 0 ]]; then
    echo "${COLOR_OK}[OK]${COLOR_RESET} Recorrido E2E: $CONTROLES_OK OK, $CONTROLES_PENDIENTE pendientes manuales, $CONTROLES_BLOQUEADO bloqueados."
    echo "Si no hay FALLO, el script pasa. Los pendientes manuales deben completarse en el informe."
  else
    echo "${COLOR_FAIL}[BLOQUEADO]${COLOR_RESET} Recorrido E2E: $CONTROLES_FALLO controles FALLARON; el MVP NO se declara listo."
    echo "Derivar los hallazgos al CA responsable o a un cambio separado."
  fi
}

# Verifica que todos los archivos y directorios imprescindibles
# para el MVP están presentes. Si alguno falta, el recorrido se
# bloquea porque no se puede ejecutar sin esos recursos.
control_1() {
  local archivos=(
    "$AGENTES/desearch.md"
    "$AGENTES/critico.md"
    "$AGENTES/validador-dr.md"
    "$AGENTES/modo-aprendizaje.md"
    "$RESULTADOS/investigaciones"
    "$RESULTADOS/conclusiones-aprendizaje"
    "$OPENCODE/skills/modo-aprendizaje/SKILL.md"
  )

  local ausentes=()
  for f in "${archivos[@]}"; do
    if [[ ! -e "$f" ]]; then
      ausentes+=("$f")
    fi
  done

  if [[ "${#ausentes[@]}" -gt 0 ]]; then
    imprimir_bloqueado 1 "Precondiciones" "${ausentes[*]}" "todos los recorridos" \
      "Restaurar los archivos y directorios imprescindibles antes de continuar"
    return 1
  fi

  imprimir_ok 1 "Precondiciones"
  CONTROLES_OK=$((CONTROLES_OK + 1))
  return 0
}

# Verifica que OpenCode CLI está disponible y que el archivo de
# configuración del proyecto es parseable. Si falla, el operador
# puede instalar OpenCode siguiendo la documentación oficial.
control_2() {
  if ! command -v opencode >/dev/null 2>&1; then
    imprimir_fallo 2 "Instalación limpia" "instalación" \
      "OpenCode CLI no disponible en PATH" \
      "ejecutar 'command -v opencode' no encontró el binario"
    return 1
  fi

  if [[ ! -f "$OPENCODE/opencode.json" ]]; then
    imprimir_fallo 2 "Instalación limpia" "instalación" \
      "configuración del proyecto no encontrada" \
      "$OPENCODE/opencode.json ausente"
    return 1
  fi

  if ! python3 -c "import json; json.load(open('$OPENCODE/opencode.json'))" 2>/dev/null \
     && ! jq -e . "$OPENCODE/opencode.json" >/dev/null 2>&1; then
    imprimir_fallo 2 "Instalación limpia" "instalación" \
      "configuración del proyecto no parseable" \
      "validar JSON de $OPENCODE/opencode.json"
    return 1
  fi

  imprimir_ok 2 "Instalación limpia"
  CONTROLES_OK=$((CONTROLES_OK + 1))
  return 0
}

# Verifica que el directorio de investigaciones es escribible y que
# el comportamiento del Principal declara las secciones normativas
# del registro de investigación y de los contadores.
control_3() {
  local archivo="$AGENTES/desearch.md"

  if [[ ! -w "$RESULTADOS/investigaciones" ]]; then
    imprimir_fallo 3 "Investigación" "registro de investigación" \
      "directorio de destino no escribible" \
      "$RESULTADOS/investigaciones no escribible"
    return 1
  fi

  if ! grep -q "Registro de investigación" "$archivo" \
     || ! grep -q "Contadores y evaluación de suficiencia" "$archivo"; then
    imprimir_fallo 3 "Investigación" "Principal" \
      "secciones normativas ausentes en el producto" \
      "$(grep -n -E 'Registro de investigación|Contadores' "$archivo" || echo ninguno)"
    return 1
  fi

  imprimir_pendiente 3 "Investigación" "investigacion"
  return 0
}

# Verifica que el directorio de conclusiones de aprendizaje es
# escribible, que la skill está presente y que su comportamiento
# declara activación solo por pedido explícito (no auto-activación).
control_4() {
  if [[ ! -w "$RESULTADOS/conclusiones-aprendizaje" ]]; then
    imprimir_fallo 4 "Modo aprendizaje" "registro de aprendizaje" \
      "directorio de destino no escribible" \
      "$RESULTADOS/conclusiones-aprendizaje no escribible"
    return 1
  fi

  local skill="$OPENCODE/skills/modo-aprendizaje/SKILL.md"
  if [[ ! -f "$skill" ]]; then
    imprimir_fallo 4 "Modo aprendizaje" "skill condicional" \
      "fuente de la skill no encontrada" \
      "$skill ausente (la skill debe existir en .opencode/skills/)"
    return 1
  fi

  if ! grep -qi "pedido explícito" "$AGENTES/modo-aprendizaje.md"; then
    imprimir_fallo 4 "Modo aprendizaje" "skill condicional" \
      "activación condicional no documentada" \
      "$(grep -n -i -E 'pedido|activaci|explícito' "$AGENTES/modo-aprendizaje.md" | head -3 || echo ninguno)"
    return 1
  fi

  imprimir_pendiente 4 "Modo aprendizaje" "aprendizaje"
  return 0
}

# Verifica que el Validador declara permisos read-only (sin
# búsqueda ni escritura) en su fuente de verdad.
control_5() {
  local archivo="$AGENTES/validador-dr.md"

  if [[ ! -f "$archivo" ]]; then
    imprimir_fallo 5 "Validador" "Validador" \
      "fuente de verdad no encontrada" \
      "$archivo ausente"
    return 1
  fi

  if ! grep -q "^  read: allow" "$archivo" \
     || ! grep -q "^  edit: deny" "$archivo" \
     || ! grep -q "^  bash: deny" "$archivo" \
     || ! grep -q "^  webfetch: deny" "$archivo" \
     || ! grep -q "^  websearch: deny" "$archivo"; then
    imprimir_fallo 5 "Validador" "Validador" \
      "permisos read-only no declarados" \
      "$(grep -E '^  (read|edit|bash|webfetch|websearch):' "$archivo" || echo ninguno)"
    return 1
  fi

  imprimir_pendiente 5 "Validador" "validador"
  return 0
}

# Verifica que el Crítico declara permisos read-only y que su rol
# declara explícitamente que no ejecuta búsquedas ni escribe
# archivos.
control_6() {
  local archivo="$AGENTES/critico.md"

  if [[ ! -f "$archivo" ]]; then
    imprimir_fallo 6 "Critico" "Crítico" \
      "fuente de verdad no encontrada" \
      "$archivo ausente"
    return 1
  fi

  if ! grep -q "^  read: allow" "$archivo" \
     || ! grep -q "^  edit: deny" "$archivo" \
     || ! grep -q "^  bash: deny" "$archivo" \
     || ! grep -q "^  webfetch: deny" "$archivo" \
     || ! grep -q "^  websearch: deny" "$archivo"; then
    imprimir_fallo 6 "Critico" "Crítico" \
      "permisos read-only no declarados" \
      "$(grep -E '^  (read|edit|bash|webfetch|websearch):' "$archivo" || echo ninguno)"
    return 1
  fi

  if ! grep -qi "no ejecuta búsquedas" "$archivo" \
     && ! grep -qi "no escribe archivos" "$archivo"; then
    imprimir_fallo 6 "Critico" "Crítico" \
      "rol read-only no declarado" \
      "$(grep -n -i -E 'no ejecuta|no escribe|read.only' "$archivo" | head -3 || echo ninguno)"
    return 1
  fi

  imprimir_pendiente 6 "Critico" "critico"
  return 0
}

# Si scripts/verificar-composicion.sh existe (script de composición
# mergeado a master), lo invoca y propaga su resultado. Si NO existe,
# marca como BLOQUEADO por dependencia pendiente: el script de
# composición está cerrado y aprobado pero su merge a master aún no
# se aplicó (verificado: git ls-files scripts/ → vacío en master,
# el commit de composición vive solo en su worktree). NO se presenta
# como FALLO.
control_7() {
  local script_ca006="$RAIZ_REPO/scripts/verificar-composicion.sh"

  if [[ ! -f "$script_ca006" ]]; then
    imprimir_bloqueado 7 "Composición" \
      "scripts/verificar-composicion.sh ausente" \
      "composición estática" \
      "mergear a master antes de validar composición (script de composición cerrado, pendiente de merge)"
    return 1
  fi

  if ! bash "$script_ca006" >/tmp/composicion-salida.txt 2>&1; then
    imprimir_fallo 7 "Composición" "composición estática" \
      "verificar-composicion.sh reportó fallo" \
      "$(head -20 /tmp/composicion-salida.txt)"
    return 1
  fi

  imprimir_ok 7 "Composición"
  CONTROLES_OK=$((CONTROLES_OK + 1))
  return 0
}

main() {
  echo "Verificación end-to-end del MVP de Desearch"
  echo "Modo: $([[ "$MODO_AMPLIADO" -eq 1 ]] && echo ampliado || echo breve)"
  echo "----------------------------------------"

  # Cada control se ejecuta; el primero que falla aborta con
  # exit 1 (FALLO). Los BLOQUEADOS también cuentan como no-apto
  # para exit code, pero el operador puede continuar si la
  # dependencia pendiente se resuelve (D-RESILIENCIA-CA006).
  control_1 || true
  control_2 || true
  control_3 || true
  control_4 || true
  control_5 || true
  control_6 || true
  control_7 || true

  imprimir_resumen

  if [[ "$CONTROLES_FALLO" -gt 0 ]]; then
    exit 1
  fi

  exit 0
}

main "$@"

# Fin del script. Sin secciones ceremoniales. El código es la
# documentación. El contrato de invocación y el formato de
# informe viven en scripts/README.md.
