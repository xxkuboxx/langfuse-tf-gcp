## 前提条件
- Google CloudのProject作成
- gcloud CLIのインストール
- Terraformのインストール

## Terraformの準備
- locals.tfの書き換え
  ```
  mv locals.tf.example locals.tf
  vim locals.tf
  ```
  `<your-project-id>`を置換

## 事前に作成する必要のあるリソース作成
- Cloud SQL, Service Account, Cloud Storage, シークレット変数
  ```
  terraform apply -target module.cloud_sql -target module.service_account  -target module.storage -target module.secret_manager
  ```

## Cloud SQLのpassword設定
  ```
  gcloud sql users set-password postgres --host=% --instance=my-postgres-instance --prompt-for-password
  ```

## シークレット準備

### DATABASE_URL
- IPv4 ADDRESS 取得
  ```
  gcloud sql instances list
  ```
- シークレット作成
  ```
  echo -n postgresql://postgres:<password>@<ip-address>/mydb | gcloud secrets versions add DATABASE_URL --data-file=-
  ```
  `<password>`（Cloud SQLで設定したものと同じもの）と `<ip-address>`を置換
### NEXTAUTH_SECRET
```
printf "%s" "$(openssl rand -base64 32)" | gcloud secrets versions add NEXTAUTH_SECRET --data-file=-
```
### SALT
```
printf "%s" "$(openssl rand -base64 32)" | gcloud secrets versions add SALT --data-file=-
```
### ENCRYPTION_KEY
```
printf "%s" "$(openssl rand -hex 32)" | gcloud secrets versions add ENCRYPTION_KEY --data-file=-
```
### HMACキー（LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID, LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY）
- Service Accountの確認
  ```
  gcloud iam service-accounts list 
  ```
  `cloud-run-sa@<your-project-id>.iam.gserviceaccount.com`が作成されたSA
- HMACキーの確認
  ```
  gcloud storage hmac create cloud-run-sa@<your-project-id>.iam.gserviceaccount.com
  ```
- LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID
  ```
  echo -n <accessId> | gcloud secrets versions add LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID --data-file=-
  ```
- LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY
  ```
  echo -n <secret> | gcloud secrets versions add LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY --data-file=-
  ```

## Langfuseのデプロイ
```
terraform apply
```
