# Stage 1: Build the static files
FROM node:lts AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
# Copy the built files from Stage 1
COPY --from=builder /app/dist /usr/share/nginx/html
# Copy our custom nginx config
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80