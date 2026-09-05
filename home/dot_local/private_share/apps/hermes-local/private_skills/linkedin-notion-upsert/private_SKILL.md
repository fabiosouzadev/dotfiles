--- 
name: linkedin-notion-upsert
description: Upsert LinkedIn to Notion DB using MCP with positional args.
trigger: When the user provides LinkedIn job JSON and wants to store it in a Notion database via Hermes MCP integration.
version: 1.0
author: Hermes Agent
--- 

# LinkedIn → Notion Upsert via MCP

This skill describes how to upsert LinkedIn job postings into a Notion database using the Model-Context-Protocol (MCP) integration in Hermes Agent via `model_tools.handle_function_call`.

## Key Corrections from Session

- **Import path**: Use `from model_tools import handle_function_call as tool_call` (not `hermes_tools`)
- **Call signature**: `tool_call` expects **positional arguments**: `(function_name_string, arguments_dict)`. Using keyword arguments like `name=` or `arguments=` causes `TypeError: handle_function_call() got an unexpected keyword argument 'name'`.
- **Response handling**: The `mcp__Notion__API_query_data_source` may return a string (e.g., error or "no results") instead of a dict. Always check if response is a dict before using `.get()`; if string, treat as zero matches.
- **Dependencies**: Install via `uv pip install --python /opt/hermes/.venv/bin/python pyyaml httpx requests` (system pip may be missing).

## Standard Workflow

1. Add `/opt/hermes` to `sys.path` to import `model_tools`.
2. Load LinkedIn jobs from JSON (e.g., `/opt/data/cache/job-process/linkedin_jobs_100.json`).
3. For each job:
   a. Query Notion for existing page by title (or URL) using `tool_call("mcp__Notion__API_query_data_source", {"data_source_id": DB_ID, "filter": {...}})`.
   b. If response is a dict and contains results, extract page ID for patch; else, prepare to create.
   c. Upsert: use `mcp__Notion__API_patch_page` for existing, `mcp__Notion__API_post_page` for new.
   d. Log result (e.g., "Criado: <title> → REJECTED (XXpts)" if Fit Engine score < 60).

## Pitfalls

- Assuming query response is always a dict → `'str' object has no attribute 'get'` error.
- Using keyword arguments with `tool_call` → unexpected keyword argument error.
- Missing dependencies → `No module named 'yaml'` etc. errors during tool loading.

## References

- See `references/notion_upsert_pipeline.py` for a working implementation.
- See `references/error-transcript.md` for annotated log of common errors and fixes.

--- 
# End of SKILL.md