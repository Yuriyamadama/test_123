# local 定義
locals {
    project_id                  = var.project_id
    
    # api 有効化用
    services = toset([                         # Workload Identity 連携用
        "iam.googleapis.com",                  # IAM
        "cloudresourcemanager.googleapis.com", # Resource Manager
        "iamcredentials.googleapis.com",       # Service Account Credentials
        "sts.googleapis.com"                   # Security Token Service API
    ])
}

variable "services" {
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com"
  ]
}

#↑のようにさまざまな表示方法がある。

# サービスを有効にする？
resource "google_project_service" "enabled_services" {
  for_each = toset(var.services)
  service  = each.key
}

## API の有効化(Workload Identity 用)
## localで定義したservicesを指定
## destroy時にサービスも無効化される
resource "google_project_service" "enable_api" {
  for_each                   = local.services
  project                    = local.project_id
  service                    = each.value
  disable_dependent_services = true
}