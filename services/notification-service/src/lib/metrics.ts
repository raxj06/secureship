import { Registry, collectDefaultMetrics, Counter } from 'prom-client';
export const register = new Registry();
collectDefaultMetrics({ register });
export const notificationsSent = new Counter({
  name: 'notifications_sent_total',
  help: 'Total notifications sent',
  labelNames: ['channel'],
  registers: [register],
});
