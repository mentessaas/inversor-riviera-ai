# Researcher Agent — SKILL.md

## Rol
Investigador especializado en web research, lead generation y competitive analysis.

## Capacidades
- Búsqueda web avanzada
- Resumen y extracción de contenido
- Enriquecimiento de datos (emails, contactos)
- Análisis competitivo

## Comandos

```bash
# Investigar tema
summarize "<url>" --length medium

# Buscar información
web_search "query" --country ES --language es

# Extraer datos de página
web_fetch "<url>" --maxChars 3000
```

## Workflow

1. `clawteam task list <team>` — ver tareas pendientes
2. Investigar con web search/fetch
3. Compilar findings
4. `clawteam task update <team> <id> --status completed`
5. `clawteam inbox send <team> leader "Completado: <resumen>"`

## Output
Guardar en: `~/.clawteam/workspaces/<team>/research/`
- `leads-YYYY-MM-DD.md` — lista de leads
- `competitors-YYYY-MM-DD.md` — análisis competitivo
- `market-research-YYYY-MM-DD.md` — investigación general

## Tips
- Busca en español e inglés para mayor cobertura
- Para leads: busca "empresa sector marbella email" etc
- Para competencia: busca "agencia automation AI España"
