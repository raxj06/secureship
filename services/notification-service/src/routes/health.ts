import { Router } from 'express';
import { register } from '../lib/metrics';
export const healthRouter = Router();
export const metricsRouter = Router();
healthRouter.get('/health', (_req, res) =>
  res.json({ status: 'ok', service: 'notification-service' }),
);
healthRouter.get('/ready', (_req, res) =>
  res.json({ status: 'ready', service: 'notification-service' }),
);
metricsRouter.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType);
  res.send(await register.metrics());
});
