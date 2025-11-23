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
