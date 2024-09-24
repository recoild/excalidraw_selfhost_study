# Stage 1: Build
FROM node:18 AS build

WORKDIR /opt/node_app

# Copy root package.json and yarn.lock
COPY package.json yarn.lock ./

# Copy workspace package.json files
COPY excalidraw-app/package.json excalidraw-app/
COPY packages/excalidraw/package.json packages/excalidraw/
COPY packages/utils/package.json packages/utils/
COPY packages/math/package.json packages/math/
# Add other workspaces as needed

# Install dependencies
RUN yarn install --frozen-lockfile --network-timeout 600000

# Copy the rest of the source code
COPY . .

# Set build environment variable
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Build the application
RUN yarn build:app:docker

# Stage 2: Production Image
FROM nginx:1.27-alpine-slim

# Copy built assets to Nginx
COPY --from=build /opt/node_app/excalidraw-app/build /usr/share/nginx/html

# Healthcheck
HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
