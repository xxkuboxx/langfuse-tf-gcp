resource "google_storage_bucket" "langfuse_bucket" {
  name                        = "langfuse-bucket-${var.project_id}"
  location                    = var.region
  storage_class               = "STANDARD" # 必要に応じてストレージクラスを変更 (例: "NEARLINE", "COLDLINE")
  force_destroy               = false      # バケットを削除する際に、中のオブジェクトも強制的に削除するかどうか
  uniform_bucket_level_access = true       # 均一なバケットレベルのアクセスを有効にする (推奨)

}
