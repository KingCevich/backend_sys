# ============================================================
#  SanosYSalvos - Script de inicio completo
#  Ejecutar desde la raiz del proyecto: .\start_sanosysalvos.ps1
#  Requiere: Docker corriendo, sys_venv y ia_venv creados
# ============================================================

$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$VENV = "$ROOT\sys_venv\Scripts\Activate.ps1"
$IA_VENV = "$ROOT\mascotas_serv\ia_venv\Scripts\Activate.ps1"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   SanosYSalvos - Iniciando servicios  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ── 1. Redis (Docker) ────────────────────────────────────────
Write-Host "[1/9] Iniciando Redis (Docker)..." -ForegroundColor Yellow
$redisStatus = docker inspect -f '{{.State.Running}}' redis 2>$null
if ($redisStatus -eq "true") {
    Write-Host "      Redis ya esta corriendo." -ForegroundColor Green
} else {
    docker start redis 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "      Creando contenedor Redis nuevo..." -ForegroundColor Gray
        docker run -d -p 6379:6379 --name redis redis | Out-Null
    }
    Write-Host "      Redis iniciado en localhost:6379" -ForegroundColor Green
}

Start-Sleep -Seconds 2

# ── Funcion para abrir nueva terminal ────────────────────────
function Open-Service {
    param(
        [string]$Title,
        [string]$Command
    )
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "
        `$host.UI.RawUI.WindowTitle = '$Title'
        $Command
    "
    Start-Sleep -Milliseconds 800
}

# ── 2. usuarios_serv (8000) ──────────────────────────────────
Write-Host "[2/9] Iniciando usuarios_serv  (puerto 8000)..." -ForegroundColor Yellow
Open-Service -Title "usuarios_serv :8000" -Command "
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
    & '$VENV'
    cd '$ROOT\usuarios_serv'
    python manage.py runserver 8000
"

# ── 3. auth_serv (8001) ──────────────────────────────────────
Write-Host "[3/9] Iniciando auth_serv      (puerto 8001)..." -ForegroundColor Yellow
Open-Service -Title "auth_serv :8001" -Command "
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
    & '$VENV'
    cd '$ROOT\auth_serv'
    python manage.py runserver 8001
"

# ── 4. mascotas_serv (8002) ──────────────────────────────────
Write-Host "[4/9] Iniciando mascotas_serv  (puerto 8002)..." -ForegroundColor Yellow
Open-Service -Title "mascotas_serv :8002" -Command "
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
    & '$VENV'
    cd '$ROOT\mascotas_serv'
    python manage.py runserver 8002
"

# ── 5. bff_serv (8003) ───────────────────────────────────────
Write-Host "[5/9] Iniciando bff_serv       (puerto 8003)..." -ForegroundColor Yellow
Open-Service -Title "bff_serv :8003" -Command "
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
    & '$VENV'
    cd '$ROOT\bff_serv'
    python manage.py runserver 8003
"

# ── 6. noticias_serv (8004) ──────────────────────────────────
Write-Host "[6/9] Iniciando noticias_serv  (puerto 8004)..." -ForegroundColor Yellow
Open-Service -Title "noticias_serv :8004" -Command "
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
    & '$VENV'
    cd '$ROOT\noticias_serv'
    python manage.py runserver 8004
"

# ── 7. notificaciones_serv (8005) ────────────────────────────
Write-Host "[7/9] Iniciando notificaciones_serv (puerto 8005)..." -ForegroundColor Yellow
Open-Service -Title "notificaciones_serv :8005" -Command "
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
    & '$VENV'
    cd '$ROOT\notificaciones_serv'
    python manage.py runserver 8005
"

# ── 8. FastAPI IA (8006) ──────────────────────────────────────
Write-Host "[8/9] Iniciando FastAPI IA     (puerto 8006)..." -ForegroundColor Yellow
Open-Service -Title "FastAPI IA :8006" -Command "
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
    & '$IA_VENV'
    cd '$ROOT\mascotas_serv\mascotas_app'
    uvicorn main_fastapi:app --host 0.0.0.0 --port 8006 --reload
"

# ── 9. Celery Worker ─────────────────────────────────────────
Write-Host "[9/9] Iniciando Celery worker..." -ForegroundColor Yellow
Open-Service -Title "Celery Worker" -Command "
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
    & '$VENV'
    cd '$ROOT\mascotas_serv'
    celery -A mascotas_serv worker --loglevel=info --pool=solo
"

# ── 10. Frontend (5173) ───────────────────────────────────────
Write-Host ""
Write-Host "Esperando que los servicios backend suban (5s)..." -ForegroundColor Gray
Start-Sleep -Seconds 5

Write-Host "[+]  Iniciando Frontend        (puerto 5173)..." -ForegroundColor Yellow
Open-Service -Title "Frontend :5173" -Command "
    cd '$ROOT\frontend_sys'
    npm run dev
"

# ── Resumen ───────────────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Todos los servicios iniciados        " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  usuarios_serv   -> http://localhost:8000" -ForegroundColor White
Write-Host "  auth_serv       -> http://localhost:8001" -ForegroundColor White
Write-Host "  mascotas_serv   -> http://localhost:8002" -ForegroundColor White
Write-Host "  bff_serv        -> http://localhost:8003" -ForegroundColor White
Write-Host "  noticias_serv   -> http://localhost:8004" -ForegroundColor White
Write-Host "  notificaciones  -> http://localhost:8005" -ForegroundColor White
Write-Host "  FastAPI IA      -> http://localhost:8006" -ForegroundColor White
Write-Host "  Frontend        -> http://localhost:5173" -ForegroundColor Cyan
Write-Host "  Redis           -> localhost:6379"        -ForegroundColor White
Write-Host "  Celery          -> worker activo"         -ForegroundColor White
Write-Host ""
Write-Host "Presiona cualquier tecla para cerrar esta ventana..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")