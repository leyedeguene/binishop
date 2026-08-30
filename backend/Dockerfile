# BINISHOP — Dockerfile Medusa.js
FROM node:20-alpine AS base

WORKDIR /app

# Installer les dépendances système nécessaires
RUN apk add --no-cache \
    postgresql-client \
    curl \
    python3 \
    make \
    g++

# Copier les fichiers de dépendances
COPY package.json ./
COPY package-lock.json* ./

# Installer les dépendances Node.js
RUN npm install --legacy-peer-deps

# Copier le code source
COPY . .

# Construire l'application
RUN npm run build

# --- Image de développement ---
FROM base AS development

EXPOSE 9000

CMD ["medusa", "develop"]

# --- Image de production (future) ---
FROM base AS production

EXPOSE 9000

CMD ["medusa", "start"]