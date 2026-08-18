# --- Build Stage ---
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copy package configurations
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# --- Production Stage ---
FROM node:20-alpine

# Set node environment to production
ENV NODE_ENV=production
WORKDIR /usr/src/app

# Copy dependency artifacts from builder
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY package.json ./
COPY index.js ./

# Run application under the non-root user 'node' for security
USER node

# Expose port
EXPOSE 3000

# Use 'node' directly instead of 'npm start' to ensure OS signals (SIGTERM/SIGINT) 
# are correctly received by the process for graceful shutdown
CMD ["node", "index.js"]
