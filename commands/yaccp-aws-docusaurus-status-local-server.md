---
description: Check the status of the local development server
---

# AWS Docusaurus: Local Server Status

Check if the local development server is running and display its status.

## Configuration Storage

Read server info from `.claude/yaccp/aws-docusaurus/config.json`:

```json
{
  "localServer": {
    "PORT": "3000",
    "HOST": "localhost",
    "PID": "12345",
    "STARTED_AT": "2024-01-15T10:30:00Z"
  }
}
```

## Interactive Flow

### Step 1: Load Saved Configuration

Read existing config:
```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null
```

### Step 2: Check Server Status

#### Check saved PID
```bash
PID=$(jq -r '.localServer.PID // empty' .claude/yaccp/aws-docusaurus/config.json 2>/dev/null)
PORT=$(jq -r '.localServer.PORT // "3000"' .claude/yaccp/aws-docusaurus/config.json 2>/dev/null)
STARTED_AT=$(jq -r '.localServer.STARTED_AT // empty' .claude/yaccp/aws-docusaurus/config.json 2>/dev/null)
```

#### Verify process is running
```bash
if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
  SERVER_STATUS="Running"
else
  SERVER_STATUS="Stopped"
fi
```

#### Check port availability
```bash
PORT_INFO=$(lsof -i :${PORT} 2>/dev/null | grep LISTEN)
if [ -n "$PORT_INFO" ]; then
  PORT_STATUS="In use"
  ACTUAL_PID=$(echo "$PORT_INFO" | awk '{print $2}')
else
  PORT_STATUS="Available"
fi
```

#### Test HTTP response
```bash
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${HOST}:${PORT}/ 2>/dev/null)
if [ "$HTTP_STATUS" = "200" ]; then
  HEALTH="Healthy"
else
  HEALTH="Not responding"
fi
```

### Step 3: Get Process Details (if running)

```bash
# Get process info
ps -p ${PID} -o pid,ppid,%cpu,%mem,etime,command 2>/dev/null

# Get memory usage
ps -p ${PID} -o rss= 2>/dev/null | awk '{print $1/1024 " MB"}'
```

### Step 4: Display Results

#### If Server Running:
```
Local Development Server Status
================================

Status:      Running
URL:         http://${HOST}:${PORT}
PID:         ${PID}
Started:     ${STARTED_AT}
Uptime:      ${UPTIME}
Health:      ${HEALTH}

Process Info:
├── CPU:     ${CPU}%
├── Memory:  ${MEM} MB
└── Command: node docusaurus start

Quick Actions:
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-stop-local-server  - Stop the server
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy             - Deploy to AWS
```

#### If Server Stopped:
```
Local Development Server Status
================================

Status:      Stopped
Port ${PORT}: ${PORT_STATUS}

No local development server is currently running.

Quick Actions:
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-start-local-server - Start the server
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy             - Deploy to AWS
```

#### If Stale PID (process not running but config exists):
```
Local Development Server Status
================================

Status:      Stale (server crashed or was killed externally)
Last PID:    ${PID}
Port ${PORT}: ${PORT_STATUS}

The server appears to have stopped unexpectedly.
Configuration has been cleaned up.

Quick Actions:
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-start-local-server - Start the server
```

Clean up stale config:
```bash
# Update config to remove stale PID
jq '.localServer.PID = null | .localServer.STARTED_AT = null' \
  .claude/yaccp/aws-docusaurus/config.json > tmp.json && \
  mv tmp.json .claude/yaccp/aws-docusaurus/config.json
```

### Step 5: Offer Actions

Use AskUserQuestion:
"What would you like to do?"

If running:
- "Open in browser"
- "Stop the server"
- "View server logs"
- "Nothing, done"

If stopped:
- "Start the server"
- "Nothing, done"
