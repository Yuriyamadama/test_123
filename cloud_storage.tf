# test bucket

resource "google_storage_bucket" "test" {
  name          = "${var.project_id}-test"
  location      = var.region
  storage_class = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}