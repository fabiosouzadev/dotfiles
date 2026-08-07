---
name: linkedin-automation
description: Automate LinkedIn feed, messages, and job extraction.
version: "1.0.0"
tags: ["linkedin", "automation", "job-search", "web-scraping", "career"]
---

# LinkedIn Automation Skill

## Purpose
Automate LinkedIn interactions for job hunting, feed monitoring, and message management while handling authentication challenges.

## Capabilities
- Feed scraping (100+ posts with pagination)
- Direct message access and history retrieval
- Job posting extraction with structured data
- Authentication handling (manual VNC fallback)
- Search and filter by keywords/hashtags

## Prerequisites
- Active LinkedIn session (manual login via VNC if needed)
- Browser automation tools available
- `.env` with `LINKEDIN_PASSWORD` for automated login attempts

## Workflows

### 1. Feed Collection (100 Posts)
```bash
# Navigate to feed
browser_navigate("https://www.linkedin.com/feed/")

# Scroll and capture snapshots
for i in {1..15}:
    browser_scroll("down")
    sleep(2)
    browser_snapshot(full=true)
    read_file(snapshot_path)
```

### 2. Message Access
```bash
# Navigate to messaging
browser_navigate("https://www.linkedin.com/messaging/")

# Search for contact
browser_type(searchbox_ref, "Contact Name")
browser_press("Enter")

# Open conversation
browser_click(conversation_ref)
browser_press("Enter")

# Capture full thread
browser_snapshot(full=true)
```

### 3. Job Extraction Pattern
```json
{
  "id": "unique_identifier",
  "author": "Recruiter Name",
  "headline": "Role at Company",
  "text": "Full job description...",
  "time": "2h / 3d / 1sem",
  "reactions": "count",
  "comments": "count",
  "shares": "count",
  "email": "contact@company.com",
  "whatsapp": "(XX) XXXXX-XXXX",
  "link": "lnkd.in/xxx",
  "type": "VAGA|PROMOÇÃO|POST",
  "tags": ["Java", "Remote", "Senior", "AWS"]
}
```

## Authentication Handling
1. **Try automated navigation** first
2. **If security check appears**: "Estamos dando acesso à sua conta"
   - Wait 5-10 seconds
   - Retry navigation
3. **If persistent**: Manual login via VNC
   - User logs in manually
   - Session cookies persist for automation

## Known Challenges
- LinkedIn security verification triggers intermittently
- JavaScript-rendered content not fully captured in accessibility snapshots
- Feed loads ~5-10 posts per scroll
- Message threads require click + Enter to fully load
- Search box needs exact name match for best results

## Output Formats
- **Console**: Structured tables with engagement metrics
- **JSON**: `/tmp/linkedin_posts_100.json` for programmatic use
- **Markdown**: Human-readable reports with contact info

## Rate Limiting
- Scroll: 2-3 seconds between actions
- Snapshot: Full captures only when needed
- Navigation: Reuse session when possible

## Example Usage
```python
# Collect 100 posts from feed
posts = collect_feed_posts(target=100)

# Filter for remote Java positions
remote_java = [p for p in posts 
               if p['type']=='VAGA' 
               and 'Java' in p['tags'] 
               and 'Remoto' in p['tags']]

# Get message history
messages = get_message_history("Contact Name")

# Export to CSV/JSON
export_jobs(jobs, format="csv")
```

## Maintenance Notes
- Update selectors when LinkedIn UI changes
- Monitor for new security challenges
- Test authentication flow monthly
- Keep `.env` credentials secure