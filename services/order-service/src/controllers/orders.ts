import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { prisma } from '../lib/prisma';

export async function createOrder(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const { item, quantity } = req.body;
    if (!item || quantity == null) {
      res.status(400).json({ error: 'item and quantity required' });
      return;
    }
    const order = await prisma.order.create({
      data: { userId: req.user!.userId, item, quantity: Number(quantity) },
    });
    res.status(201).json(order);
  } catch (err) {
    next(err);
  }
}

export async function getOrders(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const orders = await prisma.order.findMany({ where: { userId: req.user!.userId } });
    res.json(orders);
  } catch (err) {
    next(err);
  }
}

export async function getOrderById(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const order = await prisma.order.findFirst({
      where: { id: req.params.id, userId: req.user!.userId },
    });
    if (!order) {
      res.status(404).json({ error: 'Order not found' });
      return;
    }
    res.json(order);
  } catch (err) {
    next(err);
  }
}

export async function updateOrder(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const existing = await prisma.order.findFirst({
      where: { id: req.params.id, userId: req.user!.userId },
    });
    if (!existing) {
      res.status(404).json({ error: 'Order not found' });
      return;
    }
    const order = await prisma.order.update({
      where: { id: req.params.id },
      data: { status: req.body.status, item: req.body.item, quantity: req.body.quantity },
    });
    res.json(order);
  } catch (err) {
    next(err);
  }
}
