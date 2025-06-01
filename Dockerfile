FROM docker.n8n.io/n8nio/n8n

USER root

# Install Chrome dependencies and Chrome
RUN apk add --no-cache \
    chromium \
    nss \
    glib \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    udev \
    ttf-liberation \
    font-noto-emoji

# (Optional: global install is fine but NOT enough for Code node)
RUN npm install -g cheerio

# Tell Puppeteer to use installed Chrome instead of downloading it
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Install n8n-nodes-puppeteer in a permanent location
COPY . /opt/n8n-custom-nodes/node_modules/n8n-nodes-puppeteer
RUN cd /opt/n8n-custom-nodes/node_modules/n8n-nodes-puppeteer && \
    npm install && \
    npm run build && \
    chown -R node:node /opt/n8n-custom-nodes

# Install cheerio in n8n's data directory (THIS is the key step)
RUN npm install --prefix /home/node/.n8n cheerio

# Copy our custom entrypoint
COPY docker/docker-custom-entrypoint.sh /docker-custom-entrypoint.sh
RUN chmod +x /docker-custom-entrypoint.sh && \
    chown node:node /docker-custom-entrypoint.sh

USER node

ENTRYPOINT ["/docker-custom-entrypoint.sh"]
