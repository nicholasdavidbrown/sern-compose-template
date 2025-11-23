Below is the **revised set of step-by-step markdown instructions**, written for an AI agent that is **already positioned in the root working directory** (the future `my-app` directory). All paths assume the agent is operating from this root.

---

# 📘 Instructions for AI Agent

### Build a Self-Hosted App (Vite React + Express + SQLite + Docker Compose)

**Assume you are already in the root project directory.**

---

## ✅ 1. Create Project Structure

1. Create folders:

   ```bash
   mkdir -p backend/src frontend
   ```

2. Ensure the directory structure is now:

   ```
   ./backend/
   ./backend/src/
   ./frontend/
   ```

---

## ✅ 2. Set Up the Frontend (Vite + React)

1. Navigate to the frontend directory:

   ```bash
   cd frontend
   ```

2. Create a new Vite React project **inside the current folder**:

   ```bash
   npm create vite@latest . -- --template react
   ```

3. Install dependencies:

   ```bash
   npm install
   ```

4. Confirm that the `package.json` contains a build script:

   ```json
   "scripts": {
     "dev": "vite",
     "build": "vite build",
     "preview": "vite preview"
   }
   ```

5. Return to the root directory:

   ```bash
   cd ..
   ```

---

## ✅ 3. Set Up the Backend (Express + SQLite)

1. Navigate to backend directory:

   ```bash
   cd backend
   ```

2. Initialize a Node.js project:

   ```bash
   npm init -y
   ```

3. Install dependencies:

   ```bash
   npm install express sqlite3 sqlite
   ```

4. Add a start script in `backend/package.json`:

   ```json
   "scripts": {
     "start": "node src/index.js"
   }
   ```

5. Add the module type:

   ```json
   "type": "module"
   ```

6. Create `backend/src/index.js` with the following contents:

   ```js
   import express from "express";
   import path from "path";
   import { fileURLToPath } from "url";
   import sqlite3 from "sqlite3";
   import { open } from "sqlite";

   const __filename = fileURLToPath(import.meta.url);
   const __dirname = path.dirname(__filename);

   const app = express();
   const PORT = process.env.PORT || 3000;
   const DB_PATH = process.env.DB_PATH || "/data/db.sqlite";

   let db;

   async function initDb() {
     db = await open({
       filename: DB_PATH,
       driver: sqlite3.Database,
     });

     await db.exec(`
       CREATE TABLE IF NOT EXISTS users (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         name TEXT NOT NULL
       );
     `);
   }

   app.use(express.json());

   app.get("/api/users", async (_req, res) => {
     const rows = await db.all("SELECT * FROM users");
     res.json(rows);
   });

   app.post("/api/users", async (req, res) => {
     const { name } = req.body;
     const result = await db.run("INSERT INTO users (name) VALUES (?)", name);
     res.json({ id: result.lastID, name });
   });

   const staticPath = path.join(__dirname, "..", "frontend_dist");
   app.use(express.static(staticPath));

   app.get("*", (_req, res) => {
     res.sendFile(path.join(staticPath, "index.html"));
   });

   initDb().then(() => {
     app.listen(PORT, () => {
       console.log(`Server running on port ${PORT}`);
     });
   });
   ```

7. Return to root directory:

   ```bash
   cd ..
   ```

---

## ✅ 4. Create the Dockerfile (Multi-Stage Build)

In the root directory, create a file named `Dockerfile` containing:

```dockerfile
# ---- Frontend build stage ----
FROM node:20-alpine AS frontend-build

WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

# ---- Backend build stage ----
FROM node:20-alpine AS backend-build

WORKDIR /app/backend

COPY backend/package*.json ./
RUN npm ci --only=production

COPY backend/ ./

# ---- Final runtime image ----
FROM node:20-alpine

WORKDIR /app

RUN mkdir -p /data

COPY --from=backend-build /app/backend /app/backend
COPY --from=frontend-build /app/frontend/dist /app/frontend_dist

ENV NODE_ENV=production
ENV PORT=3000
ENV DB_PATH=/data/db.sqlite

WORKDIR /app/backend

EXPOSE 3000

CMD ["node", "src/index.js"]
```

---

## ✅ 5. Create docker-compose.yml

In the root directory, create a file named `docker-compose.yml`:

```yaml
version: "3.8"

services:
  myapp:
    build: .
    container_name: myapp
    environment:
      - NODE_ENV=production
      - TZ=Asia/Tashkent
      - PORT=3000
      - DB_PATH=/data/db.sqlite
    ports:
      - "8080:3000"
    volumes:
      - ./data:/data
    restart: unless-stopped
```

---

## ✅ 6. Build and Run the Entire Application

1. From the root directory, run:

   ```bash
   docker compose up -d --build
   ```

2. Access the app:

   ```
   http://localhost:8080
   ```

3. To view logs:

   ```bash
   docker compose logs -f myapp
   ```

4. To stop the app:

   ```bash
   docker compose down
   ```

---

## ✅ 7. Confirm SQLite Persistence

1. Ensure the `data/` directory exists:

   ```
   ./data/db.sqlite
   ```

2. If missing, Docker will create it automatically on first run.

---

## 🎉 Done!

These instructions are now fully aligned for an AI agent operating **from the root project directory** with clear, deterministic step-by-step actions.
