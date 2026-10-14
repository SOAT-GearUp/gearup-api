[CmdletBinding()]
param(
    [string]$BaseUrl = "http://localhost:8080",
    [string]$AdminUser = $(if ($env:SEED_ADMIN_USER) { $env:SEED_ADMIN_USER } else { "admin" }),
    [string]$AdminPassword = $env:SEED_ADMIN_PASSWORD,
    [ValidateRange(1, 10000)]
    [int]$Iterations = 20,
    [ValidateRange(0, 3600)]
    [double]$IntervalSeconds = 1
)

$ErrorActionPreference = "Stop"
$BaseUrl = $BaseUrl.TrimEnd("/")

if ([string]::IsNullOrWhiteSpace($AdminPassword)) {
    throw "Informe -AdminPassword ou defina a variavel de ambiente SEED_ADMIN_PASSWORD."
}

function Invoke-GearUpRequest {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("GET", "POST")]
        [string]$Method,
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$Token,
        [string]$Body,
        [string]$Scenario
    )

    $correlationId = [Guid]::NewGuid().ToString()
    $responseFile = [System.IO.Path]::GetTempFileName()
    $requestFile = $null
    $arguments = @(
        "--silent",
        "--show-error",
        "--output", $responseFile,
        "--write-out", "%{http_code}|%{time_total}",
        "--request", $Method,
        "--header", "Accept: application/json",
        "--header", "X-Correlation-ID: $correlationId"
    )

    if (-not [string]::IsNullOrWhiteSpace($Token)) {
        $arguments += @("--header", "Authorization: Bearer $Token")
    }

    if (-not [string]::IsNullOrWhiteSpace($Body)) {
        $requestFile = [System.IO.Path]::GetTempFileName()
        [System.IO.File]::WriteAllText(
            $requestFile,
            $Body,
            [System.Text.UTF8Encoding]::new($false))

        $arguments += @(
            "--header", "Content-Type: application/json",
            "--data-binary", "@$requestFile"
        )
    }

    $arguments += "$BaseUrl$Path"

    try {
        $result = & curl.exe @arguments

        if ($LASTEXITCODE -ne 0) {
            throw "curl.exe terminou com o codigo $LASTEXITCODE."
        }

        $parts = $result -split "\|", 2
        $statusCode = $parts[0]
        $duration = if ($parts.Count -gt 1) { $parts[1] } else { "n/a" }

        Write-Host ("{0} {1,-4} {2,-55} status={3} tempo={4}s correlationId={5}" -f `
                (Get-Date -Format "HH:mm:ss"), $Method, $Scenario, $statusCode, $duration, $correlationId)

        return [PSCustomObject]@{
            StatusCode    = [int]$statusCode
            Body          = Get-Content -LiteralPath $responseFile -Raw
            CorrelationId = $correlationId
        }
    }
    finally {
        Remove-Item -LiteralPath $responseFile -Force -ErrorAction SilentlyContinue

        if ($requestFile) {
            Remove-Item -LiteralPath $requestFile -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "Autenticando em $BaseUrl..."

$loginBody = @{
    usuario = $AdminUser
    senha   = $AdminPassword
} | ConvertTo-Json -Compress

$login = Invoke-GearUpRequest `
    -Method POST `
    -Path "/api/autenticacao/login" `
    -Body $loginBody `
    -Scenario "login valido"

if ($login.StatusCode -ne 200) {
    throw "Falha no login (HTTP $($login.StatusCode)): $($login.Body)"
}

$token = ($login.Body | ConvertFrom-Json).accessToken

if ([string]::IsNullOrWhiteSpace($token)) {
    throw "A resposta do login nao possui accessToken."
}

Write-Host "Iniciando $Iterations iteracoes. Pressione Ctrl+C para interromper."

for ($iteration = 1; $iteration -le $Iterations; $iteration++) {
    Write-Host "`nIteracao $iteration de $Iterations"

    Invoke-GearUpRequest `
        -Method GET `
        -Path "/health/live" `
        -Scenario "health check valido" | Out-Null

    Invoke-GearUpRequest `
        -Method GET `
        -Path "/api/clientes" `
        -Token $token `
        -Scenario "listagem de clientes valida" | Out-Null

    $clienteInexistenteId = [Guid]::NewGuid()
    Invoke-GearUpRequest `
        -Method GET `
        -Path "/api/clientes/$clienteInexistenteId" `
        -Token $token `
        -Scenario "cliente inexistente (404 esperado)" | Out-Null

    $estoqueInexistenteId = [Guid]::NewGuid()
    $movimentacaoBody = @{
        tipo       = 1
        quantidade = 1
        motivo     = "Teste de observabilidade Datadog"
    } | ConvertTo-Json -Compress

    Invoke-GearUpRequest `
        -Method POST `
        -Path "/api/estoque/$estoqueInexistenteId/movimentacoes" `
        -Token $token `
        -Body $movimentacaoBody `
        -Scenario "movimentacao em item inexistente (404 esperado)" | Out-Null

    if ($iteration -lt $Iterations -and $IntervalSeconds -gt 0) {
        Start-Sleep -Milliseconds ([int]($IntervalSeconds * 1000))
    }
}

Write-Host "`nGeracao de logs concluida."
