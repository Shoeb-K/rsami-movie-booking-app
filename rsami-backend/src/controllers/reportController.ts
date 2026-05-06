import { Request, Response } from 'express';
import { prisma } from '../db';
import { AuthRequest } from '../middleware/authMiddleware';

export const getBookingStats = async (req: AuthRequest, res: Response) => {
  try {
    // 1. Total Bookings
    const totalBookings = await prisma.booking.count({
      where: { status: 'CONFIRMED' }
    });

    // 2. Total Revenue
    const revenueResult = await prisma.booking.aggregate({
      where: { status: 'CONFIRMED' },
      _sum: { total_amount: true }
    });

    // 3. Tickets Sold (Total BookingItems)
    const ticketsSold = await prisma.bookingItem.count({
      where: {
        booking: { status: 'CONFIRMED' }
      }
    });

    // 4. Most Popular Movies (Top 5)
    const popularMovies = await prisma.booking.groupBy({
      by: ['show_id'],
      where: { status: 'CONFIRMED' },
      _count: { id: true },
      orderBy: {
        _count: { id: 'desc' }
      },
      take: 5,
    });

    // Fetch movie titles for the popular shows
    const popularMoviesWithTitles = await Promise.all(
      popularMovies.map(async (item) => {
        const show = await prisma.show.findUnique({
          where: { id: item.show_id },
          include: { movie: true }
        });
        return {
          title: show?.movie.title || 'Unknown',
          bookings: item._count.id
        };
      })
    );

    res.json({
      totalBookings,
      totalRevenue: revenueResult._sum.total_amount || 0,
      ticketsSold,
      popularMovies: popularMoviesWithTitles
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
