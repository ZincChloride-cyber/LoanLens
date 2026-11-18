# Run once before presentation — confirms data, model, and API without starting a server.
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
$Python = Join-Path $Root ".venv\Scripts\python.exe"

if (-not (Test-Path $Python)) { throw "Missing .venv — see scripts/start_loanlens.ps1 header." }

Write-Host "[1/3] Raw data" -ForegroundColor Cyan
& $Python -m src.download_data

Write-Host "[2/3] Model + predict smoke test" -ForegroundColor Cyan
& $Python -c @"
from fastapi.testclient import TestClient
from web.server import app
c = TestClient(app)
assert c.get('/api/health').json()['model_ready']
ex = c.get('/api/example').json()
r = c.post('/api/predict', json={'applicant': ex['applicant'], 'policy': 'standard', 'explain': True})
r.raise_for_status()
body = r.json()
print('Example', ex['loan_id'], '->', body['prediction'], f\"prob={body['probability']:.3f}\")
assert body.get('explanation') and body['explanation'].get('image')
print('SHAP: OK')
"@

Write-Host "[3/3] Automated tests (fast subset)" -ForegroundColor Cyan
& $Python -m pytest tests/test_web_api.py::test_real_prediction_matches_shared_pipeline tests/test_data.py -q --tb=line

Write-Host ""
Write-Host "All checks passed. Run: .\scripts\start_loanlens.ps1" -ForegroundColor Green