FROM node:20-slim AS builder
WORKDIR /app
COPY package.json ./
COPY tsconfig.json ./
RUN npm install
COPY src ./src
RUN npx prisma generate --schema=src/prisma/schema.prisma
RUN npm run build

FROM node:20-slim
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src/prisma ./src/prisma
COPY package.json ./
USER app
EXPOSE 8001
HEALTHCHECK --interval=30s --timeout=3s CMD node -e "require(''http'').get(''http://localhost:8001/health'', r=>r.statusCode===200?process.exit(0):process.exit(1))"
CMD ["node", "dist/server.js"]
