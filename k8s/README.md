# Workload Kubernetes da API

Esta pasta descreve o workload `gearup-api`, não a infraestrutura do cluster.

## Conteúdo

- `base/`: `Deployment`, `Service` e `HPA` reutilizados nos ambientes AWS.
- `overlays/`: customizações Kustomize de homologação e produção consumidas pelo workflow `.github/workflows/cd.yml`.
- `local/`: manifests para executar a API e o PostgreSQL em um Kubernetes local.

VPC, EKS, ECR, Metrics Server, OpenTelemetry Collector e Datadog Agent pertencem ao repositório [`gearup-infra-k8s`](https://github.com/SOAT-GearUp/gearup-infra-k8s).

Essa separação permite que a plataforma seja provisionada independentemente, enquanto cada versão da API leva consigo sua imagem e sua especificação de implantação.
