FROM python:3.11-slim

WORKDIR /app

# Copier les dépendances
COPY requirements.txt .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code
COPY app.py .

# Exposer le port
EXPOSE 5000

# Lancer l'application
CMD ["python", "app.py"]