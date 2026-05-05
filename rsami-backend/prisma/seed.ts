import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // 1. Create Admin User
  const adminPassword = await bcrypt.hash('admin123', 10);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@rsami.com' },
    update: {},
    create: {
      name: 'Admin User',
      email: 'admin@rsami.com',
      password_hash: adminPassword,
      role: 'ADMIN',
    },
  });
  console.log('Admin user created/verified');

  // 2. Create Customer User
  const customerPassword = await bcrypt.hash('user123', 10);
  const customer = await prisma.user.upsert({
    where: { email: 'shoeb@example.com' },
    update: {},
    create: {
      name: 'Shoeb',
      email: 'shoeb@example.com',
      password_hash: customerPassword,
      role: 'CUSTOMER',
    },
  });
  console.log('Customer user created/verified');

  // 3. Create Movies
  const movie1 = await prisma.movie.create({
    data: {
      title: 'Avengers: Endgame',
      description: 'After the devastating events of Infinity War, the universe is in ruins.',
      language: 'English',
      duration_minutes: 181,
      genre: 'Action/Sci-Fi',
      poster_url: 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?auto=format&fit=crop&q=80&w=400',
      trailer_url: 'https://youtube.com/watch?v=TcMBFSGVi1c',
    },
  });

  const movie2 = await prisma.movie.create({
    data: {
      title: 'Inception',
      description: 'A thief who steals corporate secrets through the use of dream-sharing technology.',
      language: 'English',
      duration_minutes: 148,
      genre: 'Sci-Fi/Action',
      poster_url: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&q=80&w=400',
      trailer_url: 'https://youtube.com/watch?v=YoHD9XEInc0',
    },
  });
  console.log('Movies created');

  // 4. Initialize Master Seats (50 seats)
  const count = await prisma.seat.count();
  if (count === 0) {
    const rows = ['A', 'B', 'C', 'D', 'E'];
    const seatsPerRow = 10;
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
    console.log('50 Master seats initialized');
  }

  // 5. Create Showtimes
  const masterSeats = await prisma.seat.findMany();
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  tomorrow.setHours(18, 0, 0, 0);

  const show = await prisma.show.create({
    data: {
      movie_id: movie1.id,
      show_date: tomorrow,
      start_time: tomorrow,
      end_time: new Date(tomorrow.getTime() + 180 * 60000),
      base_price: 250.0,
    },
  });

  const showSeatsData = masterSeats.map((seat) => ({
    show_id: show.id,
    seat_id: seat.id,
    price: seat.category === 'premium' ? 350.0 : 250.0,
  }));

  await prisma.showSeat.createMany({ data: showSeatsData });
  console.log('Showtime and 50 seats created for tomorrow');

  console.log('Seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
