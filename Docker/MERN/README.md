# My MERN App

This is a MERN (MongoDB, Express, React, Node.js) application that demonstrates a full-stack web application using Docker. The project is structured into separate directories for the backend and frontend, along with an Nginx reverse proxy for serving the application.

## Project Structure

```
my-mern-app
├── backend          # Contains the backend application
│   ├── Dockerfile   # Multi-stage build for the backend
│   ├── src         # Source code for the backend
│   ├── package.json # Backend dependencies and scripts
├── frontend         # Contains the frontend application
│   ├── Dockerfile   # Multi-stage build for the frontend
│   ├── src         # Source code for the frontend
│   ├── package.json # Frontend dependencies and scripts
├── nginx            # Contains the Nginx configuration
│   ├── Dockerfile   # Dockerfile for Nginx reverse proxy
│   └── nginx.conf   # Nginx configuration file
├── docker-compose.yml # Docker Compose file for orchestration
└── README.md        # Project documentation
```

## Getting Started

### Prerequisites

- Docker
- Docker Compose

### Setup Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   cd my-mern-app
   ```

2. Build and run the application using Docker Compose:
   ```
   docker-compose up --build
   ```

3. Access the application:
   - Frontend: `https://localhost`
   - Backend API: `https://localhost/api`

### Usage

- The backend is built with Express and connects to a MongoDB database.
- The frontend is a React application that communicates with the backend API.
- Nginx serves as a reverse proxy, handling HTTPS requests and routing them to the appropriate services.

### Contributing

Feel free to submit issues or pull requests for improvements or bug fixes.

### License

This project is licensed under the MIT License.