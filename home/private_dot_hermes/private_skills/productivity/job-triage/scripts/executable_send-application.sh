#!/bin/bash
# send-application.sh
# Envia candidatura por email via Python smtplib (Gmail) com CV anexado e LinkedIn no body
# MIME: multipart/mixed > multipart/alternative (text/plain + text/html) + attachment (PDF)

set -euo pipefail

# Uso: send-application.sh <email_destino> <titulo_vaga> <empresa> <url_vaga> <score> <cv_path> <linkedin_url>

EMAIL_DESTINO="${1:-}"
TITULO_VAGA="${2:-}"
EMPRESA="${3:-}"
URL_VAGA="${4:-}"
SCORE="${5:-}"
CV_PATH="${6:-/opt/data/home/documents/curriculo_atualizado_ats.pdf}"
LINKEDIN_URL="${7:-https://www.linkedin.com/in/fabiosouzadev/}"

if [[ -z "$EMAIL_DESTINO" || -z "$TITULO_VAGA" || -z "$EMPRESA" ]]; then
    echo "Uso: $0 <email_destino> <titulo_vaga> <empresa> <url_vaga> <score> [cv_path] [linkedin_url]"
    exit 1
fi

# Verificar se CV existe
if [[ ! -f "$CV_PATH" ]]; then
    echo "❌ CV não encontrado: $CV_PATH"
    exit 1
fi

# Verificar Himalaya (caminho completo)
HIMALAYA="/opt/data/home/.local/bin/himalaya"
if [[ ! -f "$HIMALAYA" ]]; then
    echo "❌ Himalaya não encontrado em $HIMALAYA"
    exit 1
fi

