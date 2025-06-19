# Snuggy - Canteen Management System

A full-stack canteen management application with a Spring Boot backend and Flutter frontend.

## Project Structure

The project is organized into two main directories:

### Backend (Spring Boot)
- Java-based REST API
- PostgreSQL database
- JWT Authentication
- Order and payment processing

### Frontend (Flutter)
- Dart-based mobile application
- User authentication
- Menu browsing
- Order and payment management
- Order tracking

## Getting Started

### Backend Setup
1. Ensure you have JDK 17+ installed
2. Navigate to the backend directory:
   ```
   cd backend
   ```
3. Start PostgreSQL database and create database 'snuggy'
4. Run the application:
   ```
   ./mvnw spring-boot:run
   ```
5. The API will be available at http://localhost:8080

### Frontend Setup
1. Ensure you have Flutter installed (2.5.0 or higher)
2. Navigate to the frontend directory:
   ```
   cd frontend
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Ensure you have the required font files in the assets/fonts directory
5. To run the application on connected mobile device or emulator:
   ```
   flutter run
   ```

## API Endpoints

### Authentication
- POST /api/auth/register
- POST /api/auth/login

### Menu
- GET /api/menu/items

### Orders
- GET /api/orders
- POST /api/orders
- PUT /api/orders/{id}/confirm
- GET /api/orders/{id}

### Payments
- POST /api/payments/{orderId}

## Contributors
- Your Name/Team

## License
MIT License
 
