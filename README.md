# B2B Restaurant Marketplace

A full-stack B2B marketplace platform that connects **farmers/suppliers** with **restaurants**, enabling direct product trading, order management, communication, and supply chain collaboration.

The platform helps restaurants easily discover and purchase fresh products from suppliers while allowing farmers to expand their market reach.

---

## 🚀 Project Overview

Traditional food supply chains often involve multiple intermediaries, increasing costs and reducing transparency. This project provides a digital marketplace where:

* 👨‍🌾 Farmers can showcase and manage their products.
* 🍽️ Restaurants can browse, order, and communicate with suppliers.
* 🤝 Both parties can build long-term business relationships through ratings, messaging, and order tracking.

---

# 🏗️ System Architecture

```
                    Users
                      |
                      |
              Flutter Web Application
                      |
                      |
              NestJS REST API Backend
                      |
        --------------------------------
        |                              |
   PostgreSQL Database            File Storage
                                   (Images)
```

---

# 🛠️ Technology Stack

## Frontend

* Flutter Web
* Dart
* Responsive UI Design

## Backend

* NestJS
* TypeScript
* REST API
* JWT Authentication
* Prisma ORM

## Database

* PostgreSQL

## DevOps

* Docker
* Docker Compose
* GitHub Actions CI/CD

## Storage

* Cloudflare R2 / Object Storage for product images

---

# ✨ Features

## 👨‍🌾 Farmer Features

* Register and manage supplier account
* Create and update product listings
* Upload product images
* Manage inventory
* View incoming orders
* Communicate with restaurants
* Manage business profile

---

## 🍽️ Restaurant Features

* Browse available products
* Search and filter products
* View supplier information
* Add products to cart
* Place orders
* Track order status
* Chat with suppliers
* Rate suppliers/products

---

## 🔐 Authentication & Security

* JWT-based authentication
* Role-based access control
* Secure password hashing
* Protected API endpoints

---

## 📦 Product Management

Each product contains:

* Product name
* Category
* Description
* Price
* Quantity
* Availability status
* Images
* Supplier information

---

# 📂 Project Structure

```
B2B Marketplace/

├── backend/
│   ├── src/
│   │   ├── auth/
│   │   ├── users/
│   │   ├── products/
│   │   ├── orders/
│   │   └── main.ts
│   │
│   ├── prisma/
│   ├── Dockerfile
│   └── package.json
│
├── mobile/
│   ├── lib/
│   ├── assets/
│   ├── web/
│   └── pubspec.yaml
│
├── docker-compose.yml
└── README.md
```

---

# 🐳 Running with Docker

## Requirements

Install:

* Docker
* Docker Compose

Check installation:

```bash
docker --version
docker compose version
```

---

## Start Application

Clone the repository:

```bash
git clone <repository-url>

cd "B2B Marketplace"
```

Build and start containers:

```bash
docker compose up --build
```

The services will start:

| Service     | Port |
| ----------- | ---- |
| Backend API | 3000 |
| PostgreSQL  | 5432 |
| Flutter Web | 8080 |

---

# ⚙️ Backend Setup (Without Docker)

Navigate:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

Create environment file:

```
.env
```

Example:

```env
DATABASE_URL=postgresql://username:password@localhost:5432/b2b_marketplace

JWT_SECRET=your_secret_key

PORT=3000
```

Run database migration:

```bash
npx prisma migrate dev
```

Start development server:

```bash
npm run start:dev
```

---

# 📱 Flutter Web Setup

Navigate:

```bash
cd mobile
```

Install packages:

```bash
flutter pub get
```

Run application:

```bash
flutter run -d chrome
```

Build production version:

```bash
flutter build web
```

---

# 🧪 Testing

## Backend

Run tests:

```bash
npm run test
```

Run end-to-end tests:

```bash
npm run test:e2e
```

---

# 🔄 CI/CD Pipeline

GitHub Actions automatically performs:

```
Push Code
    |
    ↓
Install Dependencies
    |
    ↓
Run Tests
    |
    ↓
Build Backend
    |
    ↓
Build Flutter Web
    |
    ↓
Build Docker Images
```

---

# 🗄️ Database Modules

Main entities:

```
User
 |
 ├── Farmer
 ├── Restaurant
 |
Product
 |
Order
 |
OrderItem
 |
Message
 |
Review
 |
Notification
```

---

# 🔮 Future Improvements

* Real-time chat using WebSocket
* Online payment integration
* AI product recommendation
* Delivery tracking
* Mobile application release
* Analytics dashboard
* Multi-language support (Khmer/English)

---

# 👨‍💻 Development Team

**Project:** B2B Restaurant Marketplace

**Purpose:** Internship / Software Engineering Project

**Developed with:**

* Flutter
* NestJS
* PostgreSQL
* Docker
* GitHub Actions

---

# 📄 License

This project is developed for educational and internship purposes.
