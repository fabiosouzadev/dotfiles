# Trigger Implementation Details

## 1. Telegram Mention Trigger

### Pattern
User sends: `@hermes coding-agent: <task description> [repo] [#issue]`

### Implementation (skill: telegram)
```python
# In telegram skill handler
def handle_coding_agent_mention(message_text, chat_id, thread_id):
    # Parse: @hermes coding-agent: fix auth bug myorg/repo #123
    pattern = r'@hermes\s+coding-agent:\s+(.+?)(?:\s+(\S+/\S+))?(?:\s+#(\d+))?$'
    match = re.match(pattern, message_text)
    
    if match:
        task_desc = match.group(1)
        repo = match.group(2)
        issue_num = match.group(3)
        
        # Invoke orchestrator
        hermes_run_skill("coding-orchestrator", {
            "trigger": "telegram",
            "task": task_desc,
            "repo": repo,
            "issue": issue_num,
            "chat_id": chat_id,
            "thread_id": thread_id
        })
```

### Hermes Gateway Integration
Configure in `~/.hermes/config.yaml`:
```yaml
telegram:
  allowed_chats: "644615401"
  extra:
    rich_messages: false
  webhook_path: "/webhook/telegram"
```

---

## 2. Webhook Trigger

### Endpoint
`POST https://hermes.fabiosouzadev.duckdns.org/webhook/github`

### Payload (GitHub Issue Labeled Event)
```json
{
  "action": "labeled",
  "issue": {
    "number": 42,
    "title": "Fix memory leak in websocket handler",
    "body": "WebSocket connections not closing properly...",
    "html_url": "https://github.com/myorg/backend/issues/42",
    "user": { "login": "fabiosouza" },
    "labels": [{"name": "coding-agent"}, {"name": "bug"}]
  },
  "repository": {
    "full_name": "myorg/backend",
    "html_url": "https://github.com/myorg/backend"
  },
  "label": { "name": "coding-agent" }
}
```

### Validation
```bash
# Verify HMAC signature
X-Hub-Signature-256: sha256=<hmac>
GITHUB_WEBHOOK_SECRET from .env
```

### Caddy Config
```caddy
hermes.fabiosouzadev.duckdns.org {
    handle /webhook/github {
        reverse_proxy 127.0.0.1:9119
    }
}
```

### Handler Logic
```python
def handle_github_webhook(payload, signature):
    if not verify_signature(payload, signature, GITHUB_WEBHOOK_SECRET):
        return 401
    
    if payload.get("action") == "labeled":
        label = payload.get("label", {}).get("name")
        if label == "coding-agent":
            issue = payload["issue"]
            repo = payload["repository"]["full_name"]
            
            hermes_run_skill("coding-orchestrator", {
                "trigger": "github",
                "task": f"{issue['title']}: {issue['body'][:500]}",
                "repo": repo,
                "issue": issue["number"],
                "url": issue["html_url"]
            })
```

---

## 3. Cron Trigger (Nightly)

### Schedule
`0 2 * * *` (02:00 UTC = 23:00 BRT)

### Hermes Cron Job
```json
{
  "id": "coding-orchestrator-nightly",
  "name": "Coding Orchestrator - Nightly Autonomous Coding",
  "prompt": "Find all open GitHub issues with label 'coding-agent' in fabiosouzadev/ repos. For each issue without an open PR from coding-orchestrator: create worktree, run Aider with budget $2, commit changes, open PR with summary. Skip issues already processed this week. Total budget: $5.",
  "skills": ["coding-orchestrator", "github"],
  "model": "omniroute/work",
  "schedule": { "kind": "cron", "expr": "0 2 * * *" },
  "enabled": true,
  "deliver": "origin",
  "origin": {
    "platform": "telegram",
    "chat_id": "644615401",
    "thread_id": "8876"
  }
}
```

### Processing Logic
```python
def process_nightly_queue():
    budget_remaining = 5.0
    per_task_budget = 2.0
    
    issues = github_search_issues(
        label="coding-agent",
        state="open",
        repos=["fabiosouzadev/*"]
    )
    
    for issue in issues:
        if budget_remaining < per_task_budget:
            break
            
        # Check if already processed
        if has_orchestrator_pr(issue):
            continue
            
        # Run orchestrator
        result = run_orchestrator({
            "trigger": "cron",
            "task": f"{issue['title']}: {issue['body'][:500]}",
            "repo": issue["repository"]["full_name"],
            "issue": issue["number"],
            "budget": per_task_budget
        })
        
        budget_remaining -= estimate_cost(result)
        
        # Report progress
        telegram_send(f"Processed #{issue['number']}: {result['status']}")
```

---

## 4. Trigger Configuration (config.yaml)

```yaml
triggers:
  telegram:
    enabled: true
    pattern: "@hermes coding-agent:"
    allowed_chats: ["644615401"]
    thread_id: "8876"
  
  webhook:
    enabled: true
    path: "/webhook/github"
    secret_env: "GITHUB_WEBHOOK_SECRET"
    verify_signature: true
  
  github:
    enabled: true
    label: "coding-agent"
    repos: ["fabiosouzadev/*"]
    check_existing_pr: true
  
  cron:
    enabled: true
    schedule: "0 2 * * *"
    timezone: "UTC"
    label_filter: "coding-agent"
    max_tasks_per_run: 3
    budget_usd: 5
```

---

## 5. Integration Points

### With Hermes Skills
- **telegram**: Mention parsing + delivery
- **github**: Issue search, PR creation, webhook handling
- **coding-orchestrator**: Core execution logic
- **notion**: Task tracking, context enrichment

### With External Services
- **OmniRoute**: LLM gateway (port 20128)
- **GitHub API**: Issues, PRs, webhooks
- **Telegram Bot API**: Messages, mentions
- **Notion MCP**: Context gathering, task updates