FROM node:20-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy server code
COPY . .

# Expose the server port
EXPOSE 3001

# Start the server
CMD ["npm", "start"]
