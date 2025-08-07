# Stage 1: Build dependencies
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-warn-script-location -r requirements.txt

# Stage 2: Runtime image
FROM python:3.11-slim
WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder /root/.local /root/.local
COPY . .

# Ensure scripts in .local are usable
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1

# Gunicorn CMD
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "RestaurantCore.wsgi"]
