FROM redis:7

COPY redis.conf /app/

WORKDIR /app
