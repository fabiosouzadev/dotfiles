# LinkedIn Scraping & Email MIME Lessons Learned

## LinkedIn Public Post Extraction

**Method**: Use `browser_navigate` on the public post URL (no auth needed for public posts).

**Content location**: The post text is in the `article > paragraph` elements of the accessibility tree. Look for:
- Main post content (first paragraph after author info)
- Email addresses appear as `mailto:` links with `linkedin.com/redir/redirect` wrapper
- Hashtags at the end indicate stack/tags

**Example extraction**:
```bash
browser_navigate "https://www.linkedin.com/posts/author_post-id/"
# Parse snapshot for article/paragraph text
```

## Email MIME Structure (Critical Fix)

**Problem**: Himalaya MML piped input with `--attach` created malformed multipart:
- HTML source visible in email body
- Variables not expanded (quoted heredocs `<<'EOF'`)
- From header missing display name
- Attachment not properly nested

**Solution**: Use Python `smtplib` directly with proper MIME hierarchy:

```python
# Correct structure:
msg = MIMEMultipart("mixed")           # Top level
msg["From"] = formataddr(("Fábio Souza", "fabiovanderlei.developer@gmail.com"))
msg["To"] = to_email

alt = MIMEMultipart("alternative")     # Nested alternative
alt.attach(MIMEText(body_text, "plain", "utf-8"))
alt.attach(MIMEText(body_html, "html", "utf-8"))
msg.attach(alt)

# Attachment at mixed level
attach = MIMEApplication(pdf_bytes, _subtype="pdf")
attach.add_header("Content-Disposition", "attachment", filename="cv.pdf")
msg.attach(attach)
```

## Bash Heredoc Variable Expansion

**Critical**: Use **unquoted** heredoc delimiters for bash variable expansion:
```bash
# CORRECT - expands ${VAR}
BODY=$(cat <<EOF
Content with ${VAR}
EOF
)

# WRONG - literal ${VAR}
BODY=$(cat <<'EOF'
Content with ${VAR}
EOF
)
```

## Score Thresholds (User Confirmed)

| Score | Action |
|-------|--------|
| ≥ 70  | Auto-apply via email + Notion card |
| 40-69 | Ask user before applying |
| < 40  | Ignore (only Notion card for tracking) |

## Stack Matching Keywords

**Core stacks** (30 pts): Python, Node.js/NestJS/Express, Java/Spring Boot
**Contract + Remote** (25 pts): PJ + 100% remoto
**Seniority** (18 pts): Pleno/Sênior/Tech Lead/Arquiteto
**Fintech/Cloud** (15 pts): AWS/GCP/Azure, Docker/K8s, PCI-DSS, microserviços, CI/CD
**AI/LLM** (10 pts): Python, Langfuse, Generative AI, LLMs

## Multi-Email Posts (Bianca Vieira Pattern)

Some posts list multiple emails per stack. Parse each stack→email mapping separately and triage each independently.

## Tested Working URLs (Aug 2026)

- `andrea@4solutiongroup.com.br` - Java Pleno/Sênior
- `vishal.rami@sapsol.com` - Java/Kotlin + Ruby on Rails (USA, USD)
- `ariane.nunes@nexmuv.com.br` - Full Stack Java/React
- `e3consultoriarh@outlook.com` - Node.js/NestJS
- `aline.lemos@nexmuv.com.br` - Fullstack Java, .NET, Identity Security
- `leticia.rodrigues@nexmuv.com.br` - Cybersecurity, Identity Security
- `bruna.santos@nexmuv.com.br` - .NET, Flutter
- `magna.vieira@nexmuv.com.br` - Security, .NET