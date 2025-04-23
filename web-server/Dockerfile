# Use official Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first (to leverage Docker cache)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build TypeScript code
RUN npm run build

# Set environment variables
ENV PORT=80

# Expose port
EXPOSE 80

# Run the compiled JS file (assumes dist/server.js exists)
CMD ["node", "server.js"]
