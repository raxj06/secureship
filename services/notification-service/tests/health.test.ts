import request from 'supertest';
import app from '../src/app';

describe('notification-service health', () => {
  it('GET /health returns ok', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
  it('GET /ready returns ready', async () => {
    const res = await request(app).get('/ready');
    expect(res.status).toBe(200);
  });
  it('POST /notify validates input', async () => {
    const res = await request(app).post('/notify').send({});
    expect(res.status).toBe(400);
  });
  it('POST /notify sends notification', async () => {
    const res = await request(app).post('/notify').send({ recipient: 'a@b.com', message: 'hello' });
    expect(res.status).toBe(200);
    expect(res.body.sent).toBe(true);
  });
});
