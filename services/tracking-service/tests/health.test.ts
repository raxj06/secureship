jest.mock('../src/lib/prisma', () => ({
  prisma: { $queryRaw: jest.fn().mockResolvedValue(1), trackingEvent: { findMany: jest.fn().mockResolvedValue([]), create: jest.fn().mockImplementation((a: { data: Record<string, unknown> }) => Promise.resolve({ id: '1', ...a.data })) } },
}));
import request from 'supertest';
import app from '../src/app';

describe('tracking-service health', () => {
  it('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
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
