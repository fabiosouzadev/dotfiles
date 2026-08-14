# -------------------------------------------------
# Dockerfile.custom – OmniRoute + Qoder CLI
# -------------------------------------------------
# 1️⃣ Imagem oficial da versão que você já está usando
FROM diegosouzapw/omniroute:v3.8.49-web   # ← mesma tag do seu compose

# 2️⃣ Instala o Qoder CLI (global) – ~129 MB
#    npm install -g coloca o binário em /usr/local/bin (já no $PATH)
RUN npm install -g @qoder-ai/qodercli \
    && npm cache clean --force \
    # opcional: verifica a instalação
    && qoder --version