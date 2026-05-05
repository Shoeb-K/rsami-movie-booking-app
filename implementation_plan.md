# Movie Theater Booking Application Implementation Plan

This document outlines the architecture, tech stack, and step-by-step development plan for building your scalable movie theater booking platform. It has been tailored for a two-developer team structure (Backend & Frontend).

## Project Overview

**Goal:** Build a comprehensive movie theater booking platform with Web and Mobile interfaces.
**Team Structure:**
*   **Developer 1 (You):** Backend API, Database Design, Concurrency Logic, Cloud Infrastructure.
*   **Developer 2 (Frontend):** Mobile App (Flutter) AND Web App.

> [!TIP]
> **Web App Strategy:** Since Developer 2 is using Flutter for the mobile app, the easiest and most efficient approach is to compile the Flutter app for **Flutter Web**. This means Developer 2 can build both the Mobile and Web apps from a single codebase, and you (Developer 1) only need to build the Backend APIs once.

## Architecture & Technology Stack

Since the frontend involves Flutter (Dart), a single JavaScript monorepo is no longer optimal. We will use a **Micro-services / Separated Repositories** approach.

### Backend (Your Focus)
*   **Framework:** **Node.js (Express)** with TypeScript for strong typing and ease of maintenance.
*   **Database:** **PostgreSQL** managed via an ORM like **Prisma** or **TypeORM**.
*   **Real-time:** **Socket.io** for live seat locking broadcasts.
*   **Cloud Infrastructure:** **AWS** (EC2/ECS for Express, RDS for PostgreSQL).
*   **API Documentation:** **Swagger/OpenAPI** (Crucial for providing clear API contracts to your frontend developer).

### Frontend (Developer 2 Focus)
*   **Mobile & Web Frontend:** **Flutter** (Compiles to both iOS/Android and Web from a single codebase). Alternatively, if SEO is critical, Developer 2 can build a separate React (Next.js) web app.
*   **State Management:** Riverpod, BLoC, or Provider.

## Database Schema Design (PostgreSQL)

Here is the proposed relational schema to handle concurrency securely on your end:

*   **Users:** `id`, `name`, `email`, `password_hash`, `role` (customer | admin), `created_at`
*   **Movies:** `id`, `title`, `description`, `language`, `duration_minutes`, `genre`, `poster_url`, `trailer_url`, `is_active`
*   **Shows:** `id`, `movie_id`, `show_date`, `start_time`, `end_time`, `base_price`
*   **Seats:** `id`, `row` (A-E), `number` (1-10), `category` (e.g., standard, premium)
*   **Show_Seats:** `id`, `show_id`, `seat_id`, `status` (available | locked | booked), `locked_until`, `price`
*   **Bookings:** `id`, `user_id`, `show_id`, `status` (pending | confirmed | cancelled), `total_amount`, `payment_intent_id`, `created_at`
*   **Booking_Items:** `id`, `booking_id`, `show_seat_id`

## Concurrency & Seat Locking Strategy

> [!IMPORTANT]  
> **Double Booking Prevention (Backend Logic):**
> 1. When the frontend requests a seat lock, execute an atomic transaction: `UPDATE Show_Seats SET status = 'locked' WHERE id = X AND status = 'available'`.
> 2. Set `locked_until` to `NOW() + 5 minutes`.
> 3. Emit a Socket.io event `seat_locked` with the seat IDs to all connected clients.
> 4. If payment isn't completed within 5 minutes, a cron job or background worker automatically reverts the status to `available` and emits a `seat_released` event.

## Implementation Phases

### Phase 1: Backend Foundation & Database Setup (You)
1. Initialize a new Node.js/Express project with TypeScript in your workspace.
2. Set up PostgreSQL and Prisma. Define the schemas and run migrations.
3. Setup basic Express architecture (Routes, Controllers, Services).
4. Implement JWT Authentication.
5. **Crucial:** Setup Swagger (OpenAPI) to automatically generate API docs. This will be the single source of truth for the Flutter developer.

### Phase 2: Core Domain APIs (You)
1. **Movie & Show API:** Build CRUD endpoints.
2. **Seat API:** Endpoints to fetch seat layouts and handle the temporary locking mechanism (optimistic locking via DB).
3. **WebSockets:** Integrate Socket.io server to broadcast seat status updates.

### Phase 3: Frontend Setup (Developer 2)
1. Initialize the Flutter project and configure routing.
2. Consume the Swagger API documentation to generate Dart models and API service classes.
3. Build the core screens: Home (Movie Listing), Movie Details, and Showtime Selection.

### Phase 4: Seat Selection & Booking Finalization (Both)
1. **Frontend:** Build the 50-seat grid layout in Flutter. Connect to the WebSocket for real-time updates.
2. **Backend:** Implement the final Booking confirmation logic (payment success -> generate unique Booking ID -> update DB).
3. **Integration:** End-to-end testing of the temporary lock -> payment -> confirmation flow.

## User Review Required

> [!CAUTION]
> Please review the updated plan:
> 1. **Project Structure:** Since there are two of you, I recommend setting up two separate folders (e.g., `rsami-backend` and `rsami-frontend`). I will help you build the backend in `rsami-backend`. Does this sound good?
> 2. **API Documentation:** Are you comfortable with setting up Swagger right from the start? It will make collaboration with the Flutter developer much smoother.

## Next Steps
Once you approve this plan, we can start **Phase 1** by initializing the Node.js/TypeScript backend and configuring the PostgreSQL database schema.
