jest.mock('../src/lib/prisma', () => ({
  prisma: {
    $queryRaw: jest.fn().mockResolvedValue(1),
    user: { findUnique: jest.fn(), create: jest.fn() },
    order: { findMany: jest.fn(), findFirst: jest.fn(), create: jest.fn(), update: jest.fn() },
  },
}));
import request from 'supertest';
import jwt from 'jsonwebtoken';
import app from '../src/app';
import { prisma } from '../src/lib/prisma';

const mockedPrisma = prisma as unknown as {
  order: { findMany: jest.Mock; findFirst: jest.Mock; create: jest.Mock; update: jest.Mock };
};

const token = jwt.sign({ userId: 'u1', email: 'a@b.com' }, process.env.JWT_SECRET || 'dev-secret');

describe('orders', () => {
  it('requires auth', async () => {
    const res = await request(app).get('/orders');
    expect(res.status).toBe(401);
  });
  it('creates order', async () => {
    mockedPrisma.order.create.mockResolvedValue({
      id: '1',
      item: 'box',
      quantity: 2,
      userId: 'u1',
      status: 'pending',
    });
    const res = await request(app)
      .post('/orders')
      .set('Authorization', `Bearer ${token}`)
      .send({ item: 'box', quantity: 2 });
    expect(res.status).toBe(201);
    expect(res.body.item).toBe('box');
  });
  it('validates item/quantity', async () => {
    const res = await request(app).post('/orders').set('Authorization', `Bearer ${token}`).send({});
    expect(res.status).toBe(400);
  });
});
