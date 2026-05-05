import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { setupSwagger } from './swagger';
import authRoutes from './routes/authRoutes';
import movieRoutes from './routes/movieRoutes';
import showtimeRoutes from './routes/showtimeRoutes';
import bookingRoutes from './routes/bookingRoutes';
import { setupSockets } from './socket';
import { setupCronJobs } from './cron';

dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
  },
});

app.use(cors());
app.use(express.json());

// Setup Swagger API Documentation
setupSwagger(app);

app.get('/', (req, res) => {
  res.send('<h1>Welcome to RSAMI Movie Theater API</h1><p>View the docs at <a href="/api-docs">/api-docs</a></p>');
});

app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Movie Theater API is running' });
});

app.use('/api/auth', authRoutes);
app.use('/api/movies', movieRoutes);
app.use('/api/shows', showtimeRoutes);
app.use('/api/bookings', bookingRoutes);

// Socket.io integration
setupSockets(io);

// Background Cron Jobs
setupCronJobs(io);

const PORT = process.env.PORT || 3000;

httpServer.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
