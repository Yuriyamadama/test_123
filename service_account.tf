
# GitHub Actions が借用するサービスアカウント　事前に作成ずみ
data "google_service_account" "terraform_sa" {
    account_id = var.terraform_email
}

# サービスアカウントの IAM Policy 設定と GitHub リポジトリの指定、userとしてrepositoryを追加
#Workload Identity Pool Providerを通じて認証が成功した外部エンティティ（例：GitHubのWorkflow）が、
#特定のGCPリソースにアクセスできるように、GCPのService Accountと紐付けられます。
resource "google_service_account_iam_member" "terraform_sa" {
  service_account_id = data.google_service_account.terraform_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.mypool.name}/attribute.repository/${var.github_repository}"
}

