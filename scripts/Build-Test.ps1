# RoMoo io — compilador de teste no Windows.
# Basta baixar este repositorio ZIP do GitHub e abrir 'TESTAR-ROMOO.cmd'.
# A compilacao e feita localmente. Os modelos CC0 externos precisam ser importados a parte.
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$tools = Join-Path $root ".tools"
$exe = Join-Path $tools "rojo.exe"
$target = Join-Path $root "RoMoo-io-Teste.rbxlx"
$project = Join-Path $root "default.project.json"
if (-not (Test-Path $project)) { throw "Nao encontrei default.project.json. Extraia TODO o ZIP primeiro." }

if (-not (Test-Path $exe)) {
    Write-Host "[RoMoo] Baixando Rojo 7.7.1 (utilitario oficial)..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force $tools | Out-Null
    $zip = Join-Path $tools "rojo.zip"
    $unpack = Join-Path $tools "unpacked"
    $url = "https://github.com/rojo-rbx/rojo/releases/download/v7.7.1/rojo-7.7.1-windows-x86_64.zip"
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $unpack -Force
    $found = Get-ChildItem -Path $unpack -Recurse -Filter "rojo.exe" | Select-Object -First 1
    if (-not $found) { throw "O ZIP do Rojo nao contem rojo.exe." }
    Copy-Item $found.FullName $exe -Force
    Remove-Item $zip -Force
    Remove-Item $unpack -Force -Recurse
}

Write-Host "[RoMoo] Verificando Rojo..." -ForegroundColor Cyan
& $exe --version
if ($LASTEXITCODE -ne 0) { throw "Rojo nao executou." }

Write-Host "[RoMoo] Montando arquivo Roblox..." -ForegroundColor Cyan
& $exe build $project -o $target
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $target)) {
    throw "Falha na compilacao. Envie o erro mostrado no console."
}

Write-Host "[RoMoo] Pronto: $target" -ForegroundColor Green
Write-Host "[RoMoo] Abrindo no Roblox Studio..." -ForegroundColor Green
try { Start-Process -FilePath $target }
catch {
    Write-Warning "Nao consegui abrir automaticamente. Abra o Roblox Studio > Arquivo > Abrir e selecione '$target'."
}
