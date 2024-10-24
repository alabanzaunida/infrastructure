terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.9"
    }
  }
}

provider "grafana" {
  url  = var.grafana_url
  auth = var.grafana_auth
}

resource "grafana_folder" "alert_folder" {
  title = "Cluster Monitoring Alerts"
}

resource "grafana_contact_point" "contact_point_670f28d46e226feb" {
  name = "IT Iglesia Unida"

  telegram {
    token                    = var.telegram_token
    chat_id                  = var.telegram_chat_id
    message_thread_id        = ""
    message                  = "{{ template \"basic\" . }}"
    disable_web_page_preview = false
    protect_content          = false
  }
}

resource "grafana_message_template" "basic_template" {
  name     = "basic"
  template = <<EOT
{{ define "basic" }}
  {{ range .Alerts }}
    {{- if eq .Status "firing" }}
      🚨 Firing
{{ .Annotations.summary }}
Start Time: {{ .StartsAt.Format "15:04 UTC" }}
    {{ else if eq .Status "resolved" }}
      ✅ Resolved
{{ .Annotations.summary }}
Resolved Time: {{ .EndsAt.Format "15:04 UTC" }}
    {{ end }}
  {{ end }}
{{ end }}
EOT
}


resource "grafana_rule_group" "rule_group_a94442e6972097f5" {
  org_id           = "1"
  name             = "Cluster"
  folder_uid       = grafana_folder.alert_folder.uid
  interval_seconds = 60

  rule {
    name      = "Cluster RAM"
    condition = "C"

    data {
      ref_id = "A"
      
      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "prometheus"
      model          = jsonencode({
        editorMode     = "code"
        expr           = "100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))"
        instant        = true
        intervalMs     = 1000
        legendFormat   = "__auto"
        maxDataPoints  = 43200
        range          = false
        refId          = "A"
      })
    }

    data {
      ref_id = "C"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        conditions = [
          {
            evaluator = {
              params = [70]
              type   = "gt"
            }
            operator = {
              type = "and"
            }
            query = {
              params = ["C"]
            }
            reducer = {
              params = []
              type   = "last"
            }
            type = "query"
          }
        ]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression      = "A"
        intervalMs      = 1000
        maxDataPoints   = 43200
        refId           = "C"
        type            = "threshold"
      })
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "1m"

    annotations = {
      summary = "RAM usage is above 70% on cluster"
    }

    labels = {}

    is_paused = false

    notification_settings {
      contact_point = "IT Iglesia Unida"
    }
  }

  rule {
    name      = "Cluster CPU"
    condition = "C"

    data {
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "prometheus"
      model          = jsonencode({
        editorMode     = "code"
        expr           = "100 * (1 - avg by (instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])))"
        instant        = true
        intervalMs     = 1000
        legendFormat   = "__auto"
        maxDataPoints  = 43200
        range          = false
        refId          = "A"
      })
    }

    data {
      ref_id = "C"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = jsonencode({
        conditions = [
          {
            evaluator = {
              params = [70]
              type   = "gt"
            }
            operator = {
              type = "and"
            }
            query = {
              params = ["C"]
            }
            reducer = {
              params = []
              type   = "last"
            }
            type = "query"
          }
        ]
        datasource = {
          type = "__expr__"
          uid  = "__expr__"
        }
        expression      = "A"
        intervalMs      = 1000
        maxDataPoints   = 43200
        refId           = "C"
        type            = "threshold"
      })
    }

    no_data_state  = "NoData"
    exec_err_state = "Error"
    for            = "30s"

    annotations = {
      summary = "CPU usage is above 70% on cluster"
    }

    labels = {}

    is_paused = false

    notification_settings {
      contact_point = "IT Iglesia Unida"
    }
  }
}
