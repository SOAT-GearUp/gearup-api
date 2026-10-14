# OpenTelemetry Collector local

O modo debug permite validar o fluxo de logs, métricas e traces sem depender de uma conta ou chave de fornecedor.

## Executar todo o ambiente no Docker

Na raiz do repositório, execute o Compose principal junto com o override de observabilidade:

```powershell
docker compose `
  -f .\docker-compose.yml `
  -f .\docker-compose.observability.yml `
  up --build -d
```

O override adiciona o Collector à mesma rede da API e configura internamente:

```text
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
```

Nesse modo, não é necessário configurar `OTEL_EXPORTER_OTLP_ENDPOINT` no PowerShell nem utilizar `host.docker.internal`.

Teste a API e acompanhe a telemetria:

```powershell
Invoke-WebRequest http://localhost:8080/health/live
Invoke-WebRequest http://localhost:8080/health/ready

docker compose `
  -f .\docker-compose.yml `
  -f .\docker-compose.observability.yml `
  logs -f otel-collector
```

Para encerrar o ambiente completo:

```powershell
docker compose `
  -f .\docker-compose.yml `
  -f .\docker-compose.observability.yml `
  down
```

Os registros `ResourceSpans`, `ResourceMetrics` e `ResourceLogs` do comando `logs` confirmam o recebimento de traces, métricas e logs.

Este diretório contém somente a configuração necessária para o ambiente Docker local. O Collector de produção, o Datadog Agent, dashboards e monitores são mantidos no repositório [`gearup-infra-k8s`](https://github.com/SOAT-GearUp/gearup-infra-k8s).
