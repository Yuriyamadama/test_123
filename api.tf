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

# /Users/yuriyamada/.config/gcloud/application_default_credentials.json


# gcloud auth listで表示
# たとえば、次のコマンドは、指定したサービス アカウントから提供された ID とアクセス権を使用して、ストレージ バケットを一覧表示します。

# gcloud storage buckets list --impersonate-service-account=SERVICE_ACCT_EMAIL


# Use auth/impersonate_service_account if:
# gcloud config set auth/impersonate_service_account SERVICE_ACCT_EMAIL
# gcloud CLI で権限借用をデフォルトで使用する
#Use gcloud config set auth/impersonate_service_account when you need to run commands on behalf of a service account 
#without switching the active account. !
#This is typically used in cases where you want to delegate permissions to another service account, such as in CI/CD pipelines.
# デフォルトでサービス アカウントによって提供される ID とアクセス権を使用するように gcloud CLI を設定するには、gcloud CLI config コマンドを使用します。
# You want to impersonate a service account temporarily.
# Your current credentials have permission to impersonate the service account.
# You need to preserve your current active account.
# Use gcloud config set auth/impersonate_service_account 
# when you want to impersonate a service account across multiple gcloud commands without having to repeat the impersonation flag each time.

# Use set account if:
#  gcloud config set account githubaction-for@glassy-iridium-438509-u8.iam.gserviceaccount.com
# Use gcloud config set account when you want to authenticate directly as a service account or another user, 
# meaning all commands will execute with the full permissions of that account.
# You want to switch to a service account or another account directly.
#but all commands will execute as the service account.
# The service account is authenticated with a key file or gcloud auth activate-service-account.

# Key Difference:
# Impersonation (auth/impersonate_service_account): You remain logged in with your original account, but for specific commands, you're temporarily using another service account's permissions.
# Account Switch (gcloud config set account): You actually change the authenticating account, so all future gcloud operations will be executed as that account.

#gcloud auth application-default login --impersonate-service-account githubaction-for@glassy-iridium-438509-u8.iam.gserviceaccount.com
#Temporary, applies to the specific gcloud session you're running!
# gcloud auth application-default login command configures Application Default Credentials (ADC) for libraries and SDKs, 
# but it does not change the active user account for the gcloud CLI. Thus, your personal account remains the active account in the gcloud auth list.
# https://cloud.google.com/docs/authentication/use-service-account-impersonation?hl=ja
# 特定の gcloud CLI コマンドで権限借用を使用するには、--impersonate-service-account フラグを使用します。
#Use gcloud auth application-default login --impersonate-service-account 
#when you need to authenticate with Google Cloud and use Application Default Credentials (ADC) as a service account for an API call or other application-specific task.

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