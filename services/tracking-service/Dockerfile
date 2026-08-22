FROM node:22-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y openssl && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*
COPY package.json ./
COPY tsconfig.json ./
RUN npm install
COPY src ./src
RUN npm run build

FROM node:22-slim
RUN apt-get update && apt-get install -y openssl && apt-get upgrade -y && rm -rf /var/lib/apt/lists/* \
  && addgroup --system app && adduser --system --ingroup app app
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src/prisma ./src/prisma
COPY package.json ./
USER app
EXPOSE 8002
HEALTHCHECK --interval=30s --timeout=3s CMD node -e "require(''http'').get(''http://localhost:8002/health'', r=>r.statusCode===200?process.exit(0):process.exit(1))"
CMD ["node", "dist/server.js"]
