FROM diegosouzapw/omniroute:3.8.49-web

USER root

RUN npm install -g @qoder-ai/qodercli \
    && npm cache clean --force

USER node

RUN qoder --version