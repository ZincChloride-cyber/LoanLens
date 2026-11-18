# LoanLens — start the demo server (use this before your viva/presentation).
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$Python = Join-Path $Root ".venv\Scripts\python.exe"
if (-not (Test-Path $Python)) {
    Write-Host "Virtual environment not found. Run once:" -ForegroundColor Yellow
    Write-Host "  python -m venv .venv"
    Write-Host "  .\.venv\Scripts\pip install -r requirements-lock.txt"
    Write-Host "  .\.venv\Scripts\python -m src.download_data"
    exit 1
}

Write-Host "Checking raw data..." -ForegroundColor Cyan
& $Python -m src.download_data | Out-Host

Write-Host "Quick health check (loads model in-process)..." -ForegroundColor Cyan
& $Python -c "from fastapi.testclient import TestClient; from web.server import app; r=TestClient(app).get('/api/health'); assert r.status_code==200 and r.json()['model_ready'], r.text; print('OK:', r.json())"

$Port = 8000
$Url = "http://127.0.0.1:$Port"

Write-Host ""
Write-Host "Starting LoanLens at $Url" -ForegroundColor Green
Write-Host "Keep this window open during the demo. Press Ctrl+C to stop." -ForegroundColor DarkGray
Write-Host ""

Start-Process $Url
& $Python -m web --port $Port