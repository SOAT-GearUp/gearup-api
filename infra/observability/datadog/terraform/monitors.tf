resource "datadog_monitor" "cpu_alto_containers" {
  name    = "Uso de CPU alto no container {{container_name.name}}"
  type    = "query alert"
  query   = <<EOT
avg(last_5m):avg:container.cpu.usage{container_name:gearup-*} by {container_name} > 25000000
EOT
  message = <<EOT
{{#is_alert}}
Uso de CPU critico no container {{container_name.name}}.
Valor atual: {{value}}. Limite: {{threshold}}.

@slack-alertas-datadog
{{/is_alert}}

{{#is_warning}}
Uso de CPU elevado no container {{container_name.name}}.
Valor atual: {{value}}. Limite: {{warn_threshold}}.

@slack-alertas-datadog
{{/is_warning}}

{{#is_recovery}}
O uso de CPU do container {{container_name.name}} voltou ao normal.

@slack-alertas-datadog
{{/is_recovery}}
EOT

  tags = [
    "service:gearup-api",
    "env:development",
    "monitor:container-cpu"
  ]

  priority                 = 3
  draft_status             = "published"
  include_tags             = true
  new_group_delay          = 30
  notification_preset_name = "show_all"
  on_missing_data          = "show_no_data"
  require_full_window      = false

  monitor_thresholds {
    critical = 25000000
    warning  = 15000000
  }
}

resource "datadog_monitor" "http_404_elevado" {
  name    = "Quantidade elevada de HTTP 404 em {{resource_name.name}}"
  type    = "query alert"
  query   = <<EOT
sum(last_5m):sum:trace.http.server.request.hits{service:gearup-api,http.status_code:404} by {env,resource_name}.as_count() > 8
EOT
  message = <<EOT
{{#is_alert}}
Quantidade critica de respostas HTTP 404.

Ambiente: {{env.name}}
Endpoint: {{resource_name.name}}
Quantidade: {{value}}
Limite critico: {{threshold}}

Verifique rotas invalidas, parametros incorretos e recursos nao encontrados.

@slack-alertas-datadog
{{/is_alert}}

{{#is_warning}}
A quantidade de respostas HTTP 404 esta aumentando.

Ambiente: {{env.name}}
Endpoint: {{resource_name.name}}
Quantidade: {{value}}
Limite de aviso: {{warn_threshold}}

@slack-alertas-datadog
{{/is_warning}}

{{#is_recovery}}
A quantidade de respostas HTTP 404 voltou ao nivel normal.

Ambiente: {{env.name}}
Endpoint: {{resource_name.name}}

@slack-alertas-datadog
{{/is_recovery}}
EOT

  tags = [
    "service:gearup-api",
    "env:development",
    "monitor:http-404"
  ]

  priority            = 3
  draft_status        = "published"
  include_tags        = true
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 8
    warning  = 6
  }
}

resource "datadog_monitor" "erro_interno_api" {
  name    = "Erro interno detectado na API GearUp"
  type    = "log alert"
  query   = <<EOT
logs("service:gearup-api status:error \"Erro não tratado ao processar a requisição\"").index("*").rollup("count").last("5m") > 0
EOT
  message = <<EOT
{{#is_alert}}
Foi detectado um erro interno na API GearUp.

Servico: gearup-api
Quantidade: {{value}}
Limite: {{threshold}}

Verifique os logs e o trace associado para identificar a causa.

@slack-alertas-datadog
{{/is_alert}}

{{#is_recovery}}
Nenhum novo erro interno foi identificado na janela de monitoramento.

@slack-alertas-datadog
{{/is_recovery}}
EOT

  tags = [
    "service:gearup-api",
    "env:development",
    "monitor:internal-error"
  ]

  priority               = 2
  draft_status           = "published"
  groupby_simple_monitor = false
  include_tags           = false
  on_missing_data        = "default"
  require_full_window    = false

  monitor_thresholds {
    critical = 0
  }
}
