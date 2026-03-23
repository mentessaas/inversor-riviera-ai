#!/bin/bash
# =============================================================================
# Agency Ops — 24/7 Autonomous Agent Team Launcher
# =============================================================================
# Usage: ./scripts/start-agency-ops.sh
# =============================================================================

set -e

TEAM="agency-ops"
TEAM_DESC="Equipo autónomo 24/7 para agencia AI de Elvis"
LEADER="leader"

export CLAWTEAM_TEAM="$TEAM"

# Colours
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[🚀]${NC} $1"; }
warn() { echo -e "${YELLOW}[⚠️]${NC} $1"; }
error() { echo -e "${RED}[❌]${NC} $1"; }

# =============================================================================
# 1. Setup workspace git repo if needed
# =============================================================================
log "Verificando workspace git..."
cd ~/.openclaw/workspace
git branch -M main 2>/dev/null || git init -b main
git commit --allow-empty -m "init" 2>/dev/null || true

# =============================================================================
# 2. Create or resume team
# =============================================================================
log "Creando equipo $TEAM..."

if clawteam team discover 2>/dev/null | grep -q "$TEAM"; then
    warn "Equipo $TEAM ya existe — usando existente"
else
    clawteam team spawn-team "$TEAM" -d "$TEAM_DESC" -n "$LEADER" 2>/dev/null
    log "Equipo creado!"
fi

clawteam team status "$TEAM" 2>/dev/null

# =============================================================================
# 3. Create tasks for the team
# =============================================================================
log "Creando tareas iniciales..."

# Task 1: Market Research
clawteam task create "$TEAM" "Investigación de mercado: AI agencies en España" \
    -d "Investigar 10 agencies de AI en España: nombre, web, precios, servicios, diferenciador. Guardar en ~/clawteam/workspaces/agency-ops/research/market-research.md" \
    -o researcher 2>/dev/null || true

# Task 2: Lead Generation
clawteam task create "$TEAM" "Generación de leads: 50 prospectos" \
    -d "Generar lista de 50 empresas en Costa del Sol (real estate, tourism, restaurants) que podrían necesitar servicios de automatización AI. Nombre, web, email si es posible." \
    -o researcher 2>/dev/null || true

# Task 3: Content Calendar
clawteam task create "$TEAM" "Calendario de contenido LinkedIn" \
    -d "Crear calendario de contenido para LinkedIn: 20 posts sobre AI agents para negocios. Incluir: tema, hook, estructura, hashtags." \
    -o writer 2>/dev/null || true

# Task 4: n8n Automation Demo
clawteam task create "$TEAM" "Demo workflow n8n: lead capture" \
    -d "Crear un workflow n8n de demostración: captura leads desde web → guarda en CSV → envía email de bienvenida. Exportar como JSON." \
    -o coder 2>/dev/null || true

# Task 5: Competitive Analysis Report
clawteam task create "$TEAM" "Informe de competencia: pricing analysis" \
    -d "Analizar pricing de 10 agencies de automatización. Crear tabla comparativa y recomendar estructura de precios para nuestra agencia." \
    -o analyst 2>/dev/null || true

log "Tareas creadas!"

# =============================================================================
# 4. Spawn Specialized Agents
# =============================================================================
log "Lanzando agentes especializados..."

spawn_agent() {
    local NAME="$1"
    local TYPE="$2"
    local TASK="$3"
    
    # Check if already running
    if tmux list-sessions 2>/dev/null | grep -q "clawteam-$TEAM:$NAME"; then
        warn "Agente $NAME ya está corriendo — saltando"
        return 0
    fi
    
    log "  → Spawning $NAME ($TYPE)"
    clawteam spawn --team "$TEAM" --agent-name "$NAME" \
        --agent-type "$TYPE" \
        --repo ~/.openclaw/workspace \
        --task "$TASK" 2>/dev/null
}

# Researcher
spawn_agent "researcher" "researcher" \
    "Eres el investigador de la agencia. Tu misión: investigar el mercado de AI agencies en España. 

Tareas pendientes:
1. Busca agencies de AI en España y analiza sus servicios y precios
2. Genera leads de empresas en Costa del Sol 
3. Usa clawteam task list $TEAM para ver todas tus tareas
4. Cuando completes una tarea: clawteam task update $TEAM <task-id> --status completed
5. Reporta al líder: clawteam inbox send $TEAM leader 'Tarea completada: <descripción>'

Skills disponibles: web search, summarize, data analysis. 
Trabaja de forma autónoma. Si necesitas información, investígala. Si completas algo, marca y reporta."

# Writer
spawn_agent "writer" "writer" \
    "Eres el creador de contenido de la agencia. Tu misión: generar contenido de marketing.

Tareas pendientes:
1. Crear calendario de contenido LinkedIn (20 posts)
2. Escribir proposals template para clientes
3. Usar clawteam task list $TEAM para ver tus tareas

Cuando termines contenido, marca la tarea completada y reporta al leader.

Skills: copywriting, content strategy, SEO, email copy. Escribe contenido que vende."

# Coder
spawn_agent "coder" "coder" \
    "Eres el desarrollador de automatizaciones. Tu misión: construir demos y automatizaciones.

Tareas pendientes:
1. Crear workflow n8n de demo para lead capture
2. Documentar el workflow para que pueda servir como demo para clientes
3. Usar clawteam task list $TEAM para ver todas las tareas

Skills: n8n, python, bash, API integration. El directorio de trabajo es ~/.openclaw/workspace/agent-system/workflows/"

# Analyst
spawn_agent "analyst" "analyst" \
    "Eres el analista de la agencia. Tu misión: analizar datos y generar insights.

Tareas pendientes:
1. Competitive analysis de pricing
2. Crear informe de mercado con recomendaciones
3. Usar clawteam task list $TEAM para ver tus tareas

Skills: data analysis, reporting, market research. Guarda análisis en ~/clawteam/workspaces/agency-ops/analysis/"

# =============================================================================
# 5. Start Monitoring (background)
# =============================================================================
log "Iniciando monitor..."
nohup ~/.openclaw/workspace/agent-system/scripts/monitor-agency-ops.sh > ~/.clawteam/agency-ops-monitor.log 2>&1 &
log "Monitor corriendo en background (PID: $!)"

# =============================================================================
# 6. Start Dashboard
# =============================================================================
log "Iniciando dashboard..."
if ! pgrep -f "clawteam board serve $TEAM" > /dev/null; then
    cd ~/.openclaw/workspace/agent-system
    nohup clawteam board serve "$TEAM" > ~/.clawteam/agency-ops-board.log 2>&1 &
    log "Dashboard: http://127.0.0.1:8080"
else
    warn "Dashboard ya está corriendo"
fi

# =============================================================================
# 7. Summary
# =============================================================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Agency Ops 24/7 — Sistema Arrancado${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "  Team: ${BLUE}$TEAM${NC}"
echo -e "  Dashboard: ${BLUE}http://127.0.0.1:8080${NC}"
echo -e "  Status: ${BLUE}clawteam team status $TEAM${NC}"
echo -e "  Logs: ${BLUE}~/.clawteam/agency-ops-monitor.log${NC}"
echo ""
clawteam task list "$TEAM" 2>/dev/null | head -20
echo ""
