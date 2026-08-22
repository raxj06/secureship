import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { healthRouter, metricsRouter } from './routes/health';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { authMiddleware } from './middleware/auth';

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());

app.use(healthRouter);
app.use(metricsRouter);

const ORDER_SERVICE_URL = process.env.ORDER_SERVICE_URL || 'http://localhost:8001';
const TRACKING_SERVICE_URL = process.env.TRACKING_SERVICE_URL || 'http://localhost:8002';
const NOTIFICATION_SERVICE_URL = process.env.NOTIFICATION_SERVICE_URL || 'http://localhost:8003';

// Auth routes — proxied without gateway auth (login/register are public)
app.use(
  '/api/auth',
  createProxyMiddleware({ target: ORDER_SERVICE_URL, changeOrigin: true, pathRewrite: { '^/api/auth': '/auth' } }),
);

// Orders — JWT required at gateway
app.use(
  '/api/orders',
  authMiddleware,
  createProxyMiddleware({ target: ORDER_SERVICE_URL, changeOrigin: true, pathRewrite: { '^/api/orders': '/orders' } }),
);

// Tracking
app.use(
  '/api/tracking',
  createProxyMiddleware({ target: TRACKING_SERVICE_URL, changeOrigin: true, pathRewrite: { '^/api/tracking': '/tracking' } }),
);

// Notify — JWT required
app.use(
  '/api/notify',
  authMiddleware,
  createProxyMiddleware({ target: NOTIFICATION_SERVICE_URL, changeOrigin: true, pathRewrite: { '^/api/notify': '/notify' } }),
);

export default app;
