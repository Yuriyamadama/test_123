# terraformのstate fileをGCPで管理する。※一人での作業の場合、localでも管理は可能
# そのファイルを格納するための場所を作成

resource "google_storage_bucket" "tfstate" {
  name          = "${var.project_id}-tfstate"
  location      = var.region
  storage_class = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}