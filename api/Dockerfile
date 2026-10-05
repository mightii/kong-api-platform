# Python 3.12 : les wheels de pydantic-core 2.16.3 existent (voir docs/02)
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .

# Utilisateur non-root : moindre privilège dans le conteneur
RUN useradd --create-home appuser
USER appuser

EXPOSE 5000
# 0.0.0.0 : écoute sur toutes les interfaces du conteneur (voir docs/03)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
