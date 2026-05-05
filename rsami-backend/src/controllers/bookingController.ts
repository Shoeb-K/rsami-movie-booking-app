import { Request, Response } from 'express';
import QRCode from 'qrcode';
import { prisma } from '../db';
import { AuthRequest } from '../middleware/authMiddleware';

export const createBooking = async (req: AuthRequest, res: Response) => {
  try {
    const { showId, showSeatIds, paymentIntentId } = req.body;
    const userId = req.user!.userId;

    if (!showSeatIds || !Array.isArray(showSeatIds) || showSeatIds.length === 0) {
      return res.status(400).json({ error: 'No seats provided for booking' });
    }

    const booking = await prisma.$transaction(async (tx) => {
      // 1. Fetch the requested seats to verify they are locked and belong to this show
      const seats = await tx.showSeat.findMany({
        where: {
          id: { in: showSeatIds },
          show_id: showId,
        },
      });

      if (seats.length !== showSeatIds.length) {
        throw new Error('Some seats are invalid or do not belong to this show');
      }

      // 2. Ensure seats are currently in a LOCKED state (or AVAILABLE if we want to skip locking for testing)
      const invalidSeats = seats.filter(seat => seat.status === 'BOOKED');
      if (invalidSeats.length > 0) {
        throw new Error('Some requested seats are already booked');
      }

      // 3. Calculate total price
      const totalAmount = seats.reduce((sum, seat) => sum + seat.price, 0);

      // 4. Create the main Booking record
      const newBooking = await tx.booking.create({
        data: {
          user_id: userId,
          show_id: showId,
          total_amount: totalAmount,
          status: 'CONFIRMED', // Assuming payment was successful via Stripe/Razorpay on frontend
          payment_intent_id: paymentIntentId || 'dummy_payment_id',
        },
      });

      // 5. Create BookingItems (mapping booking to specific seats)
      const bookingItemsData = seats.map((seat) => ({
        booking_id: newBooking.id,
        show_seat_id: seat.id,
      }));

      await tx.bookingItem.createMany({
        data: bookingItemsData,
      });

      // 6. Update Seat statuses to BOOKED
      await tx.showSeat.updateMany({
        where: { id: { in: showSeatIds } },
        data: {
          status: 'BOOKED',
          locked_until: null, // Clear the lock
        },
      });

      return newBooking;
    });

    // 7. Generate Ticket QR Code
    const qrData = JSON.stringify({
      bookingId: booking.id,
      userId: booking.user_id,
      showId: booking.show_id,
      amount: booking.total_amount,
    });
    const qrCodeBase64 = await QRCode.toDataURL(qrData);

    res.status(201).json({ 
      message: 'Booking confirmed successfully', 
      booking,
      ticketQr: qrCodeBase64 
    });
  } catch (error) {
    console.error('Error creating booking:', error);
    if (error instanceof Error) {
      return res.status(400).json({ error: error.message });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
};

export const getUserBookings = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const bookings = await prisma.booking.findMany({
      where: { user_id: userId },
      include: {
        show: {
          include: { movie: true },
        },
        booking_items: {
          include: {
            show_seat: {
              include: { seat: true },
            },
          },
        },
      },
      orderBy: { created_at: 'desc' },
    });

    res.json(bookings);
  } catch (error) {
    console.error('Error fetching bookings:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
