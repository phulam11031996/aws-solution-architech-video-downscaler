import express from 'express';
import cors from 'cors';
import downscaleRoutes from './routes/downscale.route';
import { Request, Response } from 'express';

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors({ origin: '*', credentials: true }));

app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({ status: 'ok' });
});
app.use('/', downscaleRoutes);

export default app;
