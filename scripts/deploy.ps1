# Exit on error
$ErrorActionPreference = "Stop"

# Load environment variables if .env exists
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        $name, $value = $_.Split('=', 2)
        if ($name -and $value) {
            [System.Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim())
        }
    }
}

Write-Host "🚀 Packaging Spring Boot application..." -ForegroundColor Green
./mvnw.cmd clean package -DskipTests

Write-Host "🐳 Building Docker image..." -ForegroundColor Green
docker build -t munashechibaya/inventory-app:latest .

Write-Host "📤 Deploying local docker-compose stack..." -ForegroundColor Green
docker compose down --remove-orphans
docker compose up -d

Write-Host "✅ Local deployment completed successfully! App running on port 80." -ForegroundColor Green
