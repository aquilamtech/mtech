# syntax=docker/dockerfile:1.7
# A-08 - Empacotamento versionado e reprodutivel
# Imagens base fixadas por digest: o build nao muda quando a tag movel for atualizada.

ARG NODE_IMAGE=node:22-alpine@sha256:b6f26b36c8ff49624cfdac716b8ea1138d606df02586a77d364bb5536a634f85
ARG NGINX_IMAGE=nginx:1.29-alpine@sha256:5616878291a2eed594aee8db4dade5878cf7edcb475e59193904b198d9b830de

# ---------- estagio de build ----------
FROM ${NODE_IMAGE} AS build
WORKDIR /app

# Instalacao pelo arquivo de travamento: npm ci exige package-lock.json versionado.
COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Vite gera "dist"; Create React App gera "build".
# Se o projeto for CRA, troque o valor padrao abaixo para build.
ARG BUILD_DIR=dist
RUN mv "${BUILD_DIR}" /app/_site

# ---------- estagio final ----------
FROM ${NGINX_IMAGE}
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/_site /usr/share/nginx/html

LABEL org.opencontainers.image.title="painel-cadunico"
EXPOSE 8080
