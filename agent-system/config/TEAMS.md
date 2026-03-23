# Agent System — 24/7 Autonomous Team

## Estructura del Sistema

```
Totin (Director, tú)
  └── Equipo "agency-ops" (persistent 24/7)
        ├── leader 🤖 — Orchestrator, asigna tareas, coordina
        ├── researcher 🔍 — Investiga, busca leads, analiza mercado
        ├── writer ✍️ — Crea contenido, copy, proposals
        ├── coder 💻 — Automatizaciones, n8n, scripts
        └── analyst 📊 — Analiza datos, reports, métricas
```

## Workflow

1. Director (Totin) crea equipo y spawnea agentes
2. Leader recibe objetivos y crea/spawnea workers especializados
3. Workers ejecutan tareas y reportan al leader
4. Leader marca tareas completadas y reporta al Director
5. Cron checks: si un agente muere, respawn automático
6. Memory: cada agente actualiza su learning log

## Comandos

```bash
# Arrancar sistema completo
./scripts/start-agency-ops.sh

# Ver estado
clawteam team status agency-ops

# Dashboard
clawteam board serve agency-ops

# Ver logs de un agente
clawteam lifecycle logs agency-ops <agent-name>

# Parar todo
./scripts/stop-agency-ops.sh
```

## Specializations

### researcher
- Web research, lead generation, competitive analysis
- Skills: web_search, summarize, data_enrichment
- Tools: web_search, web_fetch, summarize

### writer
- Content creation, copy, email templates, proposals
- Skills: copywriting, content_strategy, seo
- Tools: documents, templates

### coder
- n8n workflows, scripts, automation
- Skills: n8n, python, bash, api_integration
- Tools: n8n, cli-anything, exec

### analyst
- Data analysis, reporting, metrics
- Skills: data_analysis, reporting, visualization
- Tools: spreadsheet, json_analysis
