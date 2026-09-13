# syntax=docker/dockerfile:1

# =========================
# Stage 1: Build
# =========================
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* ./

RUN npm install --force

COPY . .

# PRODUCTION_ENV is mounted only during build.
# It will NOT be persisted in the final image.
RUN --mount=type=secret,id=production_env,target=/app/.env \
    npm run build


# =========================
# Stage 2: Production
# =========================
FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/next.config.ts ./

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "start"]