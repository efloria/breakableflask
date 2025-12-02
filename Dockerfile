FROM python:3.12-alpine AS build
WORKDIR /app
RUN apk add --no-cache build-base gcc libpq-dev
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt
COPY . /app

FROM python:3.12-alpine
WORKDIR /app
RUN apk add --no-cache libpq
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=build /install /usr/local
COPY --from=build /app /app
RUN chown -R appuser:appgroup /app
ENV PYTHONUNBUFFERED=1
USER appuser
EXPOSE 4000
CMD ["python3", "main.py"]
HEALTHCHECK CMD curl -f http://localhost:5000/ || exit 1
