Below is the **revised set of step-by-step markdown instructions**, written for an AI agent that is **already positioned in the root working directory**. All paths assume the agent is operating from this root.

---

# 📘 Instructions for AI Agent

### Build a Self-Hosted App (Vite React TypeScript + Express TypeScript + SQLite + Docker Compose)

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

## ✅ 2. Set Up the Frontend (Vite + React + TypeScript)

1. Navigate to the frontend directory:

   ```bash
   cd frontend
   ```

2. Create a new Vite React TypeScript project **inside the current folder**:

   ```bash
   npm create vite@latest . -- --template react-ts
   ```

3. Install dependencies using yarn:

   ```bash
   yarn install
   ```

4. Confirm that the `package.json` contains a build script:

   ```json
   "scripts": {
     "dev": "vite",
     "build": "tsc -b && vite build",
     "preview": "vite preview"
   }
   ```

5. Return to the root directory:

   ```bash
   cd ..
   ```

---

## ✅ 3. Set Up the Backend (Express + SQLite + TypeScript)

1. Navigate to backend directory:

   ```bash
   cd backend
   ```

2. Initialize a Node.js project:

   ```bash
   npm init -y
   ```

3. Install runtime dependencies:

   ```bash
   yarn add express sqlite3 sqlite
   ```

4. Install TypeScript and development dependencies:

   ```bash
   yarn add -D typescript @types/node @types/express tsx
   ```

5. Create `backend/tsconfig.json`:

   ```json
   {
     "compilerOptions": {
       "target": "ES2022",
       "module": "NodeNext",
       "moduleResolution": "NodeNext",
       "outDir": "./dist",
       "rootDir": "./src",
       "strict": true,
       "esModuleInterop": true,
       "skipLibCheck": true,
       "forceConsistentCasingInFileNames": true,
       "resolveJsonModule": true,
       "declaration": true,
       "declarationMap": true,
       "sourceMap": true
     },
     "include": ["src/**/*"],
     "exclude": ["node_modules", "dist"]
   }
   ```

6. Update `backend/package.json` to add scripts and module type:

   ```json
   {
     "type": "module",
     "scripts": {
       "build": "tsc",
       "dev": "tsx src/index.ts",
       "start": "node dist/index.js"
     }
   }
   ```

7. Create `backend/src/index.ts` with the following contents:

   ```typescript
   import express from "express";
   import path from "path";
   import { fileURLToPath } from "url";
   import sqlite3 from "sqlite3";
   import { open, Database } from "sqlite";

   const __filename = fileURLToPath(import.meta.url);
   const __dirname = path.dirname(__filename);

   const app = express();
   const PORT = process.env.PORT || 3000;
   const DB_PATH = process.env.DB_PATH || "/data/db.sqlite";

   let db: Database<sqlite3.Database, sqlite3.Statement>;

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

8. Test the TypeScript compilation:

   ```bash
   yarn build
   ```

9. Return to root directory:

   ```bash
   cd ..
   ```

---

## ✅ 4. Create the Dockerfile (Multi-Stage Build with TypeScript)

In the root directory, create a file named `Dockerfile` containing:

```dockerfile
# ---- Frontend build stage ----
FROM node:20-alpine AS frontend-build

WORKDIR /app/frontend

COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --frozen-lockfile

COPY frontend/ ./
RUN yarn build

# ---- Backend build stage ----
FROM node:20-alpine AS backend-build

WORKDIR /app/backend

COPY backend/package.json backend/yarn.lock ./
RUN yarn install --frozen-lockfile

COPY backend/ ./
RUN yarn build

# ---- Final runtime image ----
FROM node:20-alpine

WORKDIR /app

RUN mkdir -p /data

# Copy compiled backend and its dependencies
COPY --from=backend-build /app/backend/dist /app/backend/dist
COPY --from=backend-build /app/backend/node_modules /app/backend/node_modules
COPY --from=backend-build /app/backend/package.json /app/backend/package.json

# Copy compiled frontend
COPY --from=frontend-build /app/frontend/dist /app/frontend_dist

ENV NODE_ENV=production
ENV PORT=3000
ENV DB_PATH=/data/db.sqlite

WORKDIR /app/backend

EXPOSE 3000

CMD ["node", "dist/index.js"]
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

  sqlite-web:
    image: coleifer/sqlite-web
    container_name: sqlite-web
    ports:
      - "8081:8080"
    volumes:
      - ./data:/data
    environment:
      - SQLITE_DATABASE=db.sqlite
    command: ["/data/db.sqlite"]
    restart: unless-stopped
```

---

## ✅ 6. Build and Run the Entire Application

1. From the root directory, run:

   ```bash
   docker compose up -d --build
   ```

2. Access the services:

   ```
   Main App:    http://localhost:8080
   SQLite GUI:  http://localhost:8081
   ```

3. To view logs:

   ```bash
   docker compose logs -f myapp
   docker compose logs -f sqlite-web
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

## ✅ 8. Using the SQLite GUI

1. Access sqlite-web at `http://localhost:8081`

2. You can:
   - Browse all tables and data
   - Execute SQL queries
   - Add, edit, and delete records
   - Export data as JSON or CSV
   - View table schemas

3. The GUI connects to the same database as your application (`./data/db.sqlite`)

4. Changes made in the GUI are immediately visible in your app and vice versa

---

## 🎉 Done!

You now have a fully TypeScript-based self-hosted application with:
- **Frontend**: Vite + React + TypeScript
- **Backend**: Express + TypeScript + SQLite
- **Database GUI**: sqlite-web for easy database management
- **Docker**: Multi-stage builds with TypeScript compilation
- **Persistence**: SQLite database persisted in `./data/`

All instructions are aligned for an AI agent operating **from the root project directory** with clear, deterministic step-by-step actions.
