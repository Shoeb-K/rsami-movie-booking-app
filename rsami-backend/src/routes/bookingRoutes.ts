import { Router } from 'express';
import { createBooking, getUserBookings } from '../controllers/bookingController';
import { getBookingStats as getReportStats } from '../controllers/reportController';

import { authenticateJWT, requireAdmin } from '../middleware/authMiddleware';

const router = Router();

/**
 * @swagger
 * /api/bookings:
 *   post:
 *     summary: Finalize a booking and permanently book seats
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - showId
 *               - showSeatIds
 *             properties:
 *               showId:
 *                 type: string
 *               showSeatIds:
 *                 type: array
 *                 items:
 *                   type: string
 *               paymentIntentId:
 *                 type: string
 *     responses:
 *       201:
 *         description: Booking confirmed successfully
 */
router.post('/', authenticateJWT, createBooking);

/**
 * @swagger
 * /api/bookings:
 *   get:
 *     summary: Retrieve all bookings for the currently authenticated user
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: A list of bookings.
 */
router.get('/', authenticateJWT, getUserBookings);

/**
 * @swagger
 * /api/bookings/stats:
 *   get:
 *     summary: Get booking statistics (Admin Only)
 *     tags: [Admin, Bookings]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Booking statistics
 */
router.get('/stats', authenticateJWT, requireAdmin, getReportStats);


export default router;
