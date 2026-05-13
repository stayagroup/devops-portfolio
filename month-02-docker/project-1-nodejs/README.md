# Node.js Docker Project

Multi-stage Dockerfile for Node.js application.

## Build
```bash
docker build -t devops-app:1.0 .
```

## Run
```bash
docker run -p 3000:3000 devops-app:1.0
```

## Test
```bash
curl http://localhost:3000
curl http://localhost:3000/health
```

## Features
- Multi-stage build (smaller final image)
- Health check
- Environment variable support (PORT)
