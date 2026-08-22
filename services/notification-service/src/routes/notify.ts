import { Router } from 'express';
import { sendNotification } from '../controllers/notify';
const router = Router();
router.post('/', sendNotification);
export default router;
