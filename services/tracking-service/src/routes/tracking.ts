import { Router } from 'express';
import { getTracking, createTracking } from '../controllers/tracking';
const router = Router();
router.get('/:orderId', getTracking);
router.post('/update', createTracking);
export default router;
