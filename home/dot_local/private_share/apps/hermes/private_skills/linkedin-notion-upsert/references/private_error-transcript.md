# Error Transcript: LinkedIn to Notion Upsert Pipeline

Common errors observed during execution and their fixes:

## 1. Missing YAML/httpx/requests modules
**Error:**
```
Could not import tool module tools.vision_tools: No module named 'httpx'
Could not import tool module tools.web_tools: No module named 'httpx'
Could not import tool module tools.x_search_tool: No module named 'requests'
```
**Fix:**
Install dependencies in Hermes venv:
```bash
/opt/hermes/.venv/bin/python -m pip install pyyaml httpx requests
# or preferably:
uv pip install --python /opt/hermes/.venv/bin/python pyyaml httpx requests
```

## 2. Wrong import path for tool_call
**Error (early in session):**
```
Erro ao processar ...: No module named 'hermes_tools'
```
**Fix:**
Changed import from `hermes_tools` to `model_tools`:
```python
# Before (incorrect):
# from hermes_tools import ... 
# After (correct):
from model_tools import handle_function_call as tool_call
```

## 3. Wrong tool_call signature (keyword args)
**Error:**
```
handle_function_call() got an unexpected keyword argument 'name'
```
**Fix:**
`handle_function_call` expects positional arguments:
```python
# Wrong:
tool_call(name="mcp__Notion__API_query_data_source", arguments={...})
# Correct:
tool_call("mcp__Notion__API_query_data_source", {...})
```

## 4. Query response treated as dict when it's a string
**Error:**
```
Erro buscando página existente: 'str' object has no attribute 'get'
```
**Explanation:**
The MCP `query_data_source` call sometimes returns a plain string (e.g., an error message or "no results") instead of a dict with a `results` key.
**Fix:**
Always check the type before using `.get()`:
```python
result = tool_call("mcp__Notion__API_query_data_source", {...})
if isinstance(result, dict) and result.get("results"):
    page_id = result["results"][0].get("id")
else:
    # treat as no match
    page_id = None
```

## 5. Duplicate page creation
**Symptom:**
Seeing "Criado: ..." for the same job repeatedly instead of "Atualizado: ...".
**Cause:**
Due to the string-response issue above, the lookup fails and the script always creates a new page.
**Mitigation:**
- Improve the filter (e.g., also filter by URL or company+title)
- Accept that duplicates may occur and rely on manual cleanup or Notion's native deduplication (if enabled)
- Consider adding a hash-based unique property (e.g., LinkedIn URL) to detect exact matches

## 6. Fit Engine rejection
**Expected log line:**
```
Criado: Backend Software Developer (Remote) → REJECTED (60pts)
```
This is not an error in the pipeline; it indicates the job was successfully upserted to Notion but then rejected by the downstream Fit Engine scoring (score < 60). The pipeline's job is complete at the Notion upsert step.

--- 
End of error transcript