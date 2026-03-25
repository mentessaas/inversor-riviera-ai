#!/usr/bin/env python3
"""
Agency Ops Admin Server
Serves the full admin panel + REST API that wraps ClawTeam CLI
Runs on port 8081 while clawteam board runs on 8080
"""
import json
import subprocess
import threading
import os
import re
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import signal

PORT = 8081
STATIC_FILE = "/tmp/agency_ops_admin.html"

# ─── ClawTeam CLI Wrapper ─────────────────────────────────────────────────────

def run_clawteam(args: list, timeout=30) -> dict:
    """Run a clawteam command and return parsed output."""
    try:
        result = subprocess.run(
            ["clawteam"] + args,
            capture_output=True,
            text=True,
            timeout=timeout,
            env={**os.environ, "NO_COLOR": "1"}
        )
        return {"ok": True, "stdout": result.stdout, "stderr": result.stderr, "returncode": result.returncode}
    except subprocess.TimeoutExpired:
        return {"ok": False, "error": "timeout"}
    except Exception as e:
        return {"ok": False, "error": str(e)}

def get_teams() -> list:
    """Get all teams."""
    r = run_clawteam(["team", "discover"])
    if not r.get("ok"):
        return []
    # Parse discover output
    teams = []
    for line in r["stdout"].split("\n"):
        if line.strip() and not line.startswith("-"):
            m = re.search(r"[\w-]+", line)
            if m:
                name = m.group()
                if name not in ["Teams", "team", "discover"]:
                    teams.append({"name": name, "description": ""})
    return teams

def get_team_data(team_name: str) -> dict:
    """Get full data for a team."""
    # Get team status
    r = run_clawteam(["team", "status", team_name])
    members = []
    if r.get("ok"):
        # Parse member lines
        for line in r["stdout"].split("\n"):
            parts = [p.strip() for p in line.split("│") if p.strip()]
            if len(parts) >= 4 and parts[0] not in ["Name", "━━━"]:
                name = parts[0].replace("┃","").replace("│","").strip()
                if name and not name.startswith("━"):
                    mtype = parts[2] if len(parts) > 2 else "general-purpose"
                    members.append({
                        "name": name,
                        "agentType": mtype,
                        "joinedAt": parts[3] if len(parts) > 3 else "",
                        "inboxCount": 0
                    })
    
    # Get tasks
    tasks = {"pending": [], "in_progress": [], "completed": [], "blocked": []}
    taskSummary = {"pending": 0, "in_progress": 0, "completed": 0, "blocked": 0, "total": 0}
    r = run_clawteam(["task", "list", team_name])
    if r.get("ok"):
        current_status = "pending"
        for line in r["stdout"].split("\n"):
            if "PENDING" in line: current_status = "pending"
            elif "IN PROGRESS" in line: current_status = "in_progress"
            elif "COMPLETED" in line: current_status = "completed"
            elif "BLOCKED" in line: current_status = "blocked"
            # Task lines have ID + Subject
            if "│" in line:
                parts = [p.strip() for p in line.split("│")]
                if len(parts) >= 2:
                    tid = re.search(r"#([a-f0-9]+)", parts[1])
                    if tid:
                        task_id = tid.group(1)
                        subject = parts[1].replace(f"#{task_id}", "").strip()
                        owner = parts[2].strip() if len(parts) > 2 else ""
                        tasks[current_status].append({"id": task_id, "subject": subject, "owner": owner})
    
    for k in tasks:
        taskSummary[k] = len(tasks[k])
        taskSummary["total"] += len(tasks[k])
    
    # Get messages (inbox log)
    messages = []
    r = run_clawteam(["inbox", "log", team_name])
    if r.get("ok"):
        for line in r["stdout"].split("\n"):
            if line.strip() and "→" in line:
                parts = line.split("→")
                if len(parts) >= 2:
                    messages.append({"from": parts[0].strip(), "to": parts[1].strip(), "content": "", "timestamp": ""})
    
    return {
        "team": {"name": team_name, "description": "", "leaderName": "lider", "createdAt": ""},
        "members": members,
        "tasks": tasks,
        "taskSummary": taskSummary,
        "messages": messages[-20:]  # Last 20 messages
    }

