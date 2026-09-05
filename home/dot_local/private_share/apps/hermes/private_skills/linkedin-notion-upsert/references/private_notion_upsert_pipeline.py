#!/opt/hermes/.venv/bin/python3
"""Job Process - Notion Upsert Pipeline - Lê vagas do JSON e grava no Notion via MCP"""

import json
import os
import sys

# Add /opt/hermes to sys.path to import model_tools
sys.path.insert(0, '/opt/hermes')

from model_tools import handle_function_call as tool_call

NOTION_DATABASE_ID = "cb9a134b-ad3b-80f7-ba8f-000b99e1ef01"
LINKEDIN_JSON_PATH = "/opt/data/cache/job-process/linkedin_jobs_100.json"

def main():
    print("Iniciando pipeline de upsert Notion")
    
    # Load LinkedIn jobs
    with open(LINKEDIN_JSON_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    jobs = data.get("jobs", [])
    print(f"Total de vagas no JSON: {len(jobs)}")
    
    # Simple filter: approve all for now (in real scenario, apply Fit Engine logic)
    approved_jobs = jobs  # Placeholder - in reality would filter by fit score
    print(f"Vagas aprovadas: {len(approved_jobs)}")
    
    created = 0
    updated = 0
    skipped = 0
    
    for job in approved_jobs:
        title = job.get("title", "")
        if not title:
            continue
            
        try:
            # Query for existing page by title
            query_result = tool_call("mcp__Notion__API_query_data_source", {
                "data_source_id": NOTION_DATABASE_ID,
                "filter": {
                    "property": "Job Title",
                    "title": {
                        "equals": title
                    }
                }
            })
            
            # Handle response - could be string or dict
            existing_page_id = None
            if isinstance(query_result, dict):
                # Parse the actual response structure from Notion MCP
                results = query_result.get("results", [])
                if results:
                    existing_page_id = results[0].get("id")
            
            # Prepare page properties
            properties = {
                "Job Title": {"title": [{"text": {"content": title}}]},
                "Company": {"rich_text": [{"text": {"content": job.get("company", "")}}]},
                "Location": {"rich_text": [{"text": {"content": job.get("location", "")}}]},
                "URL": {"url": job.get("url", "")},
                "Modality": {"select": {"name": job.get("modality", "")}} if job.get("modality") else None,
                "Remote": {"checkbox": job.get("remote", False)},
                "Rate": {"rich_text": [{"text": {"content": job.get("rate", "") or ""}}]},
                "Description": {"rich_text": [{"text": {"content": job.get("description", "")}}]}
            }
            # Remove None values
            properties = {k: v for k, v in properties.items() if v is not None}
            
            if existing_page_id:
                # Update existing page
                tool_call("mcp__Notion__API_patch_page", {
                    "page_id": existing_page_id,
                    "properties": properties
                })
                print(f"Atualizado: {title}")
                updated += 1
            else:
                # Create new page
                tool_call("mcp__Notion__API_post_page", {
                    "parent": {"database_id": NOTION_DATABASE_ID},
                    "properties": properties
                })
                print(f"Criado: {title}")
                created += 1
                
        except Exception as e:
            print(f"Erro ao processar {title}: {e}")
            skipped += 1
    
    print(f"Concluído: {created} criados, {updated} atualizados, {skipped} pulados")

if __name__ == "__main__":
    main()