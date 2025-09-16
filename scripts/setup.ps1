# Escrow Service Setup Script for Windows
# Run this script with: PowerShell -ExecutionPolicy Bypass -File setup.ps1

Write-Host "🚀 Setting up Escrow Service Platform..." -ForegroundColor Green

# Check if Node.js is installed
Write-Host "Checking Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found. Please install Node.js 18+ first." -ForegroundColor Red
    exit 1
}

# Check if PostgreSQL is available
Write-Host "Checking PostgreSQL..." -ForegroundColor Yellow
try {
    psql --version
    Write-Host "✅ PostgreSQL is available" -ForegroundColor Green
} catch {
    Write-Host "⚠️  PostgreSQL not found. You can use Docker instead." -ForegroundColor Yellow
}

# Create environment files from examples
Write-Host "Creating environment files..." -ForegroundColor Yellow

if (!(Test-Path "backend\.env")) {
    Copy-Item "backend\.env.example" "backend\.env"
    Write-Host "✅ Created backend/.env from example" -ForegroundColor Green
} else {
    Write-Host "✅ backend/.env already exists" -ForegroundColor Green
}

if (!(Test-Path "frontend\.env.local")) {
    @"
VITE_API_URL=http://localhost:5000/api
VITE_NODE_ENV=development
VITE_PAYFAST_MERCHANT_ID=your-payfast-merchant-id
VITE_ENABLE_2FA=true
VITE_APP_NAME=Escrow Service Platform
VITE_APP_VERSION=1.0.0
"@ | Out-File -FilePath "frontend\.env.local" -Encoding UTF8
    Write-Host "✅ Created frontend/.env.local" -ForegroundColor Green
} else {
    Write-Host "✅ frontend/.env.local already exists" -ForegroundColor Green
}

# Install backend dependencies
Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
Set-Location "backend"
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install backend dependencies" -ForegroundColor Red
    Set-Location ".."
    exit 1
}
Set-Location ".."

# Install frontend dependencies
Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
Set-Location "frontend"
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install frontend dependencies" -ForegroundColor Red
    Set-Location ".."
    exit 1
}
Set-Location ".."

# Create initial database setup script
Write-Host "Creating database setup script..." -ForegroundColor Yellow
$dbSetupScript = @"
-- Initial database setup for Escrow Service
-- Run this script in your PostgreSQL instance

CREATE DATABASE escrow_service;
CREATE USER escrow_user WITH ENCRYPTED PASSWORD 'escrow_password';
GRANT ALL PRIVILEGES ON DATABASE escrow_service TO escrow_user;

-- Connect to the escrow_service database and grant schema privileges
\c escrow_service;
GRANT ALL ON SCHEMA public TO escrow_user;
"@

$dbSetupScript | Out-File -FilePath "database\init-db.sql" -Encoding UTF8
Write-Host "✅ Created database/init-db.sql" -ForegroundColor Green

# Create basic Docker files
Write-Host "Creating Docker development files..." -ForegroundColor Yellow

# Backend Dockerfile.dev
$backendDockerfile = @"
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 5000

CMD ["npm", "run", "dev"]
"@
$backendDockerfile | Out-File -FilePath "backend\Dockerfile.dev" -Encoding UTF8

# Frontend Dockerfile.dev  
$frontendDockerfile = @"
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
"@
$frontendDockerfile | Out-File -FilePath "frontend\Dockerfile.dev" -Encoding UTF8

Write-Host "✅ Created Docker development files" -ForegroundColor Green

# Create quick start scripts
$startScript = @"
# Quick Start Script
Write-Host "Starting Escrow Service Platform..." -ForegroundColor Green

# Start backend
Write-Host "Starting backend server..." -ForegroundColor Yellow
Start-Process -FilePath "cmd" -ArgumentList "/c", "cd backend && npm run dev" -WindowStyle Normal

# Wait a moment for backend to start
Start-Sleep -Seconds 3

# Start frontend
Write-Host "Starting frontend server..." -ForegroundColor Yellow
Start-Process -FilePath "cmd" -ArgumentList "/c", "cd frontend && npm run dev" -WindowStyle Normal

Write-Host "🚀 Services starting..." -ForegroundColor Green
Write-Host "Backend: http://localhost:5000" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
"@
$startScript | Out-File -FilePath "scripts\start.ps1" -Encoding UTF8

Write-Host "✅ Created start script" -ForegroundColor Green

# Final instructions
Write-Host "`n🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Update the .env files with your actual configuration values" -ForegroundColor White
Write-Host "2. Set up your PostgreSQL database (or use Docker)" -ForegroundColor White
Write-Host "3. Configure PayFast credentials in backend/.env" -ForegroundColor White
Write-Host "4. Run: .\scripts\start.ps1 to start the development servers" -ForegroundColor White
Write-Host "`nOr use Docker:" -ForegroundColor Yellow
Write-Host "docker-compose up -d" -ForegroundColor White

Write-Host "`n📚 Check the docs/ folder for detailed documentation" -ForegroundColor Cyan
