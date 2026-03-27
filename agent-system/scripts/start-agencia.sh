#!/bin/bash
# =============================================================================
# AGENIA Startup Script — Starts all systems
# =============================================================================
# Run this to start everything: Paperclip + OpenClaw + Agent System
# =============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[🚀]${NC} $1"; }
warn() { echo -e "${YELLOW}[⚠️]${NC} $1"; }
error() { echo -e "${RED}[❌]${NC} $1"; }

PAPERCLIP_DIR="$HOME/.paperclip-test"
PAPERCLIP_DATA="$HOME/Desktop/_PROYECTOS/Agenia_Marketing/agencia/13-Setup-Agencia"

# =============================================================================
# 1. Check if Paperclip is already running
# =============================================================================
if curl -s http://localhost:3100/api/health > /dev/null 2>&1; then
    log "Paperclip ya está corriendo en http://localhost:3100"
    PAPERCLIP_RUNNING=true
else
    log "Iniciando Paperclip..."
    $HOME/.nvm/versions/node/v22.22.0/bin/paperclipai onboard --yes --run \
        -d "$PAPERCLIP_DIR" > /tmp/paperclip.log 2>&1 &
    PAPERCLIP_PID=$!
    log "Paperclip iniciado (PID: $PAPERCLIP_PID)"
    
    # Wait for Paperclip to be ready
    for i in {1..15}; do
        if curl -s http://localhost:3100/api/health > /dev/null 2>&1; then
            log "Paperclip listo!"
            break
        fi
        sleep 1
    done
    PAPERCLIP_RUNNING=false
fi

# =============================================================================
# 2. Check Paperclip status
# =============================================================================
log "=== STATUS AGENIA ==="
COMPANY_ID="861917e0-8015-4962-a39e-6c8970767d59"
API_KEY=$(python3 -c "import json; print(json.load(open('$HOME/.openclaw/workspace/paperclip-claimed-api-key.json'))['token'])" 2>/dev/null || echo "")

if [ -n "$API_KEY" ]; then
    AGENTS=$(curl -s "http://localhost:3100/api/companies/$COMPANY_ID/agents" \
        -H "Authorization: Bearer $API_KEY" 2>/dev/null | \
        python3 -c "import sys,json; a=json.load(sys.stdin); print(f'{len(a)} agents')" 2>/dev/null || echo "? agents")
    TASKS=$(curl -s "http://localhost:3100/api/companies/$COMPANY_ID/issues?status=todo" \
        -H "Authorization: Bearer $API_KEY" 2>/dev/null | \
        python3 -c "import sys,json; t=json.load(sys.stdin); print(f'{len(t)} tareas pendientes')" 2>/dev/null || echo "? tareas")
    log "Agentes activos: $AGENTS"
    log "Tareas pendientes: $TASKS"
fi

# =============================================================================
# 3. Dashboard URL
# =============================================================================
echo ""
log "=== ACCESO ==="
log "Dashboard: http://localhost:3100/AGE/dashboard"
log "Skills: ~/.openclaw/skills/paperclip/SKILL.md"

# =============================================================================
# 4. Cron status
# =============================================================================
echo ""
log "=== CRON JOBS ==="
echo "Paperclip CEO Heartbeat: cada 5 min (mirar cron jobs activos)"

echo ""
log "=== INICIADO ==="
echo ""
echo "Para parar Paperclip: kill \$(pgrep -f paperclipai)"
echo "Para ver logs: tail -f /tmp/paperclip.log"
echo ""
