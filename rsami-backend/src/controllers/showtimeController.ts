import { Request, Response } from 'express';
import { prisma } from '../db';

export const getShowtimesByMovie = async (req: Request, res: Response) => {
  try {
    const { movieId } = req.params;
    const showtimes = await prisma.show.findMany({
      where: { movie_id: movieId as string },
      orderBy: { start_time: 'asc' },
    });
    res.json(showtimes);
  } catch (error) {
    console.error('Error fetching showtimes:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const createShowtime = async (req: Request, res: Response) => {
  try {
    const { movie_id, show_date, start_time, end_time, base_price } = req.body;
    
    // We must run this in a transaction: Create Show AND Create 50 Seats for this show
    const newShow = await prisma.$transaction(async (tx) => {
      const show = await tx.show.create({
        data: {
          movie_id,
          show_date: new Date(show_date),
          start_time: new Date(start_time),
          end_time: new Date(end_time),
          base_price,
        },
      });

      // We assume seats A1-A10, B1-B10... E1-E10 exist in the Seat table.
      // If not, we should probably initialize the Master Seat layout first.
      // Let's fetch all master seats to link them to this show.
      const masterSeats = await tx.seat.findMany();
      if (masterSeats.length === 0) {
        throw new Error('Master seats are not initialized in the database yet.');
      }

      const showSeatsData = masterSeats.map((seat) => ({
        show_id: show.id,
        seat_id: seat.id,
        price: base_price, // Or add premium logic here
      }));

      await tx.showSeat.createMany({
        data: showSeatsData,
      });

      return show;
    });

    res.status(201).json(newShow);
  } catch (error) {
    console.error('Error creating showtime:', error);
    if (error instanceof Error && error.message.includes('Master seats')) {
      return res.status(400).json({ error: error.message });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Endpoint to fetch the seat layout for a specific show
export const getShowSeats = async (req: Request, res: Response) => {
  try {
    const { showId } = req.params;
    const seats = await prisma.showSeat.findMany({
      where: { show_id: showId as string },
      include: { seat: true }, // Include row and number info
    });
    res.json(seats);
  } catch (error) {
    console.error('Error fetching show seats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const initMasterSeats = async (req: Request, res: Response) => {
  try {
    const rows = ['A', 'B', 'C', 'D', 'E'];
    const seatsPerRow = 10;
    
    // Check if seats already exist
    const count = await prisma.seat.count();
    if (count > 0) {
      return res.status(400).json({ error: 'Master seats are already initialized.' });
    }

    const seatsData = [];
    for (const row of rows) {
      for (let number = 1; number <= seatsPerRow; number++) {
        seatsData.push({
          row,
          number,
          category: row === 'E' ? 'premium' : 'standard',
        });
      }
    }

    await prisma.seat.createMany({ data: seatsData });
    res.status(201).json({ message: '50 Master seats initialized successfully.' });
  } catch (error) {
    console.error('Error initializing master seats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
