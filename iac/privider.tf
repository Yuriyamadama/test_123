# local 定義
locals {
    github_repository           = var.
    project_id                  = var.project_id
    region                      = var.region
    terraform_service_account   = google_service_account.terraform.email
    
    # api 有効化用
    services = toset([                         # Workload Identity 連携用
        "iam.googleapis.com",                  # IAM
        "cloudresourcemanager.googleapis.com", # Resource Manager
        "iamcredentials.googleapis.com",       # Service Account Credentials
        "sts.googleapis.com"                   # Security Token Service API
    ])
}
  


# provider 設定
#使用するprpviderやバックエンドの場所を設定
terraform {
    required_providers {
        google  = {
            source  = "hashicorp/google"
            version = ">= 4.0.0"
        }
    }
    required_version = ">= 1.3.0"
    backend "gcs" {
        bucket = "myproject_terraform_tfstate"
        prefix = "terraform/state"
    }
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
    




# Workload Identity Pool 設定
resource "google_iam_workload_identity_pool" "mypool" {
    provider                  = google-beta
    project                   = local.project_id
    workload_identity_pool_id = "mypool"
    display_name              = "mypool"
    description               = "GitHub Actions で使用"
}
  
# Workload Identity Provider 設定
resource "google_iam_workload_identity_pool_provider" "myprovider" {
    provider                           = google-beta
    project                            = local.project_id
    workload_identity_pool_id          = google_iam_workload_identity_pool.mypool.workload_identity_pool_id
    workload_identity_pool_provider_id = "myprovider"
    display_name                       = "myprovider"
    description                        = "GitHub Actions で使用"
    
    attribute_mapping = {
        "google.subject"       = "assertion.sub"
        "attribute.repository" = "assertion.repository"
    }
    
    oidc {
        issuer_uri = "https://token.actions.githubusercontent.com"
    }
}
  
# GitHub Actions が借用するサービスアカウント
data "google_service_account" "terraform_sa" {
    account_id = local.terraform_service_account
}
  
# サービスアカウントの IAM Policy 設定と GitHub リポジトリの指定
resource "google_service_account_iam_member" "terraform_sa" {
    service_account_id = data.google_service_account.terraform_sa.id
    role               = "roles/iam.workloadIdentityUser"
    member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.mypool.name}/attribute.repository/${local.github_repository}"
}


# locals {
#     terraformadmin_project_id = "${var.project_id}"
# }

# # サービス アカウントのアクセス トークンを取得するために使用するプロバイダを「別で」作成します。
# # プロバイダは「google」ですが、それに割り当てられている「impersonation」エイリアスにご注意ください。

# # scopes
# # 意味: このプロバイダーが GCP API にアクセスする際に必要な権限（スコープ）を指定しています。
# # 用途: TerraformがGoogle Cloudリソースを操作するための権限を設定します。

# provider "google" {
#     alias = "impersonation"
#     scopes = [
#         "https://www.googleapis.com/auth/cloud-platform",
#         "https://www.googleapis.com/auth/userinfo.email",
#     ]
# }

# # サービス アカウントとしての認証で使用するアクセス トークンを取得するためのデータブロックを追加します。
# # データブロックが先に指定した impersonation プロバイダとサービス アカウントを参照している点に注意してください。
# data "google_service_account_access_token" "default" {
#     provider               = google.impersonation
#     target_service_account = google_service_account.terraform.email
#     scopes                 = ["userinfo-email", "cloud-platform"]
#     lifetime               = "1200s"
# }

# # サービス アカウントのアクセス トークンを使用するもう 1 つの「google」プロバイダを記述します。
# # エイリアスがないため、これは Terraform コードの Google リソースに使用されるデフォルトのプロバイダになります。
  
# provider "google" {
#     project         = local.terraformadmin_project_id
#     region          = "asia-northeast1"
#     access_token    = data.google_service_account_access_token.default.access_token
#     request_timeout = "60s"
# }

# #サービス アカウントでリモート状態ファイルを更新する

# terraform {
#     required_providers {
#         google  = {
#             source  = "hashicorp/google"
#             version = ">= 4.0.0"
#         }
#     }
#     required_version = ">= 1.3.0"
  
#     backend "gcs" {
#         bucket                      = google_storage_bucket.tfstate.name
#         impersonate_service_account = google_service_account.terraform.email
#     }
# }

# # デフォルト ネットワークの作成をスキップ
# resource "google_org_policy_policy" "compute_skip_default_network_creation" {
#   name = "organizations/${var.organization_id}/compute.skipDefaultNetworkCreation"
#   parent     = "organizations/${var.organization_id}"
#   spec {
#     rules {
#       enforce = "TRUE"
#     }
#   }
# }
