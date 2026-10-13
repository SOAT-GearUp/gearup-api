# Monitores do Datadog com Terraform

Esta pasta versiona os monitores de CPU, respostas HTTP 404 e erros internos da API GearUp.

## Pre-requisitos

1. Criar uma API Key na organizacao Datadog de destino.
2. Criar uma Application Key com permissoes `monitors_read` e `monitors_write`.
3. Configurar a integracao do Slack e disponibilizar o canal `@slack-alertas-datadog`.
4. Ter Terraform 1.5 ou superior instalado.

## Aplicacao

Defina as credenciais apenas na sessao local:

```powershell
$env:DD_API_KEY="api-key-da-organizacao"
$env:DD_APP_KEY="application-key-da-organizacao"
```

Caso a organizacao utilize outro site Datadog, defina tambem o endpoint:

```powershell
$env:DD_HOST="https://api.datadoghq.eu"
```

Execute:

```powershell
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

O estado Terraform, os planos e os arquivos locais de variaveis sao ignorados pelo Git. Nunca adicione API Keys ou Application Keys aos arquivos `.tf`.

## Nova organizacao

Ao migrar para outra organizacao, configure novas chaves, recrie a integracao do Slack e execute novamente `terraform apply` usando um estado Terraform novo. O historico dos monitores da organizacao anterior nao e transferido.
