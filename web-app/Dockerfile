FROM node:20.7.0-alpine as BUILD_IMAGE
WORKDIR /app/react-app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

FROM nginx:1.21.6-alpine as PRODUCTION_IMAGE
COPY --from=BUILD_IMAGE /app/react-app/dist/ /usr/share/nginx/html
COPY env.sh /docker-entrypoint.d/env.sh
RUN chmod +x /docker-entrypoint.d/env.sh
CMD ["nginx", "-g", "daemon off;"]

# # Use Node.js base image
# FROM node:18-alpine AS builder
#
# WORKDIR /app
#
# # Copy package.json and install dependencies
# COPY package.json ./
# RUN npm install
#
# # Copy the source files and build the app
# COPY . ./
# RUN npm run build
#
# # Use Nginx to serve the React app
# FROM nginx:alpine
# COPY --from=builder /app/build /usr/share/nginx/html
# EXPOSE 80
#
