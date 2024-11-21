
# Terraform 用サービスアカウントの作成
resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "terraform"
}

# Terraform 用サービスアカウントに IAM ロールを付与
# https://blog.g-gen.co.jp/entry/how-to-use-iam-resources-of-terraform
# 基本的にiam_memberを使っておけばok

resource "google_organization_iam_member" "storage_admin" {
  org_id = var.organization_id
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

# Within GCP, there is a hierarchy: Organization, Project, Resource
# The IAM policies you mentioned behaves the same; however, works on different levels based on the hierarchy.
# For example, the google_project_iam_member will update the IAM policy to grant a role to a new member on the project level.
# The google_organization_iam_member will do the same thing, but on the Organization level (which is a level higher than the project.

resource "google_project_iam_member" "org_policy_admin" {
  project = var.project_id
  role   = "roles/orgpolicy.policyAdmin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_project_iam_member" "org_policy_admin" {
  project = var.project_id
  role   = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${google_service_account.terraform.email}"
}


# Terraform コマンドを実行するユーザーアカウントに対し、「サービスアクセストークン作成者ロール」を付与します。

resource "google_project_iam_member" "service_account_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "user:${var.user_account}"
}