import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { healthRouter, metricsRouter } from './routes/health';
import authRoutes from './routes/auth';
import orderRoutes from './routes/orders';
import { errorHandler } from './middleware/error';

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

app.use(healthRouter);
app.use(metricsRouter);
app.use('/auth', authRoutes);
app.use('/orders', orderRoutes);

app.use(errorHandler);

export default app;
