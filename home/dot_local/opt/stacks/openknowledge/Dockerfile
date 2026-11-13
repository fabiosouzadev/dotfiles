FROM node:24-slim

# git is a hard boot requirement: the server runs a git preflight at boot
# and the version-history subsystems shell out to the binary.
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g @inkeep/open-knowledge

# PORT is the platform-injection contract: Railway/Fly/Cloud Run override
# it at run time. 8080 is only the local default.
# OK_BIND=0.0.0.0 makes the listener reachable from the container network.
# Consent (OK_ALLOW_EXTERNAL=1) is deliberately NOT baked: a run without it
# refuses to boot and names the fix. That refusal is the secure default.
ENV PORT=8080 \
    OK_BIND=0.0.0.0

# No `VOLUME /data`: managed builders (Railway, Fly) reject the
# instruction, and for plain `docker run` it only creates anonymous
# volumes. Persistence is the operator's job: mount a volume at /data,
# or data lives in the container layer and is lost on recreate.
WORKDIR /data
EXPOSE 8080

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]