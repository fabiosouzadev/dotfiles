#!/usr/bin/env python3
"""
Cron job for Job Triage System:
1. Auto-apply for cards in "Preparar Candidatura" stage
2. Process responded cards (move to "Em processo")
"""

import os
import sys
import json
import requests
import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
from email.utils import formataddr
from datetime import datetime
from pathlib import Path
import time

# Add skill directory to path
SKILL_DIR = Path(__file__).parent.parent
SCRIPTS_DIR = Path(__file__).parent
sys.path.insert(0, str(SCRIPTS_DIR))

# Configuration
NOTION_API_KEY = os.environ.get("NOTION_API_KEY") or os.environ.get("NOTION_TOKEN")
DATABASE_ID = "b45a134b-ad3b-83c5-a4e8-07d467d825ba"  # From context
NOTION_VERSION = "2025-09-03"
GMAIL_USER = "fabiovanderlei.developer@gmail.com"
GMAIL_APP_PASSWORD = os.environ.get("GMAIL_APP_PASSWORD")
CV_PATH = "/opt/data/home/documents/curriculo_atualizado_ats.pdf"
LINKEDIN_URL = "https://www.linkedin.com/in/fabiosouzadev/"

# Rate limiting
LAST_NOTION_REQUEST = 0
NOTION_RATE_LIMIT = 1.0 / 3.0  # 3 req/s max

def notion_request(method, endpoint, json_data=None):
    """Make a rate-limited request to Notion API"""
    global LAST_NOTION_REQUEST
    
    # Rate limit: max 3 req/s
    elapsed = time.time() - LAST_NOTION_REQUEST
    if elapsed < NOTION_RATE_LIMIT:
        time.sleep(NOTION_RATE_LIMIT - elapsed)
    
    url = f"https://api.notion.com/v1/{endpoint}"
    headers = {
        "Authorization": f"Bearer {NOTION_API_KEY}",
        "Notion-Version": NOTION_VERSION,
        "Content-Type": "application/json"
    }
    
    try:
        if method == "POST":
            response = requests.post(url, headers=headers, json=json_data)
        elif method == "PATCH":
            response = requests.patch(url, headers=headers, json=json_data)
        else:
            raise ValueError(f"Unsupported method: {method}")
        
        LAST_NOTION_REQUEST = time.time()
        
        if response.status_code >= 400:
            print(f"❌ Notion API error {response.status_code}: {response.text}")
            return None
        
        return response.json()
    except Exception as e:
        print(f"❌ Notion request failed: {e}")
        return None

def query_notion_pages(filter_conditions):
    """Query Notion database with filter conditions using data_source endpoint"""
    payload = {
        "filter": {
            "and": filter_conditions
        },
        "page_size": 100
    }
    
    # Use data_source_id for queries (Notion API v2025-09-03)
    result = notion_request("POST", f"data_sources/{DATABASE_ID}/query", payload)
    if result:
        return result.get("results", [])
    return []

def update_notion_page(page_id, properties):
    """Update a Notion page with new properties"""
    payload = {
        "properties": properties
    }
    return notion_request("PATCH", f"pages/{page_id}", payload)

