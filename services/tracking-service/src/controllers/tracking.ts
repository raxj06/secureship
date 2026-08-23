import { Request, Response, NextFunction } from 'express';
import { prisma } from '../lib/prisma';
export async function getTracking(req: Request, res: Response, next: NextFunction) {
  try {
    const events = await prisma.trackingEvent.findMany({
      where: { orderId: req.params.orderId },
      orderBy: { timestamp: 'asc' },
    });
    res.json(events);
  } catch (err) {
    next(err);
  }
}
export async function createTracking(req: Request, res: Response, next: NextFunction) {
  try {
    const { orderId, status, location } = req.body;
    if (!orderId || !status) {
      res.status(400).json({ error: 'orderId and status required' });
      return;
    }
    const event = await prisma.trackingEvent.create({ data: { orderId, status, location } });
    res.status(201).json(event);
  } catch (err) {
    next(err);
  }
}
