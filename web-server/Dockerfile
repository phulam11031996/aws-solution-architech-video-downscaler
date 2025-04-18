# Use official Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install  # Install dependencies

# Copy the rest of the app files
COPY . .

# Add environment variable support
ENV PORT=80

# Expose port 80
EXPOSE 80

# Run the app
CMD ["node", "server.js"]
