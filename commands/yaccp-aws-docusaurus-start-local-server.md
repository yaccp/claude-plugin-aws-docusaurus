---
description: Start the local development server for your Docusaurus site
---

# AWS Docusaurus: Start Local Server

Start the local development server to preview your Docusaurus site before deployment.

## Configuration Storage

Read configuration from `.claude/yaccp/aws-docusaurus/config.json`:

```json
{
  "localServer": {
    "PORT": "3000",
    "HOST": "localhost",
    "OPEN_BROWSER": true
  },
  "defaults": {
    "BUILD_DIR": "build"
  }
}
```

## Interactive Flow

### Step 1: Detect Project

Check if we're in a Docusaurus project:
```bash
ls package.json docusaurus.config.ts docusaurus.config.js 2>/dev/null
```

If not found, use AskUserQuestion:
"No Docusaurus project found in current directory. What would you like to do?"
- "Create a new project (/yaccp-aws-docusaurus:yaccp-aws-docusaurus-init)"
- "Navigate to existing project"
- "Cancel"

### Step 2: Load Saved Configuration

Read existing config:
```bash
cat .claude/yaccp/aws-docusaurus/config.json 2>/dev/null
```

### Step 3: Check and Prompt for Variables

For each variable, check in this order:
1. Environment variable
2. Saved config (`localServer` section)
3. Use defaults

**Optional (with defaults):**
- **PORT**: Default "3000"
- **HOST**: Default "localhost"
- **OPEN_BROWSER**: Default true

### Step 4: Check for Running Server

Check if a server is already running:
```bash
lsof -i :${PORT} 2>/dev/null | grep LISTEN
```

If server already running, use AskUserQuestion:
"A server is already running on port ${PORT}. What would you like to do?"
- "Stop it and start a new one"
- "Use a different port"
- "Cancel"

### Step 5: Install Dependencies (if needed)

Check and install dependencies:
```bash
if [ ! -d "node_modules" ]; then
  npm install
fi
```

### Step 6: Start the Server

Start the development server in background:
```bash
npm start -- --port ${PORT} --host ${HOST} ${OPEN_BROWSER:+--open}
```

Or for more control:
```bash
npx docusaurus start --port ${PORT} --host ${HOST}
```

### Step 7: Save Server Info

Save PID and port to config for status/stop commands:
```json
{
  "localServer": {
    "PORT": "${PORT}",
    "HOST": "${HOST}",
    "PID": "${PID}",
    "STARTED_AT": "${TIMESTAMP}"
  }
}
```

### Step 8: Display Results

```
Local Development Server Started
================================

URL:     http://${HOST}:${PORT}
PID:     ${PID}
Status:  Running

The server will hot-reload on file changes.

Quick Actions:
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-status-local-server - Check server status
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-stop-local-server   - Stop the server
- /yaccp-aws-docusaurus:yaccp-aws-docusaurus-deploy              - Deploy to AWS
```

## Common Issues

### Port Already in Use
```bash
# Find process using the port
lsof -i :3000
# Kill if needed
kill -9 $(lsof -t -i :3000)
```

### Node Modules Missing
```bash
npm install
```

### TypeScript Errors
```bash
npm run typecheck
```
