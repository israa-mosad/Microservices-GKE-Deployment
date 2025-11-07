FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose Flask port
EXPOSE 5000

# Start the application
CMD ["sh", "-c", "export FLASK_APP=run.py && flask run --host=0.0.0.0 --port=5000"]