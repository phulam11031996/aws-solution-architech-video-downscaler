import { Router } from 'express';
import { handleDownscale } from '../controllers/downscale.controller';

const router = Router();

router.post('/downscale-videos', handleDownscale);

export default router;
