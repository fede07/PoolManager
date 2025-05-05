
# PoolManager

**PoolManager** is a web application designed to streamline the organization and management of 8‑ball pool tournaments. It assists tournament organizers in handling player registrations, match scheduling, bracket generation, and real‑time score tracking, ensuring a seamless tournament experience.

## Features

- **Player Management**  
  Register players, manage profiles, and track statistics.

- **Match Scheduling**  
  Automatically generate matchups and brackets.

- **Score Tracking**  
  Input and update match scores in real time.

## Tech Stack

- **Backend**: Ruby on Rails
- **Database**: PostgreSQL
- **Containerization**: Docker & Docker Compose
- **API Documentation**: Swagger (OpenAPI v1)

## Installation

### Prerequisites

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Git](https://git-scm.com/)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/fede07/PoolManager.git
   cd PoolManager
   ```

2. **Configure environment variables**
   ```bash
   cp .env.template .env
   ```  
   Edit `.env` to set your database credentials, ports, and any API keys.

3. **Build and run with Docker Compose**
   ```bash
   docker compose up --build
   ```  
   The app will be available at `http://localhost:3000`.

## Running Tests

To run the full test suite: 

```bash
docker compose exec web bundle exec rails test
```

## API Documentation

Swagger UI is available at:

```
http://localhost:3000/api-docs
```
