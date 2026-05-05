import { Server, Socket } from 'socket.io';
import { prisma } from './db';

export const setupSockets = (io: Server) => {
  io.on('connection', (socket: Socket) => {
    console.log(`Client connected: ${socket.id}`);

    // Join a room specific to a show to listen for seat updates
    socket.on('join_show', (showId: string) => {
      socket.join(`show_${showId}`);
      console.log(`Client ${socket.id} joined room show_${showId}`);
    });

    socket.on('leave_show', (showId: string) => {
      socket.leave(`show_${showId}`);
      console.log(`Client ${socket.id} left room show_${showId}`);
    });

    // Handle seat locking
    socket.on('lock_seat', async (data: { showSeatId: string; showId: string; userId: string }) => {
      try {
        const { showSeatId, showId, userId } = data;

        // Optimistic locking using Prisma transaction
        const updatedSeat = await prisma.$transaction(async (tx) => {
          const seat = await tx.showSeat.findUnique({
            where: { id: showSeatId },
          });

          if (!seat || seat.status !== 'AVAILABLE') {
            throw new Error('Seat is not available');
          }

          // Lock for 5 minutes
          const lockedUntil = new Date(Date.now() + 5 * 60 * 1000);

          return await tx.showSeat.update({
            where: { id: showSeatId },
            data: {
              status: 'LOCKED',
              locked_until: lockedUntil,
            },
            include: { seat: true },
          });
        });

        // Broadcast the lock to all clients in the show's room
        io.to(`show_${showId}`).emit('seat_locked', {
          showSeatId: updatedSeat.id,
          seatInfo: `${updatedSeat.seat.row}${updatedSeat.seat.number}`,
          lockedBy: userId, // Avoid sending full user details
          lockedUntil: updatedSeat.locked_until,
        });

        // Send confirmation back to the client that requested the lock
        socket.emit('lock_success', { showSeatId: updatedSeat.id });

      } catch (error) {
        console.error('Error locking seat:', error);
        socket.emit('lock_error', { 
          showSeatId: data.showSeatId, 
          message: error instanceof Error ? error.message : 'Failed to lock seat' 
        });
      }
    });

    socket.on('disconnect', () => {
      console.log(`Client disconnected: ${socket.id}`);
    });
  });
};
