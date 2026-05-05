import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // 1. Create Admin User
  const adminPassword = await bcrypt.hash('admin123', 10);
  await prisma.user.upsert({
    where: { email: 'admin@rsami.com' },
    update: {},
    create: {
      name: 'Admin User',
      email: 'admin@rsami.com',
      password_hash: adminPassword,
      role: 'ADMIN',
    },
  });

  // 2. Create Customer User
  const customerPassword = await bcrypt.hash('user123', 10);
  await prisma.user.upsert({
    where: { email: 'shoeb@example.com' },
    update: {},
    create: {
      name: 'Shoeb',
      email: 'shoeb@example.com',
      password_hash: customerPassword,
      role: 'CUSTOMER',
    },
  });

  // 3. Create Movies (using upsert by title to prevent duplicates)
  const movies = [
    {
      title: 'Avengers: Endgame',
      description: 'After the devastating events of Infinity War, the universe is in ruins.',
      language: 'English',
      duration_minutes: 181,
      genre: 'Action/Sci-Fi',
      poster_url: 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?auto=format&fit=crop&q=80&w=400',
    },
    {
      title: 'Inception',
      description: 'A thief who steals corporate secrets through the use of dream-sharing technology.',
      language: 'English',
      duration_minutes: 148,
      genre: 'Sci-Fi/Action',
      poster_url: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&q=80&w=400',
    }
  ];

  for (const movieData of movies) {
    await prisma.movie.upsert({
      where: { title: movieData.title },
      update: movieData,
      create: movieData,
    });
  }

  // 4. Initialize Master Seats
  const seatCount = await prisma.seat.count();
  if (seatCount === 0) {
    const rows = ['A', 'B', 'C', 'D', 'E'];
    const seatsPerRow = 10;
    const seatsData = [];
    for (const row of rows) {
      for (let number = 1; number <= seatsPerRow; number++) {
        seatsData.push({ row, number, category: row === 'E' ? 'premium' : 'standard' });
      }
    }
    await prisma.seat.createMany({ data: seatsData });
  }

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
