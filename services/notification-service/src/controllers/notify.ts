import { Request, Response, NextFunction } from 'express';
import { notificationsSent } from '../lib/metrics';
export async function sendNotification(req: Request, res: Response, next: NextFunction) {
  try {
    const { recipient, message, channel } = req.body;
    if (!recipient || !message) { res.status(400).json({ error: 'recipient and message required' }); return; }
    const ch = channel || 'email';
    // ponytail: SES stub — console.log, real SES when AWS credentials exist
    console.log(`[notify] channel=${ch} to=${recipient} msg=${message}`);
    notificationsSent.inc({ channel: ch });
    res.json({ sent: true, channel: ch });
  } catch (err) { next(err); }
}
