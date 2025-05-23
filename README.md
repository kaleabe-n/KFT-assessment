
---

## 1. KFT Backend (`kft_backend`)

The backend is built with Django and Django REST Framework, providing APIs for user authentication, merchant functionalities, product management, transactions, and admin operations.

### Key Technologies

*   Python 3.10+
*   Django
*   Django REST Framework
*   Simple JWT for token authentication
*   PostgreSQL (recommended for production, SQLite for development)
*   Gunicorn (for serving the application)
*   `python-dotenv` for environment variable management

### Setup and Running Locally

1.  **Navigate to the backend directory:**
    ```bash
    cd "c:\Users\kaleabe\Desktop\kifiya assessment\kft_backend"
    ```

2.  **Create and activate a virtual environment:**
    ```bash
    python -m venv venv
    # On Windows
    .\venv\Scripts\activate
    # On macOS/Linux
    # source venv/bin/activate
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Create a `.env` file** in the `c:\Users\kaleabe\Desktop\kifiya assessment\kft_backend` directory by copying `.env.example` (if you create one) or by creating it from scratch.
    Example `.env` content:
    ```env
    SECRET_KEY="your_strong_secret_key_here"
    DEBUG=True

    

    EMAIL_HOST_USER="your_email@example.com"
    EMAIL_HOST_PASSWORD="your_email_password"
    DEFAULT_FROM_EMAIL="your_email@example.com"
    ```

5.  **Apply database migrations after making them:**
    ```bash
    python manage.py makemigrations
    python manage.py migrate
    ```

6.  **Create a superuser (optional, for Django admin panel access):**
    ```bash
    python manage.py createsuperuser
    ```

7.  **Run the development server:**
    ```bash
    python manage.py runserver
    ```
    The backend API will typically be available at `http://127.0.0.1:8000/`.

### Deployment

This application is configured for Docker deployment (see `Dockerfile`). Environment variables should be set in the deployment environment (e.g., Render, Heroku).

---

## 2. KFT Merchant Web (`kft-merchant-web`)

This is the Next.js frontend application for merchants. It allows merchants to register, log in, manage their products, view their balance, and see transaction history.

### Key Technologies

*   Node.js
*   Next.js
*   React
*   TypeScript
*   Tailwind CSS

### Setup and Running Locally

1.  **Navigate to the merchant frontend directory:**
    ```bash
    cd "c:\Users\kaleabe\Desktop\kifiya assessment\kft-merchant-web"
    ```

2.  **Install dependencies:**
    ```bash
    npm install
    # or
    # yarn install
    ```

3.  **Create a `.env.local` file** in the `c:\Users\kaleabe\Desktop\kifiya assessment\kft-merchant-web` directory.
    ```env
    NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
    ```

4.  **Run the development server:**
    ```bash
    npm run dev
    # or
    # yarn dev
    ```
    The merchant frontend will typically be available at `http://localhost:3000/`.

---

## 3. KFT Admin Web (`kft-admin-web`)

This is the Next.js frontend application for administrators. It allows admins to log in and manage users (e.g., view and delete users).

### Key Technologies

*   Node.js
*   Next.js
*   React
*   TypeScript
*   Tailwind CSS

### Setup and Running Locally

Follow similar steps as the Merchant Web application, but in the `c:\Users\kaleabe\Desktop\kifiya assessment\kft-admin-web` directory.

1.  Navigate, install dependencies (`npm install` or `yarn install`).
2.  Create a `.env.local` file in `c:\Users\kaleabe\Desktop\kifiya assessment\kft-admin-web` with:
    ```env
    NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
    ```
3.  Run the development server (`npm run dev` or `yarn dev`).
    The admin frontend will typically be available at `http://localhost:3001/` (or another port if 3000 is taken).

---

## 4. KFT Agent Mobile (`kft_agent_mobile`)

This is a Flutter mobile application designed for agents.

### Key Technologies

*   Flutter
*   Dart

### Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- Lab: Write your first Flutter app
- Cookbook: Useful Flutter samples

For help getting started with Flutter development, view the
online documentation, which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Setup and Running Locally

1.  **Ensure Flutter is installed** on your system. Follow the official Flutter installation guide.

2.  **Navigate to the agent mobile app directory:**
    ```bash
    cd "c:\Users\kaleabe\Desktop\kifiya assessment\kft_agent_mobile"
    ```

3.  **Get dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Configure API endpoint (if applicable):**
    If the app communicates with the backend, ensure it's configured to point to the correct API URL (e.g., `http://10.0.2.2:8000` for Android Emulator accessing host's localhost, or your production API URL). This configuration will be specific to how you manage constants/env variables in your Flutter app.

5.  **Run the application:**
    Connect a device or start an emulator/simulator, then run:
    ```bash
    flutter run
    ```

---

