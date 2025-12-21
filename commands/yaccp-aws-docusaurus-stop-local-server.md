---
description: Stop the local development server
---

# AWS Docusaurus: Stop Local Server

Stop the running local development server.

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

### Step 2: Find Running Server

Try multiple methods to find the server:

#### Method 1: Check saved PID
```bash
PID=$(jq -r '.localServer.PID // empty' .claude/yaccp/aws-docusaurus/config.json 2>/dev/null)
if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
  echo "Found server with PID: $PID"
fi
```

#### Method 2: Check saved port
```bash
PORT=$(jq -r '.localServer.PORT // "3000"' .claude/yaccp/aws-docusaurus/config.json 2>/dev/null)
lsof -i :${PORT} 2>/dev/null | grep LISTEN
```

#### Method 3: Find any Docusaurus process
```bash
pgrep -f "docusaurus start" 2>/dev/null
pgrep -f "node.*docusaurus" 2>/dev/null
```

### Step 3: Confirm Stop

If server found, use AskUserQuestion:
"Found local server running on port ${PORT} (PID: ${PID}). Stop it?"
- "Yes, stop the server"
- "No, keep it running"

If no server found:
"No local development server is currently running."
- "Start a new server (/yaccp-aws-docusaurus:yaccp-aws-docusaurus-start-local-server)"
- "Done"

### Step 4: Stop the Server

Gracefully stop the server:
```bash
# Try graceful shutdown first
kill -TERM ${PID} 2>/dev/null

# Wait for process to end
sleep 2

# Force kill if still running
if kill -0 ${PID} 2>/dev/null; then
  kill -9 ${PID} 2>/dev/null
fi
```

Alternative: Kill by port:
```bash
kill -9 $(lsof -t -i :${PORT}) 2>/dev/null
```

### Step 5: Update Configuration

Clear server info from config:
```json
{
  "localServer": {
    "PORT": "3000",
    "HOST": "localhost",
    "PID": null,
    "STARTED_AT": null
  }
}
```

### Step 6: Display Results

```
Local Development Server Stopped
=================================

Port ${PORT} is now available.

Quick Actions:
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-start-local-server - Start the server again
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy             - Deploy to AWS
```

## Force Stop All

If multiple servers are running:
```bash
# Kill all Docusaurus processes
pkill -f "docusaurus start"

# Kill all node processes on common dev ports
for port in 3000 3001 3002; do
  lsof -ti :$port | xargs kill -9 2>/dev/null
done
```
