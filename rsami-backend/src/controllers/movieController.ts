import { Request, Response } from 'express';
import { prisma } from '../db';

export const getMovies = async (req: Request, res: Response) => {
  try {
    const movies = await prisma.movie.findMany({
      where: { is_active: true },
    });
    res.json(movies);
  } catch (error) {
    console.error('Error fetching movies:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getMovieById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const movie = await prisma.movie.findUnique({
      where: { id: id as string },
    });

    if (!movie) {
      return res.status(404).json({ error: 'Movie not found' });
    }
    res.json(movie);
  } catch (error) {
    console.error('Error fetching movie:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const createMovie = async (req: Request, res: Response) => {
  try {
    const { title, description, language, duration_minutes, genre, poster_url, trailer_url } = req.body;
    
    const movie = await prisma.movie.create({
      data: {
        title,
        description,
        language,
        duration_minutes,
        genre,
        poster_url,
        trailer_url,
      },
    });

    res.status(201).json(movie);
  } catch (error) {
    console.error('Error creating movie:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const updateMovie = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const movie = await prisma.movie.update({
      where: { id: id as string },
      data: updateData,
    });

    res.json(movie);
  } catch (error) {
    console.error('Error updating movie:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const deleteMovie = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    // We do a soft delete by setting is_active to false
    await prisma.movie.update({
      where: { id: id as string },
      data: { is_active: false },
    });

    res.status(204).send();
  } catch (error) {
    console.error('Error deleting movie:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
