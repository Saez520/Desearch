# Desearch

Sistema de investigación técnica que opera sobre OpenCode en este repositorio. Entrada común reconocible por OpenCode como `Desearch`.

## Estructura

```text
desearch/
├── README.md
├── agentes/
│   ├── desearch.md
│   ├── modo-aprendizaje.md
│   ├── validador-dr.md
│   └── critico.md
└── resultados/
    ├── investigaciones/
    └── conclusiones-aprendizaje/
```

## Agentes previstos

| Archivo | Rol previsto | Estado |
|---|---|---|
| `agentes/desearch.md` | Entrada común (agente conversacional principal) | Entrada común — modo investigación definido (CA-002) |
| `agentes/modo-aprendizaje.md` | Skill condicional (modo aprendizaje del Principal) | Fuente de verdad de la skill — comportamiento definido en este CA |
| `agentes/validador-dr.md` | Validador de suficiencia (DR) | Lugar reservado — comportamiento en CAs posteriores |
| `agentes/critico.md` | Crítico de cuestionamiento | Lugar reservado — comportamiento en CAs posteriores |

## Destinos de resultados

Cada tipo de resultado tiene una ubicación predeterminada:

| Tipo de resultado | Destino predeterminado |
|---|---|
| Registro de investigación | `desearch/resultados/investigaciones/` |
| Conclusión de aprendizaje | `desearch/resultados/conclusiones-aprendizaje/` |

El formato interno del registro de investigación y la mecánica del contador de evaluación de suficiencia (disparo previo a la sexta consulta acumulada) se definen en el comportamiento del Principal (`agentes/desearch.md`). El registro de aprendizaje, separado del de investigación, se escribe en `resultados/conclusiones-aprendizaje/` desde la skill `modo-aprendizaje` que el Principal carga solo por pedido explícito; ambos registros persisten como archivos independientes.

## Carpeta destino alternativa (contrato)

Quien solicita la generación de un resultado puede indicar una carpeta destino explícita. Si la indica, el resultado se guarda en esa carpeta en lugar de su destino predeterminado. Este contrato rige para los CAs que definan la generación de resultados.

## Notas

- Este directorio es la estructura de producto de Desearch; la instalación de OpenCode vive en `.opencode/` y no forma parte del producto.