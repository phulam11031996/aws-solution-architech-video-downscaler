# Use Node.js base image
FROM node:18-alpine AS builder
WORKDIR /app
# Copy package.json and install dependencies
COPY package.json ./
RUN npm install
# Copy the source files and build the app
COPY . ./
RUN npm run build

# Use Nginx to serve the React app
FROM nginx:alpine
# Copy the built app files
COPY --from=builder /app/dist /usr/share/nginx/html

# Create a custom nginx configuration template
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

# Add startup script to configure nginx
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
