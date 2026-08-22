import { Router } from 'express';
import { register } from '../lib/metrics';
import { prisma } from '../lib/prisma';
export const healthRouter = Router();
export const metricsRouter = Router();
healthRouter.get('/health', (_req, res) => res.json({ status: 'ok', service: 'tracking-service' }));
healthRouter.get('/ready', async (_req, res) => {
  try { await prisma.$queryRaw`SELECT 1`; res.json({ status: 'ready', service: 'tracking-service' }); }
  catch { res.status(503).json({ status: 'not ready', service: 'tracking-service' }); }
});
metricsRouter.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType);
  res.send(await register.metrics());
});
