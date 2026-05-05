# RSAMI Movie Theater Booking Platform

This repository contains both the **Node.js Backend** and the **Flutter Frontend**.

## 🛠 Backend Setup (Partner Instructions)

Your partner needs to do these steps on their machine to run the API locally:

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/Shoeb-K/rsami-movie-booking-app.git
    cd rsami-backend
    ```

2.  **Install Dependencies:**
    ```bash
    npm install
    ```

3.  **Environment Variables:**
    Create a `.env` file in `rsami-backend/` and add:
    ```env
    DATABASE_URL="postgresql://USER:PASSWORD@localhost:5432/rsami_db?schema=public"
    JWT_SECRET="your_super_secret_key"
    ```
    *(Replace USER and PASSWORD with their local PostgreSQL credentials)*

4.  **Database Sync:**
    ```bash
    npx prisma db push
    npx prisma db seed
    ```

5.  **Run the Server:**
    ```bash
    npm run dev
    ```
    The API will be available at `http://localhost:3000`.

---

## 📱 Frontend Setup (Flutter)

1.  **Change API URL:**
    Open `rsami-frontend/lib/services/api_service.dart`.
    Since your partner is running the backend locally, change the `baseUrl` back to:
    ```dart
    static const String baseUrl = 'http://localhost:3000/api';
    ```

2.  **Install Packages:**
    ```bash
    flutter pub get
    ```

3.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 🔑 Test Accounts
- **Admin:** `admin@rsami.com` / `admin123`
- **Customer:** `shoeb@example.com` / `user123`