def send_application_email(job_data):
    """Send application email via Python smtplib"""
    email = job_data.get("email")
    if not email:
        print("❌ No email found for job")
        return False
    
    title = job_data.get("title", "Vaga")
    company = job_data.get("company", "Empresa")
    url = job_data.get("url", "")
    score = job_data.get("score", 0)
    
    print(f"📧 Sending application to {email} for {title} at {company}")
    
    # Subject
    subject = f"Candidatura: {title} - {company} (Tech Lead/Arquiteto Sênior - PJ Remoto)"
    
    # HTML body
    body_html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }}
        @media (prefers-color-scheme: dark) {{ body {{ background: #1a1a1a; color: #e0e0e0; }} }}
        strong {{ font-weight: 600; color: inherit; }}
        a {{ color: #4a90d9; text-decoration: none; }}
        a:hover {{ text-decoration: underline; }}
        ul {{ padding-left: 20px; }}
        li {{ margin-bottom: 8px; }}
        .signature {{ margin-top: 30px; padding-top: 20px; border-top: 1px solid #444; }}
        .contact {{ font-size: 0.9em; color: #888; }}
    </style>
</head>
<body>
    <p>Olá,</p>
    <p>Tenho grande interesse na vaga de <strong>{title}</strong> na <strong>{company}</strong>.</p>
    <p>Sou <strong>Tech Lead/Arquiteto de Software Sênior</strong> com 14+ anos de experiência, especialista em:</p>
    <ul>
        <li><strong>Node.js/NestJS, Java/Spring Boot, Python/Django</strong> (stack core)</li>
        <li><strong>AWS, GCP, Azure, Kubernetes</strong> (Cloud-Native, Serverless, Microsserviços)</li>
        <li><strong>Fintech, Gateways de Pagamento, PCI-DSS</strong> (domínio principal)</li>
        <li><strong>IA Generativa/LLMs, Langfuse</strong> (foco estratégico recente)</li>
    </ul>
    <p>Experiência liderando times multidisciplinares, arquitetando sistemas de alta disponibilidade (99.99%), garantindo conformidade PCI-DSS e integrando IA em produtos.</p>
    <p><strong>Meu LinkedIn:</strong> <a href="{LINKEDIN_URL}">https://www.linkedin.com/in/fabiosouzadev/</a></p>
    <p><strong>CV em anexo</strong> para sua avaliação.</p>
    <p>Disponível para <strong>PJ 100% remoto</strong> (base em Londrina/PR).</p>
    <p>Agradeço a oportunidade e fico à disposição para conversar.</p>
    <div class="signature">
        <p><strong>Fábio Souza</strong></p>
        <p class="contact">
            <a href="{LINKEDIN_URL}">https://www.linkedin.com/in/fabiosouzadev/</a><br>
            {GMAIL_USER}<br>
            +55 43 98426-0099
        </p>
    </div>
</body>
</html>"""
    
    # Plain text body
    body_text = f"""Olá,

Tenho grande interesse na vaga de {title} na {company}.

Sou Tech Lead/Arquiteto de Software Sênior com 14+ anos de experiência, especialista em:
- Node.js/NestJS, Java/Spring Boot, Python/Django (stack core)
- AWS, GCP, Azure, Kubernetes (Cloud-Native, Serverless, Microsserviços)
- Fintech, Gateways de Pagamento, PCI-DSS (domínio principal)
- IA Generativa/LLMs, Langfuse (foco estratégico recente)

Experiência liderando times multidisciplinares, arquitetando sistemas de alta disponibilidade (99.99%), garantindo conformidade PCI-DSS e integrando IA em produtos.

Meu LinkedIn: {LINKEDIN_URL}
CV em anexo para sua avaliação.

Disponível para PJ 100% remoto (base em Londrina/PR).

Agradeço a oportunidade e fico à disposição para conversar.

Atenciosamente,
Fábio Souza
{LINKEDIN_URL}
{GMAIL_USER}
+55 43 98426-0099"""

    # Build message: multipart/mixed > multipart/alternative + attachment
    msg = MIMEMultipart("mixed")
    msg["Subject"] = subject
    msg["From"] = formataddr(("Fábio Souza", GMAIL_USER))
    msg["To"] = email

    # Alternative part (text + html)
    alt = MIMEMultipart("alternative")
    alt.attach(MIMEText(body_text, "plain", "utf-8"))
    alt.attach(MIMEText(body_html, "html", "utf-8"))
    msg.attach(alt)

    # Attachment
    try:
        with open(CV_PATH, "rb") as f:
            attach = MIMEApplication(f.read(), _subtype="pdf")
            attach.add_header("Content-Disposition", "attachment", filename=os.path.basename(CV_PATH))
            msg.attach(attach)
    except Exception as e:
        print(f"❌ Failed to attach CV: {e}")
        return False

    # Send
    context = ssl.create_default_context()
    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465, context=context) as server:
            server.login(GMAIL_USER, GMAIL_APP_PASSWORD)
            server.send_message(msg)
        print(f"✅ Application sent successfully to {email}")
        return True
    except Exception as e:
        print(f"❌ Failed to send email: {e}")
        return False

def get_page_property_value(prop):
    """Extract value from Notion property object"""
    if not prop:
        return None
    
    prop_type = prop.get("type")
    if prop_type == "title":
        title_array = prop.get("title", [])
        if title_array:
            return title_array[0].get("text", {}).get("content", "")
    elif prop_type == "rich_text":
        rich_array = prop.get("rich_text", [])
        if rich_array:
            return rich_array[0].get("text", {}).get("content", "")
    elif prop_type == "email":
        return prop.get("email")
    elif prop_type == "number":
        return prop.get("number")
    elif prop_type == "select":
        select_obj = prop.get("select")
        if select_obj:
            return select_obj.get("name")
    elif prop_type == "multi_select":
        multi_array = prop.get("multi_select", [])
        return [item.get("name") for item in multi_array]
    elif prop_type == "checkbox":
        return prop.get("checkbox", False)
    elif prop_type == "date":
        date_obj = prop.get("date")
        if date_obj:
            return date_obj.get("start")
    elif prop_type == "url":
        return prop.get("url")
    
    return None

def extract_job_data_from_page(page):
    """Extract job data from Notion page properties"""
    props = page.get("properties", {})

    # Extract basic properties
    title_prop = props.get("Name", {})
    title = get_page_property_value(title_prop) or "Vaga sem título"

    empresa_prop = props.get("Empresa", {})
    empresa = get_page_property_value(empresa_prop) or ""

    url_prop = props.get("Link Vaga", {})
    url = get_page_property_value(url_prop) or ""

    desc_prop = props.get("Descrição", {})
    content = get_page_property_value(desc_prop) or ""

    # Score: try to extract from "Anotações Etapa" text (format: "Triagem automática - score XX")
    anotacoes_prop = props.get("Anotações Etapa", {})
    anotacoes = get_page_property_value(anotacoes_prop) or ""
    score = 0
    import re
    score_match = re.search(r'score\s+(\d+)', anotacoes, re.IGNORECASE)
    if score_match:
        score = int(score_match.group(1))

    # Email: extract from description or link vaga content
    email = ""
    for text_source in [content, url]:
        if text_source:
            email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
            matches = re.findall(email_pattern, text_source)
            # Filter out common non-personal emails
            filtered = [m for m in matches if not any(x in m.lower() for x in ['noreply', 'no-reply', 'support', 'help', 'info@', 'contact@', 'admin@', 'recruitment@', 'hr@', 'jobs@', 'careers@', 'talent@', 'hiring@'])]
            email = filtered[0] if filtered else (matches[0] if matches else "")
            if email:
                break

    responded_prop = props.get("Respondeu?", {})
    responded = get_page_property_value(responded_prop) or False

    etapa_prop = props.get("Etapa Atual", {})
    etapa_atual = get_page_property_value(etapa_prop) or ""

    return {
        "id": page.get("id"),
        "title": title,
        "company": empresa,
        "url": url,
        "content": content,
        "score": score,
        "email": email,
        "responded": bool(responded),
        "etapa_atual": etapa_atual
    }

def main():
    print("🚀 Starting Job Triage Cron Job")
    print(f"⏰ {datetime.now().isoformat()}")
    
    if not NOTION_API_KEY:
        print("❌ NOTION_API_KEY not set")
        return 1
    
    if not GMAIL_APP_PASSWORD:
        print("❌ GMAIL_APP_PASSWORD not set")
        return 1
    
    # Task 1: Auto-apply for cards in "Preparar candidatura" stage
    print("\n📋 TASK 1: Processing 'Preparar candidatura' cards")
    prepar_candidatura_filter = [
        {
            "property": "Etapa Atual",
            "select": {
                "equals": "Preparar candidatura"
            }
        }
    ]
    
    prepar_pages = query_notion_pages(prepar_candidatura_filter)
    print(f"Found {len(prepar_pages)} cards in 'Preparar candidatura' stage")
    
    auto_applied_count = 0
    no_email_count = 0
    
    for page in prepar_pages:
        job_data = extract_job_data_from_page(page)
        page_id = job_data["id"]
        
        print(f"\n📄 Processing: {job_data['title']} at {job_data['company']} (Score: {job_data['score']})")
        
        if job_data["email"]:
            print(f"📧 Email found: {job_data['email']}")
            if send_application_email(job_data):
                # Update Notion page
                update_properties = {
                    "Etapa Atual": {"select": {"name": "Aguardando retorno"}},
                    "Data Candidatura": {"date": {"start": datetime.now().strftime("%Y-%m-%d")}},
                    "Canal Envio": {"multi_select": [{"name": "Email"}]},
                    "CV Enviado": {"checkbox": True},
                    "Anotações Etapa": {"rich_text": [{"text": {"content": f"Auto-aplicado via cron job em {datetime.now().isoformat()}"}}]}
                }
                result = update_notion_page(page_id, update_properties)
                if result:
                    print("✅ Page updated to 'Aguardando retorno'")
                    auto_applied_count += 1
                else:
                    print("❌ Failed to update page")
            else:
                print("❌ Failed to send email")
                # Update to Sem email? No, keep in Preparar Candidatura for manual retry
        else:
            print("📭 No email found")
            # Update to Sem email
            update_properties = {
                "Etapa Atual": {"select": {"name": "Sem email"}},
                "Anotações Etapa": {"rich_text": [{"text": {"content": f"Sem email para candidatura auto em {datetime.now().isoformat()}"}}]}
            }
            result = update_notion_page(page_id, update_properties)
            if result:
                print("✅ Page updated to 'Sem email'")
                no_email_count += 1
            else:
                print("❌ Failed to update page")
    
    # Task 2: Process responded cards
    print("\n📋 TASK 2: Processing responded cards")
    responded_filter = [
        {
            "property": "Respondeu?",
            "checkbox": {
                "equals": True
            }
        },
        {
            "property": "Etapa Atual",
            "select": {
                "does_not_equal": "Em processo"
            }
        },
        {
            "property": "archived",
            "checkbox": {
                "equals": False
            }
        }
    ]
    
    # Remove archived filter for now
    responded_filter = [
        {
            "property": "Respondeu?",
            "checkbox": {
                "equals": True
            }
        },
        {
            "property": "Etapa Atual",
            "select": {
                "does_not_equal": "Em processo"
            }
        }
    ]
    
    responded_pages = query_notion_pages(responded_filter)
    print(f"Found {len(responded_pages)} responded cards not in 'Em processo'")
    
    processed_count = 0
    for page in responded_pages:
        job_data = extract_job_data_from_page(page)
        page_id = job_data["id"]
        
        print(f"\n📄 Processing responded card: {job_data['title']} at {job_data['company']}")
        
        # Update Notion page
        update_properties = {
            "Etapa Atual": {"select": {"name": "Em processo"}},
            "Respondeu?": {"checkbox": False},
            "Anotações Etapa": {"rich_text": [{"text": {"content": f"Resposta detectada - movido para Em processo em {datetime.now().isoformat()}"}}]}
        }
        result = update_notion_page(page_id, update_properties)
        if result:
            print("✅ Page updated to 'Em processo' and Respondeu? reset")
            processed_count += 1
        else:
            print("❌ Failed to update page")
    
    # Summary
    print("\n📊 SUMMARY")
    print(f"   Auto-applied: {auto_applied_count}")
    print(f"   Moved to 'Sem email': {no_email_count}")
    print(f"   Processed responses: {processed_count}")
    print("✅ Cron job completed")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())