# ─── REST API Handler ─────────────────────────────────────────────────────────

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        
        if parsed.path == "/" or parsed.path == "/index.html":
            self.serve_file(STATIC_FILE, "text/html")
        elif parsed.path == "/api/teams":
            self.send_json(get_teams())
        elif parsed.path.startswith("/api/team/"):
            team = parsed.path.split("/api/team/")[1]
            self.send_json(get_team_data(team))
        elif parsed.path == "/api/overview":
            teams = get_teams()
            overview = []
            for t in teams:
                data = get_team_data(t["name"])
                total_inbox = sum(m.get("inboxCount", 0) for m in data.get("members", []))
                overview.append({
                    "name": t["name"],
                    "description": t.get("description", ""),
                    "members": len(data.get("members", [])),
                    "tasks": data.get("taskSummary", {}).get("total", 0),
                    "pendingMessages": total_inbox
                })
            self.send_json(overview)
        else:
            self.send_error(404)
    
    def do_POST(self):
        parsed = urlparse(self.path)
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8") if length > 0 else "{}"
        try:
            data = json.loads(body) if body else {}
        except:
            data = {}
        
        team = data.get("team", "")
        
        if parsed.path == "/api/task" and team:
            # Create task
            r = run_clawteam(["task", "create", team, data.get("subject", "No subject"),
                "-d", data.get("description", ""),
                "-o", data.get("owner", "")])
            self.send_json({"ok": r.get("ok", False), "result": r.get("stdout", "")})
        
        elif "/api/task/" in parsed.path and "status" in parsed.path and team:
            # Update task status
            task_id = parsed.path.split("/api/task/")[1].split("/")[0]
            r = run_clawteam(["task", "update", team, task_id, "--status", data.get("status", "pending")])
            self.send_json({"ok": r.get("ok", False)})
        
        elif "/api/task/" in parsed.path and "delete" in parsed.path and team:
            task_id = parsed.path.split("/api/task/")[1].split("/")[0]
            self.send_json({"ok": True, "note": "Delete via task update not directly supported — mark as blocked or completed"})
        
        elif parsed.path == "/api/spawn" and team:
            # Spawn agent
            r = run_clawteam(["spawn",
                "--team", team,
                "--agent-name", data.get("agentName", "agent"),
                "--agent-type", data.get("agentType", "general-purpose"),
                "--repo", os.path.expanduser("~/.openclaw/workspace"),
                "--task", data.get("task", f"Eres {data.get('agentName','agent')}. Trabaja en el equipo {team}.")
            ])
            self.send_json({"ok": r.get("ok", False), "result": r.get("stdout", "")})
        
        elif parsed.path == "/api/lifecycle" and team:
            # Lifecycle action
            r = run_clawteam(["lifecycle", data.get("action", "idle"), team, data.get("agentName", "")])
            self.send_json({"ok": r.get("ok", False)})
        
        elif parsed.path == "/api/inbox/send" and team:
            r = run_clawteam(["inbox", "send", team, data.get("to", ""), data.get("message", "")])
            self.send_json({"ok": r.get("ok", False)})
        
        elif parsed.path == "/api/team/create":
            r = run_clawteam(["team", "spawn-team", data.get("name", "new-team"),
                "-d", data.get("description", ""),
                "-n", data.get("leader", "leader")])
            self.send_json({"ok": r.get("ok", False)})
        
        else:
            self.send_json({"ok": False, "error": "unknown endpoint"})
    
    def serve_file(self, path, content_type):
        try:
            with open(path, "rb") as f:
                content = f.read()
            self.send_response(200)
            self.send_header("Content-Type", f"{content_type}; charset=utf-8")
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        except FileNotFoundError:
            self.send_error(404, "File not found")
    
    def send_json(self, data):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)
    
    def log_message(self, format, *args):
        pass  # Silent

def serve(port):
    server = HTTPServer(("127.0.0.1", port), Handler)
    print(f"Agency Ops Admin Server running on http://127.0.0.1:{port}")
    server.serve_forever()

if __name__ == "__main__":
    serve(PORT)
