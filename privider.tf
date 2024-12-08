# local 定義
provider "google" {
    project = var.project_id
    region = var.region
} 



# provider 設定　使用するprpviderやバックエンドの場所を設定
terraform {
    required_providers {
        google  = {
            source  = "hashicorp/google"
            version = ">= 4.0.0"
        }
    }
    required_version = ">= 1.3.0"
    backend "gcs" {
        bucket = "glassy-iridium-438509-u8-tfstate"
        prefix = "terraform/state"
    }
}    

# Workload Identity Pool 設定

resource "google_iam_workload_identity_pool" "mypool" {
    provider                  = google-beta
    project                   = local.project_id
    workload_identity_pool_id = "mypool"
    display_name              = "mypool"
    description               = "GitHub Actions で使用"
}
  
# Workload Identity Provider 設定　for GitHub Actions
#oidc
# OIDCトークン（認証トークン）を発行するプロバイダーのURI。
# GitHub Actionsの場合は "https://token.actions.githubusercontent.com/" を指定します。
# この設定により、GitHub ActionsのOIDCトークンを使ってGoogle Cloudに認証できます。

# attribute_mapping
# 外部プロバイダー（GitHub Actions）から渡されるトークン属性を、Google Cloudで使える形式に変換する設定です。

# attribute_condition
# 条件を満たす場合のみ、このプロバイダーを使ったアクセスを許可します。

resource "google_iam_workload_identity_pool_provider" "github_actions_oidc" {
  project                            = local.project_id
  workload_identity_pool_provider_id = "myprovider"
  workload_identity_pool_id          = google_iam_workload_identity_pool.mypool.workload_identity_pool_id
  display_name                       = "GitHub Actions OIDC Provider"
  description                        = "GitHub Actions used for CI/CD"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com/"
  }

  attribute_mapping = {
    "google.subject"          = "assertion.sub"
    "attribute.repository"    = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.branch"        = "assertion.sub.extract('/heads/{branch}/')"
  }

  # Condition to restrict access to your specific GitHub repository
  attribute_condition = "attribute.repository == 'Yuriyamadama/test_123'"
}