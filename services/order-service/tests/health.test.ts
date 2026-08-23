jest.mock('../src/lib/prisma', () => ({
  prisma: {
    $queryRaw: jest.fn().mockResolvedValue(1),
    user: { findUnique: jest.fn(), create: jest.fn() },
    order: { findMany: jest.fn(), findFirst: jest.fn(), create: jest.fn(), update: jest.fn() },
  },
}));
import request from 'supertest';
import app from '../src/app';

describe('order-service health', () => {
  it('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
  it('GET /ready returns ready', async () => {
    const res = await request(app).get('/ready');
    expect(res.status).toBe(200);
  });
  it('GET /metrics', async () => {
    const res = await request(app).get('/metrics');
    expect(res.status).toBe(200);
  });
});
