# Build environment
FROM node:14 as builder

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install
RUN npm install react-scripts@1.1.1 -g

# Copy the rest of your application files
COPY . .

# Build the app
RUN npm run build

# Production environment
FROM nginx:1.13.9-alpine

# Copy built files from builder
COPY --from=builder /usr/src/app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
