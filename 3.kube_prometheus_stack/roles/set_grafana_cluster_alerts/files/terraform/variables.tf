variable "grafana_url" {
  description = "Grafana server URL"
  type        = string
  default     = "http://localhost:18276"
}

variable "grafana_auth" {
  description = "Grafana authentication credentials in username:password format"
  type        = string
}

variable "telegram_token" {
  description = "Telegram bot token"
  type        = string
}

variable "telegram_chat_id" {
  description = "Telegram chat ID"
  type        = string
}
