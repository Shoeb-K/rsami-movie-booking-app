import { Router } from 'express';
import { getShowtimesByMovie, createShowtime, getShowSeats, initMasterSeats } from '../controllers/showtimeController';
import { authenticateJWT, requireAdmin } from '../middleware/authMiddleware';

const router = Router();

/**
 * @swagger
 * /api/shows/movie/{movieId}:
 *   get:
 *     summary: Retrieve showtimes for a specific movie
 *     tags: [Shows]
 *     parameters:
 *       - in: path
 *         name: movieId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: A list of showtimes.
 */
router.get('/movie/:movieId', getShowtimesByMovie);

/**
 * @swagger
 * /api/shows:
 *   post:
 *     summary: Create a new showtime (Admin Only). This automatically generates the 50 seat layout for the show.
 *     tags: [Shows]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - movie_id
 *               - show_date
 *               - start_time
 *               - end_time
 *               - base_price
 *             properties:
 *               movie_id:
 *                 type: string
 *               show_date:
 *                 type: string
 *                 format: date-time
 *               start_time:
 *                 type: string
 *                 format: date-time
 *               end_time:
 *                 type: string
 *                 format: date-time
 *               base_price:
 *                 type: number
 *     responses:
 *       201:
 *         description: Showtime and seats created successfully
 */
router.post('/', authenticateJWT, requireAdmin, createShowtime);

/**
 * @swagger
 * /api/shows/{showId}/seats:
 *   get:
 *     summary: Get the seat layout and status for a specific show
 *     tags: [Seats]
 *     parameters:
 *       - in: path
 *         name: showId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of seats and their statuses (Available, Locked, Booked)
 */
router.get('/:showId/seats', getShowSeats);

/**
 * @swagger
 * /api/shows/init-seats:
 *   post:
 *     summary: Initialize the master 50-seat layout (Admin Only)
 *     tags: [Seats]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       201:
 *         description: Seats initialized
 */
router.post('/init-seats', authenticateJWT, requireAdmin, initMasterSeats);

export default router;
