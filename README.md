# SERN Compose Template

A full-stack web application template using SQLite, Express, React, and Node.js with Docker Compose for easy deployment.

## Tech Stack

### Frontend
- **React** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **CSS** - Styling with dark/light mode support

### Backend
- **Node.js** - Runtime environment
- **Express** - Web framework
- **TypeScript** - Type safety
- **SQLite** - Embedded database
- **sqlite3** - Database driver

### DevOps
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **sqlite-web** - Web-based SQLite database viewer

## Project Structure

```
.
├── backend/              # Express API server
│   ├── src/
│   │   └── index.ts     # Main server file
│   ├── dist/            # Compiled output
│   └── package.json
├── frontend/            # React application
│   ├── src/
│   │   ├── App.tsx      # Main app component
│   │   ├── App.css      # Styles
│   │   └── main.tsx     # Entry point
│   ├── dist/            # Build output
│   └── package.json
├── data/                # SQLite database storage (gitignored)
├── docker-compose.yml   # Docker services configuration
├── Dockerfile           # Multi-stage build for production
└── package.json         # Root package with scripts

```

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Node.js 20+ and Yarn (for local development)

### Production (Docker)

1. **Start the application:**
   ```bash
   yarn up-build
   ```

2. **Access the services:**
   - Frontend + API: http://localhost:8080
   - SQLite Web Viewer: http://localhost:8081

3. **Stop the application:**
   ```bash
   yarn down
   ```

### Local Development

1. **Install dependencies:**
   ```bash
   yarn install
   ```

2. **Start backend (Terminal 1):**
   ```bash
   yarn dev-backend
   ```

3. **Start frontend (Terminal 2):**
   ```bash
   yarn dev-frontend
   ```

4. **Access the application:**
   - Frontend: http://localhost:5173 (Vite dev server with HMR)
   - API: http://localhost:8080

## Available Scripts

### Docker Commands

| Command | Description |
|---------|-------------|
| `yarn up` | Start containers with existing images |
| `yarn up-build` | Start containers and rebuild if needed |
| `yarn down` | Stop and remove containers |
| `yarn clean` | Remove containers, volumes, and clean Docker system |
| `yarn rebuild` | Full clean rebuild (no cache) |
| `yarn logs` | Follow container logs in real-time |
| `yarn restart` | Restart all containers |

### Development Commands

| Command | Description |
|---------|-------------|
| `yarn dev-frontend` | Run frontend dev server with HMR |
| `yarn dev-backend` | Run backend in development mode |

## API Endpoints

### Users

#### Get All Users
```http
GET /api/users
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "John Doe"
  }
]
```

#### Create User
```http
POST /api/users
Content-Type: application/json

{
  "name": "Jane Doe"
}
```

**Response:**
```json
{
  "id": 2,
  "name": "Jane Doe"
}
```

## Environment Variables

### Backend

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server port |
| `NODE_ENV` | `production` | Environment mode |
| `DB_PATH` | `/data/db.sqlite` | SQLite database path |
| `TZ` | `Australia/Brisbane` | Timezone |

## Docker Services

### myapp
- **Port:** 8080:8080
- **Purpose:** Serves both frontend and backend API
- **Volume:** `./data:/data` - Persistent database storage
- **Restart:** unless-stopped

### sqlite-web
- **Port:** 8081:8081
- **Purpose:** Web-based SQLite database viewer
- **Volume:** `./data:/data` - Access to application database
- **Restart:** unless-stopped

## Development Workflow

### Making Changes

1. **Frontend changes:**
   - Edit files in `frontend/src/`
   - Changes are reflected immediately with HMR in dev mode
   - For Docker: `yarn up-build`

2. **Backend changes:**
   - Edit files in `backend/src/`
   - For Docker: `yarn up-build`

3. **Dependency changes:**
   - Update package.json in respective folder
   - Run `yarn rebuild` for clean Docker build

### Viewing the Database

Access http://localhost:8081 to view and query your SQLite database using the web interface.

## Database Schema

### Users Table

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL
);
```

## Features

- Full-stack TypeScript support
- Hot Module Replacement (HMR) in development
- Multi-stage Docker builds for optimized production images
- Persistent SQLite database with web viewer
- Dark/Light mode support in UI
- RESTful API design
- Containerized development and production environments

## Troubleshooting

### Port already in use
If ports 8080 or 8081 are in use, either:
- Stop the conflicting service
- Modify ports in `docker-compose.yml`

### Database locked
If you get "database is locked" errors:
- Stop all containers: `yarn down`
- Remove volumes: `yarn clean`
- Restart: `yarn up-build`

### Clean rebuild needed
If you encounter issues after dependency changes:
```bash
yarn rebuild
```

This performs a complete rebuild without cache.

## License

MIT

---

*Vibed by Claude and quality checked by Nick Brown*
