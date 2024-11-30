
# GitHub Actions が借用するサービスアカウント
data "google_service_account" "terraform_sa" {
    account_id = var.terraform_email
}

# サービスアカウントの IAM Policy 設定と GitHub リポジトリの指定、userとしてrepositoryを追加
resource "google_service_account_iam_member" "terraform_sa" {
    service_account_id = data.google_service_account.terraform_sa.id
    role               = "roles/iam.workloadIdentityUser"
    member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.mypool.name}/attribute.repository/${var.github_repository}"
}

# ファイル構成
# ls -lhはメタデータの大きさ
# du -sh iac がベスト
# git rm -r --cached iac/.terraform/

# Terraform 用サービスアカウントに IAM ロールを付与
# https://blog.g-gen.co.jp/entry/how-to-use-iam-resources-of-terraform
# 基本的にiam_memberを使っておけばok

# resource "google_organization_iam_member" "storage_admin" {
#   org_id = var.organization_id
#   role   = "roles/storage.admin"
#   member = "serviceAccount:${google_service_account.terraform.email}"
# }

# Within GCP, there is a hierarchy: Organization, Project, Resource
# The IAM policies you mentioned behaves the same; however, works on different levels based on the hierarchy.
# For example, the google_project_iam_member will update the IAM policy to grant a role to a new member on the project level.
# The google_organization_iam_member will do the same thing, but on the Organization level (which is a level higher than the project.

# resource "google_project_iam_member" "org_policy_admin" {
#   project = var.project_id
#   role   = "roles/orgpolicy.policyAdmin"
#   member = "serviceAccount:${var.terraform_email}"
# }

resource "google_project_iam_member" "tokencreator" {
  project = var.project_id
  role   = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${var.terraform_email}"
}

# Terraform コマンドを実行するユーザーアカウントに対し、「サービスアクセストークン作成者ロール」を付与します。

resource "google_project_iam_member" "service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "user:${var.user_account}"
}