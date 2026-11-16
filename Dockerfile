# --- Stage unique optimisé ou Multi-stage propre ---
FROM python:3.10-slim AS builder

WORKDIR /app

# Installation des outils de compilation nécessaires
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copie et installation des dépendances dans /usr/local directement
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Stage final d'exécution ---
FROM python:3.10-slim

WORKDIR /app

# Récupération des bibliothèques Python installées globalement depuis le builder
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copie du code source de l'application
COPY . .

# Création et bascule sur un utilisateur non-root (Sécurité)
RUN useradd -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]