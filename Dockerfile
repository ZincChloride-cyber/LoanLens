FROM python:3.12-slim AS dependencies

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    MPLCONFIGDIR=/tmp/matplotlib \
    NUMBA_CACHE_DIR=/tmp/numba \
    WEB_HOST=0.0.0.0 \
    PORT=8000

WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends libgomp1 \
    && rm -rf /var/lib/apt/lists/*
COPY requirements-web.txt ./
RUN pip install --no-cache-dir -r requirements-web.txt \
    && useradd --uid 10001 --create-home loanlens

FROM dependencies AS runtime
COPY src ./src
COPY web ./web
COPY models ./models
COPY data/raw ./data/raw
COPY reports ./reports
# Raw CSV is not in Git; download at build time (Render, CI, fresh clones).
RUN python -m src.download_data \
    && python -c "from src.common import load_data, file_hash, ROOT; from src.predict import load_artifact; load_data(); assert load_artifact()['raw_sha256'] == file_hash(ROOT / 'data/raw/train.csv')"
USER loanlens
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s \
    CMD python -c "import json,os,urllib.request; r=json.load(urllib.request.urlopen('http://127.0.0.1:'+os.environ.get('PORT','8000')+'/api/health')); assert r['model_ready']"
CMD ["python", "-m", "web"]
