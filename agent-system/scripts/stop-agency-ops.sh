#!/bin/bash
# Stop Agency Ops — kill all agents and cleanup

TEAM="agency-ops"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[❌]${NC} $1"; }

log "Parando Agency Ops..."

# Kill monitor
pkill -f "monitor-agency-ops" 2>/dev/null && log "Monitor parado" || true

# Kill dashboard
pkill -f "clawteam board serve $TEAM" 2>/dev/null && log "Dashboard parado" || true

# Kill tmux sessions for this team
tmux kill-session -t "clawteam-$TEAM" 2>/dev/null && log "Tmux matado" || true

log "Agency Ops detenido."
log "Para reiniciar: ./scripts/start-agency-ops.sh"
