# https://blog.g-gen.co.jp/entry/using-terraform-via-github-actions

# local 定義


provider "google" {
    project = var.project_id
    region = var.region
} 

#先にbucketを作成、名前の変更
#ローカルでテスト
#ファイルを移動

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
        bucket = "glassy-iridium-438509-u8-tfstate"
        prefix = "terraform/state"
    }
}    

# https://cloud.google.com/blog/ja/products/identity-security/secure-your-use-of-third-party-tools-with-identity-federation?hl=ja
# Workload Identity Pool 設定

resource "google_iam_workload_identity_pool" "mypool" {
    provider                  = google-beta
    project                   = local.project_id
    workload_identity_pool_id = "mypool"
    display_name              = "mypool"
    description               = "GitHub Actions で使用"
}
  
# Workload Identity Provider 設定

  
resource "google_iam_workload_identity_pool_provider" "github_actions_oidc" {
  project                            = local.project_id
  workload_identity_pool_provider_id = "myprovider"
  workload_identity_pool_id          = google_iam_workload_identity_pool.mypool.workload_identity_pool_id 
  display_name              = "GitHub Actions OIDC Provider"
  description                        = "GitHub Actions で使用"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com/"
  }

  attribute_mapping = {
    "google.subject"          = "assertion.sub"
    "attribute.repository"    = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.branch"        = "assertion.sub.extract('/heads/{branch}/')"
  }

  attribute_condition = "assertion.repository_owner=='sec-mik'"
}

# resource "google_iam_workload_identity_pool_provider" "myprovider" {
#     provider                           = google-beta
#     project                            = local.project_id
#     workload_identity_pool_id          = google_iam_workload_identity_pool.mypool.workload_identity_pool_id
#     workload_identity_pool_provider_id = "myprovider"
#     display_name                       = "myprovider"
#     description                        = "GitHub Actions で使用"
    
#     attribute_mapping = {
#         "google.subject"       = "assertion.sub"
#         "attribute.repository" = "assertion.repository"
#     }
    
#     oidc {
#         issuer_uri = "https://token.actions.githubusercontent.com"
#     }
# }
