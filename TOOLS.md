# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is _my_ specifics — the stuff that's unique to our setup.

---

## 🖥️ Elvis's Machine

- **Host:** MacBook Air (Elvis)
- **OS:** macOS Darwin 25.3.0 (arm64)
- **Node:** v22.22.0
- **Shell:** zsh
- **Workdir:** `/Users/elvisvaldesinerarte/.openclaw/workspace`

---

## 🔑 Access & Accounts

- **Elvis email:** elvisvaldesinerarte@gmail.com
- **GitHub:** github.com/mentessaas
- **Zaltyko repo:** github.com/mentessaas/Zaltyko

---

## 🚀 Active Systems

### Agent System 24/7
- **Location:** `~/.openclaw/workspace/agent-system/`
- **Dashboard:** http://127.0.0.1:8080
- **Start:** `~/.openclaw/workspace/agent-system/scripts/start-agency-ops.sh`
- **Stop:** `~/.openclaw/workspace/agent-system/scripts/stop-agency-ops.sh`
- **Status:** `~/.openclaw/workspace/agent-system/scripts/status-agency-ops.sh`
- **Monitor:** cada 5 min auto-heal

### ClawTeam
- **Install:** `pipx install clawteam` → v0.1.2
- **Wrapper:** `~/.local/bin/openclaw-agent-wrapper`
- **Skill:** `~/.openclaw/skills/clawteam/SKILL.md`

---

## 🛠️ CLI Tools (CLI-Anything)

| CLI | Status | Command |
|-----|--------|---------|
| drawio | ✅ | `cli-anything-drawio` |
| mermaid | ✅ | `cli-anything-mermaid` |
| ollama | ✅ | `cli-anything-ollama` |
| comfyui | ✅ | `cli-anything-comfyui` |
| browser | ✅ | `cli-anything-browser` |
| kdenlive | ✅ | `cli-anything-kdenlive` |
| blender | ✅ | `cli-anything-blender` |
| n8n | ✅ | `n8n` / `cli-anything-n8n` |

**CLI-Anything repo:** `~/.openclaw/workspace/CLI-Anything/`

---

## 🌐 Web & URLs

- **Zaltyko:** https://zaltyko.vercel.app
- **ClawHub:** https://clawhub.com
- **OpenClaw docs:** `/Users/elvisvaldesinerarte/.nvm/versions/node/v22.22.0/lib/node_modules/openclaw/docs`

---

## 📊 Skills Available

- **cli-anything:** `~/.openclaw/skills/cli-anything/SKILL.md`
- **clawteam:** `~/.openclaw/skills/clawteam/SKILL.md`
- **github:** `~/.openclaw/skills/github/SKILL.md`
- **gog (Google Workspace):** `~/.openclaw/skills/gog/SKILL.md`
- **weather:** `~/.openclaw/skills/weather/SKILL.md`
- **himalaya (email):** `~/.openclaw/skills/himalaya/SKILL.md`
- **stripe-best-practices:** `~/.openclaw/workspace/skills/stripe-best-practices/SKILL.md`
- **notion:** `~/.openclaw/workspace/skills/notion/SKILL.md`
- **+ 20+ more** — check `~/.openclaw/skills/`

## 📱 Dashboard

- **Location:** `~/.openclaw/workspace/dashboard/index.html`
- **Quick access:** Open in browser
- **Features:** Agent status, tasks, system health, quick links
- **Auto-refresh:** Every 60 seconds

## 🔊 TTS

- Tested and working
- Use `tts` tool to narrate reports, drafts, summaries
- Say "hey Elvis, I'm Totin, what do you want me to tackle next?"

---

## 🗓️ Cron Jobs

- **Daily Research Report:** 8AM (Europe/Madrid) — active
- **Telegram delivery:** configured for cron announcements

---

## ⚠️ Pending / Blocked

- Twitter/X auth — not configured yet
- Brevo API — not configured yet

---

## 📝 Notes

- `trash` > `rm` (recoverable beats gone forever)
- When in doubt, ask before external actions
- Document errors in memory/YYYY-MM-DD.md

---

_This file is my cheat sheet. Update when setup changes._
