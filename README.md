# 🚀 ZipLink - URL Shortening Mobile Application

**ZipLink** is a URL-shortening mobile application that provides a clean, intuitive, and efficient way for users to convert long, cumbersome URLs into short, shareable links.

---

## 🏗 Architecture (3-Tier)

### 1️⃣ Mobile Application (Flutter/Dart)
- Built with **Flutter**, offering a modern, responsive UI with gradient text & interactive buttons.
- Handles user input, displays results, and manages clipboard interactions.

---

### 2️⃣ API Backend (Dart Frog)
- High-performance Dart API built using the **Dart Frog** framework.

#### 📚 Endpoints:
- `GET /zip`:  
  Receives the long URL from the app, generates a unique short code, stores it in the database, and returns the short URL.
  
- `GET /[short_code]`:  
  Retrieves the long URL from the database and performs an HTTP 302 redirect to that original URL.

#### 🔒 Environment Variables:
- Manages sensitive data (e.g., database credentials) securely using `.env` files locally and environment variables during deployment.

---

### 3️⃣ Database (Supabase / PostgreSQL)
- Persistent storage for all shortened URLs.
- Uses **Supabase** powered by PostgreSQL.

#### 📋 Schema:
- Fields:  
  - `long_url`: Original link  
  - `short_code`: Unique identifier for the short link

#### 🔐 Security:
- Row-Level Security (RLS) to ensure data integrity.

---

## ☁️ Deployment
- Dart Frog API is deployable to cloud platforms like **Globe.dev**, **Google Cloud Run**, or **AWS App Runner** using **Docker**.
- Supports **Continuous Deployment (CD)** via GitHub integration:  
  Code pushed to a branch triggers automatic API build & deployment.

---

Made with ❤️ in India 🇮🇳
