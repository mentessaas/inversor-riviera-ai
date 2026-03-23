#!/bin/bash
# Agency Ops Status

TEAM="agency-ops"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Agency Ops Status ===${NC}"
echo ""

# Team
echo -e "${BLUE}Team:${NC}"
clawteam team status "$TEAM" 2>/dev/null || echo "  No encontrado"
echo ""

# Tasks
echo -e "${BLUE}Tareas:${NC}"
clawteam task list "$TEAM" 2>/dev/null || echo "  No hay tareas"
echo ""

# Tmux
echo -e "${BLUE}Sesiones tmux:${NC}"
tmux list-sessions 2>/dev/null | grep "clawteam-$TEAM" || echo "  No hay sesiones"
echo ""

# Monitor
if pgrep -f "monitor-agency-ops" > /dev/null; then
    echo -e "${GREEN}✅ Monitor: CORRIENDO${NC}"
else
    echo -e "${RED}❌ Monitor: PARADO${NC}"
fi

# Dashboard
if curl -s http://127.0.0.1:8080 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Dashboard: http://127.0.0.1:8080${NC}"
else
    echo -e "${RED}❌ Dashboard: PARADO${NC}"
fi

# Recent logs
echo ""
echo -e "${BLUE}Logs recientes:${NC}"
tail -5 ~/.clawteam/agency-ops-monitor.log 2>/dev/null || echo "  Sin logs"
