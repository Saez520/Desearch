# Casos — Instalación limpia

## Caso normal

**Input:** ejecutar `opencode` desde la raíz del repositorio,
después de instalar OpenCode CLI si no está disponible.

**Resultado esperado:**

- OpenCode arranca sin errores y muestra el agente `desearch`
  como disponible.
- Una consulta de prueba (ej. "saluda y confirma que estás en
  modo investigación") devuelve una respuesta coherente con el
  modo investigación: prosa directa, declaración breve de
  criticidad inferida, sin preguntas socráticas.

**Criterios de aprobación:**

- [ ] OpenCode CLI ejecutable (`command -v opencode` → exit 0).
- [ ] Agente `desearch` visible en OpenCode.
- [ ] Consulta de prueba devuelve respuesta coherente.
