import { Router } from 'express';
import { getMovies, getMovieById, createMovie, updateMovie, deleteMovie } from '../controllers/movieController';
import { authenticateJWT, requireAdmin } from '../middleware/authMiddleware';

const router = Router();

/**
 * @swagger
 * /api/movies:
 *   get:
 *     summary: Retrieve a list of active movies
 *     tags: [Movies]
 *     responses:
 *       200:
 *         description: A list of movies.
 */
router.get('/', getMovies);

/**
 * @swagger
 * /api/movies/{id}:
 *   get:
 *     summary: Get a movie by ID
 *     tags: [Movies]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Movie details
 *       404:
 *         description: Movie not found
 */
router.get('/:id', getMovieById);

/**
 * @swagger
 * /api/movies:
 *   post:
 *     summary: Create a new movie (Admin Only)
 *     tags: [Movies]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - description
 *               - language
 *               - duration_minutes
 *               - genre
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               language:
 *                 type: string
 *               duration_minutes:
 *                 type: integer
 *               genre:
 *                 type: string
 *               poster_url:
 *                 type: string
 *               trailer_url:
 *                 type: string
 *     responses:
 *       201:
 *         description: Movie created successfully
 */
router.post('/', authenticateJWT, requireAdmin, createMovie);

/**
 * @swagger
 * /api/movies/{id}:
 *   put:
 *     summary: Update an existing movie (Admin Only)
 *     tags: [Movies]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Movie updated successfully
 */
router.put('/:id', authenticateJWT, requireAdmin, updateMovie);

/**
 * @swagger
 * /api/movies/{id}:
 *   delete:
 *     summary: Soft delete a movie (Admin Only)
 *     tags: [Movies]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       204:
 *         description: Movie deleted successfully
 */
router.delete('/:id', authenticateJWT, requireAdmin, deleteMovie);

export default router;
