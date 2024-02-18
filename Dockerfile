# Stage 1: Build the application
FROM node:16.17.0-alpine as builder

# Set working directory
WORKDIR /app

# Copy package.json and yarn.lock to the container
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Set build argument as environment variable
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}

# Set API endpoint URL as environment variable
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the application
RUN yarn build

# Stage 2: Serve the application using Nginx
FROM nginx:stable-alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default Nginx static assets
RUN rm -rf ./*

# Copy the built assets from the builder stage
COPY --from=builder /app/dist .

# Expose port 80
EXPOSE 80

# Start Nginx and keep it running in the foreground
CMD ["nginx", "-g", "daemon off;"]
