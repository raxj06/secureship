import { Router } from 'express';
import { authMiddleware } from '../middleware/auth';
import { createOrder, getOrders, getOrderById, updateOrder } from '../controllers/orders';

const router = Router();

router.use(authMiddleware);

router.get('/', getOrders);
router.get('/:id', getOrderById);
router.post('/', createOrder);
router.patch('/:id', updateOrder);

export default router;
