# Observabilidade local

Este diretório contém somente os componentes auxiliares para validar localmente a telemetria produzida pela API.

- `collector/`: configurações do OpenTelemetry Collector para exportação `debug` ou Datadog.
- `datadog/`: exemplo de variáveis e instruções para executar o Agent e o exporter no Docker Compose.

A instrumentação da aplicação fica em `src/GearUp.Api/Observability`. A infraestrutura de produção, dashboards e monitores como código ficam no repositório [`gearup-infra-k8s`](https://github.com/SOAT-GearUp/gearup-infra-k8s).

Não devem ser adicionados aqui estados Terraform, dashboards, monitores nem credenciais reais do fornecedor.
