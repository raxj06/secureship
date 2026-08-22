import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { healthRouter, metricsRouter } from './routes/health';
import trackingRoutes from './routes/tracking';
import { errorHandler } from './middleware/error';

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(healthRouter);
app.use(metricsRouter);
app.use('/tracking', trackingRoutes);
app.use(errorHandler);
export default app;
