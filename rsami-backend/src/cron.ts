import cron from 'node-cron';
import { prisma } from './db';
import { Server } from 'socket.io';

export const setupCronJobs = (io: Server) => {
  // Run every minute
  cron.schedule('* * * * *', async () => {
    console.log('Running cron job: Releasing expired seat locks...');
    
    try {
      const now = new Date();

      // 1. Find all seats that are LOCKED and have an expired locked_until time
      const expiredSeats = await prisma.showSeat.findMany({
        where: {
          status: 'LOCKED',
          locked_until: {
            lt: now,
          },
        },
      });

      if (expiredSeats.length === 0) return;

      console.log(`Found ${expiredSeats.length} expired seat locks. Releasing...`);

      // 2. Update them back to AVAILABLE
      await prisma.showSeat.updateMany({
        where: {
          id: { in: expiredSeats.map(s => s.id) },
        },
        data: {
          status: 'AVAILABLE',
          locked_until: null,
        },
      });

      // 3. Notify clients via Socket.io that these seats are now available
      // Group by showId to broadcast to the correct rooms
      const showGroups = expiredSeats.reduce((acc, seat) => {
        if (!acc[seat.show_id]) acc[seat.show_id] = [];
        acc[seat.show_id].push(seat.id);
        return acc;
      }, {} as Record<string, string[]>);

      for (const [showId, seatIds] of Object.entries(showGroups)) {
        io.to(`show_${showId}`).emit('seats_released', {
          showId,
          showSeatIds: seatIds,
        });
      }

    } catch (error) {
      console.error('Error in cron job:', error);
    }
  });
};
