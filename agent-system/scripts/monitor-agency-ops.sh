#!/bin/bash
# =============================================================================
# Agency Ops — 24/7 Monitor & Auto-Heal
# =============================================================================
# Runs every 5 minutes, checks agents, respawns dead ones
# =============================================================================

TEAM="agency-ops"
INTERVAL=300  # 5 minutes

export CLAWTEAM_TEAM="$TEAM"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} [MONITOR] $1"; }

log "🚀 Agency Ops Monitor started — checking every ${INTERVAL}s"

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Get team status
    STATUS=$(clawteam team status "$TEAM" 2>/dev/null)
    
    if echo "$STATUS" | grep -q "not found"; then
        log "⚠️  Equipo $TEAM no existe — esperando..."
        sleep $INTERVAL
        continue
    fi
    
    # Count agents
    MEMBERS=$(echo "$STATUS" | grep -c "general-purpose\|leader\|researcher\|writer\|coder\|analyst" || echo "0")
    
    # Get pending tasks
    PENDING=$(clawteam task list "$TEAM" 2>/dev/null | grep -c "pending" || echo "0")
    COMPLETED=$(clawteam task list "$TEAM" 2>/dev/null | grep -c "completed" || echo "0")
    
    log "📊 Team: $TEAM | Members: $MEMBERS | Pending: $PENDING | Completed: $COMPLETED"
    
    # Check if leader is alive (tmux session exists)
    if ! tmux list-sessions 2>/dev/null | grep -q "clawteam-$TEAM:leader"; then
        log "⚠️  Leader no está activo — intentando respawn..."
        # Note: leader respawn needs special handling
    fi
    
    # Check specialized agents
    for AGENT in researcher writer coder analyst; do
        if ! tmux list-sessions 2>/dev/null | grep -q "clawteam-$TEAM:$AGENT"; then
            log "🔄 Respawning $AGENT..."
            
            case $AGENT in
                researcher)
                    TASK="Eres el investigador. Revisa clawteam task list $TEAM y continúa con las tareas pending. Prioriza: research leads y competitive analysis."
                    ;;
                writer)
                    TASK="Eres el writer. Revisa clawteam task list $TEAM y continúa con contenido para LinkedIn y proposals."
                    ;;
                coder)
                    TASK="Eres el coder. Revisa clawteam task list $TEAM y continúa con workflows n8n de demo."
                    ;;
                analyst)
                    TASK="Eres el analyst. Revisa clawteam task list $TEAM y continúa con análisis de competencia y pricing."
                    ;;
            esac
            
            clawteam spawn --team "$TEAM" --agent-name "$AGENT" \
                --agent-type "$AGENT" \
                --repo ~/.openclaw/workspace \
                --task "$TASK" 2>/dev/null
                
            log "✅ $AGENT respawned"
        fi
    done
    
    # If no pending tasks, create new ones based on team goals
    if [ "$PENDING" -eq 0 ] && [ "$COMPLETED" -gt 0 ]; then
        log "📋 No pending tasks — generating new tasks..."
        
        # Generate new research task
        RAND=$((RANDOM % 5))
        case $RAND in
            0)
                clawteam task create "$TEAM" "Research: Tendencias AI agents $(date '+%B %Y')" \
                    -d "Investigar últimas tendencias en AI agents para business. Buscar noticias, nuevos productos, casos de éxito." -o researcher 2>/dev/null
                log "📝 Nueva tarea: research tendencias"
                ;;
            1)
                clawteam task create "$TEAM" "Content: Post LinkedIn sobre automatización" \
                    -d "Crear post viral para LinkedIn sobre por qué agencias necesitan automatización AI ahora." -o writer 2>/dev/null
                log "📝 Nueva tarea: post LinkedIn"
                ;;
            2)
                clawteam task create "$TEAM" "Demo: Workflow email automation" \
                    -d "Crear workflow n8n que: trigger por webhook → filtra por tipo lead → envía secuencia de emails. Exportar JSON." -o coder 2>/dev/null
                log "📝 Nueva tarea: demo email automation"
                ;;
            3)
                clawteam task create "$TEAM" "Analysis: ROI de automatización" \
                    -d "Calcular: cuánto tiempo ahorra un workflow de automatización típico? Crear calculator/simple ROI report." -o analyst 2>/dev/null
                log "📝 Nueva tarea: ROI analysis"
                ;;
            4)
                clawteam task create "$TEAM" "Leads:Hotels & Restaurants Costa del Sol" \
                    -d "Buscar 20 hoteles y restaurantes en Marbella/Marbella que tengan presencia online pero poca automatización. Incluir web y emails." -o researcher 2>/dev/null
                log "📝 Nueva tarea: leads hospitality"
                ;;
        esac
    fi
    
    # Update memory with progress
    if [ -f ~/.openclaw/workspace/memory/$(date '+%Y-%m-%d').md ]; then
        echo "[$TIMESTAMP] Agency Ops: Members=$MEMBERS Pending=$PENDING Completed=$COMPLETED" >> ~/.openclaw/workspace/memory/$(date '+%Y-%m-%d').md
    fi
    
    sleep $INTERVAL
done
