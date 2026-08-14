# -------------------------------------------------
# Dockerfile.custom – OmniRoute + Qoder CLI
# -------------------------------------------------

# 1️⃣ Imagem oficial da versão que você já está usando
FROM diegosouzapw/omniroute:3.8.49-web

# 2️⃣ Instala o Qoder CLI (global) – ~129 MB
RUN npm install -g @qoder-ai/qodercli \
    && npm cache clean --force \
    # opcional: verifica a instalação
    && qoder --version