# Preparar body do email (HTML para renderizar negrito, links, etc.)
# IMPORTANT: unquoted heredocs (<<TEXTEOF) para bash expandir ${TITULO_VAGA}, ${EMPRESA}
BODY_HTML=$(cat <<HTMLEOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
        @media (prefers-color-scheme: dark) { body { background: #1a1a1a; color: #e0e0e0; } }
        strong { font-weight: 600; color: inherit; }
        a { color: #4a90d9; text-decoration: none; }
        a:hover { text-decoration: underline; }
        ul { padding-left: 20px; }
        li { margin-bottom: 8px; }
        .signature { margin-top: 30px; padding-top: 20px; border-top: 1px solid #444; }
        .contact { font-size: 0.9em; color: #888; }
    </style>
</head>
<body>
    <p>Olá,</p>
    <p>Tenho grande interesse na vaga de <strong>${TITULO_VAGA}</strong> na <strong>${EMPRESA}</strong>.</p>
    <p>Sou <strong>Tech Lead/Arquiteto de Software Sênior</strong> com 14+ anos de experiência, especialista em:</p>
    <ul>
        <li><strong>Node.js/NestJS, Java/Spring Boot, Python/Django</strong> (stack core)</li>
        <li><strong>AWS, GCP, Azure, Kubernetes</strong> (Cloud-Native, Serverless, Microsserviços)</li>
        <li><strong>Fintech, Gateways de Pagamento, PCI-DSS</strong> (domínio principal)</li>
        <li><strong>IA Generativa/LLMs, Langfuse</strong> (foco estratégico recente)</li>
    </ul>
    <p>Experiência liderando times multidisciplinares, arquitetando sistemas de alta disponibilidade (99.99%), garantindo conformidade PCI-DSS e integrando IA em produtos.</p>
    <p><strong>Meu LinkedIn:</strong> <a href="https://www.linkedin.com/in/fabiosouzadev/">https://www.linkedin.com/in/fabiosouzadev/</a></p>
    <p><strong>CV em anexo</strong> para sua avaliação.</p>
    <p>Disponível para <strong>PJ 100% remoto</strong> (base em Londrina/PR).</p>
    <p><strong>Pretensão salarial: R$ 15.000,00 (PJ)</strong></p>
    <p>Agradeço a oportunidade e fico à disposição para conversar.</p>
    <div class="signature">
        <p><strong>Fábio Souza</strong></p>
        <p class="contact">
            <a href="https://www.linkedin.com/in/fabiosouzadev/">https://www.linkedin.com/in/fabiosouzadev/</a><br>
            fabiovanderlei.developer@gmail.com<br>
            +55 43 98426-0099
        </p>
    </div>
</body>
</html>
HTMLEOF
)

# Body plain text fallback
BODY_TEXT=$(cat <<TEXTEOF
Olá,

Tenho grande interesse na vaga de ${TITULO_VAGA} na ${EMPRESA}.

Sou Tech Lead/Arquiteto de Software Sênior com 14+ anos de experiência, especialista em:
- Node.js/NestJS, Java/Spring Boot, Python/Django (stack core)
- AWS, GCP, Azure, Kubernetes (Cloud-Native, Serverless, Microsserviços)
- Fintech, Gateways de Pagamento, PCI-DSS (domínio principal)
- IA Generativa/LLMs, Langfuse (foco estratégico recente)

Experiência liderando times multidisciplinares, arquitetando sistemas de alta disponibilidade (99.99%), garantindo conformidade PCI-DSS e integrando IA em produtos.

Meu LinkedIn: https://www.linkedin.com/in/fabiosouzadev/
CV em anexo para sua avaliação.

Disponível para PJ 100% remoto (base em Londrina/PR).

Pretensão salarial: R$ 15.000,00 (PJ)

Agradeço a oportunidade e fico à disposição para conversar.

Atenciosamente,
Fábio Souza
https://www.linkedin.com/in/fabiosouzadev/
fabiovanderlei.developer@gmail.com
+55 43 98426-0099
TEXTEOF
)

# Enviar via Python smtplib (controle total do MIME)
echo "📧 Enviando candidatura para $EMAIL_DESTINO..."

python3 <<PYEOF
import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
from email.utils import formataddr
import os

# Config
smtp_server = "smtp.gmail.com"
port = 465
username = "fabiovanderlei.developer@gmail.com"
password = os.environ.get("GMAIL_APP_PASSWORD", "").strip()
to_email = "$EMAIL_DESTINO"
subject = f"Candidatura: $TITULO_VAGA - $EMPRESA (Tech Lead/Arquiteto Sênior - PJ Remoto)"
cv_path = "$CV_PATH"

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
    <p>Tenho grande interesse na vaga de <strong>$TITULO_VAGA</strong> na <strong>$EMPRESA</strong>.</p>
    <p>Sou <strong>Tech Lead/Arquiteto de Software Sênior</strong> com 14+ anos de experiência, especialista em:</p>
    <ul>
        <li><strong>Node.js/NestJS, Java/Spring Boot, Python/Django</strong> (stack core)</li>
        <li><strong>AWS, GCP, Azure, Kubernetes</strong> (Cloud-Native, Serverless, Microsserviços)</li>
        <li><strong>Fintech, Gateways de Pagamento, PCI-DSS</strong> (domínio principal)</li>
        <li><strong>IA Generativa/LLMs, Langfuse</strong> (foco estratégico recente)</li>
    </ul>
    <p>Experiência liderando times multidisciplinares, arquitetando sistemas de alta disponibilidade (99.99%), garantindo conformidade PCI-DSS e integrando IA em produtos.</p>
    <p><strong>Meu LinkedIn:</strong> <a href="https://www.linkedin.com/in/fabiosouzadev/">https://www.linkedin.com/in/fabiosouzadev/</a></p>
    <p><strong>CV em anexo</strong> para sua avaliação.</p>
    <p>Disponível para <strong>PJ 100% remoto</strong> (base em Londrina/PR).</p>
    <p><strong>Pretensão salarial: R$ 15.000,00 (PJ)</strong></p>
    <p>Agradeço a oportunidade e fico à disposição para conversar.</p>
    <div class="signature">
        <p><strong>Fábio Souza</strong></p>
        <p class="contact">
            <a href="https://www.linkedin.com/in/fabiosouzadev/">https://www.linkedin.com/in/fabiosouzadev/</a><br>
            fabiovanderlei.developer@gmail.com<br>
            +55 43 98426-0099
        </p>
    </div>
</body>
</html>"""

# Plain text body
body_text = f"""Olá,

Tenho grande interesse na vaga de $TITULO_VAGA na $EMPRESA.

Sou Tech Lead/Arquiteto de Software Sênior com 14+ anos de experiência, especialista em:
- Node.js/NestJS, Java/Spring Boot, Python/Django (stack core)
- AWS, GCP, Azure, Kubernetes (Cloud-Native, Serverless, Microsserviços)
- Fintech, Gateways de Pagamento, PCI-DSS (domínio principal)
- IA Generativa/LLMs, Langfuse (foco estratégico recente)

Experiência liderando times multidisciplinares, arquitetando sistemas de alta disponibilidade (99.99%), garantindo conformidade PCI-DSS e integrando IA em produtos.

Meu LinkedIn: https://www.linkedin.com/in/fabiosouzadev/
CV em anexo para sua avaliação.

Disponível para PJ 100% remoto (base em Londrina/PR).

Pretensão salarial: R$ 15.000,00 (PJ)

Agradeço a oportunidade e fico à disposição para conversar.

Atenciosamente,
Fábio Souza
https://www.linkedin.com/in/fabiosouzadev/
fabiovanderlei.developer@gmail.com
+55 43 98426-0099"""

# Build message: multipart/mixed > multipart/alternative + attachment
msg = MIMEMultipart("mixed")
msg["Subject"] = subject
msg["From"] = formataddr(("Fábio Souza", username))
msg["To"] = to_email

# Alternative part (text + html)
alt = MIMEMultipart("alternative")
alt.attach(MIMEText(body_text, "plain", "utf-8"))
alt.attach(MIMEText(body_html, "html", "utf-8"))
msg.attach(alt)

# Attachment
with open(cv_path, "rb") as f:
    attach = MIMEApplication(f.read(), _subtype="pdf")
    attach.add_header("Content-Disposition", "attachment", filename=os.path.basename(cv_path))
    msg.attach(attach)

# Send
context = ssl.create_default_context()
try:
    with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
        server.login(username, password)
        server.send_message(msg)
    print("✅ Candidatura enviada com sucesso!")
    print(f"   Para: {to_email}")
    print(f"   Assunto: {subject}")
    print(f"   Anexo: {cv_path}")
except Exception as e:
    print(f"❌ Falha ao enviar: {e}")
    exit(1)
PYEOF

if [[ $? -eq 0 ]]; then
    echo "✅ Candidatura enviada com sucesso!"
    echo "   Para: $EMAIL_DESTINO"
    echo "   Assunto: Candidatura: ${TITULO_VAGA} - ${EMPRESA}"
    echo "   Anexo: $CV_PATH"
    exit 0
else
    echo "❌ Falha ao enviar email"
    exit 1
fi