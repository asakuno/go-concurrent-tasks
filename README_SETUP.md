# 環境構築手順

## 必要な環境
- Docker
- Docker Compose
- Make (オプション)

## セットアップ手順

### 1. リポジトリのクローン
```bash
git clone https://github.com/asakuno/go-concurrent-tasks.git
cd go-concurrent-tasks
git checkout develop
```

### 2. サービスの起動

#### Makeを使用する場合
```bash
# サービスをビルドして起動
make build
make up

# ログを確認
make logs
```

#### Docker Composeを直接使用する場合
```bash
# サービスをビルドして起動
docker-compose build
docker-compose up -d

# ログを確認
docker-compose logs -f
```

### 3. 動作確認

#### フロントエンド
ブラウザで http://localhost:5173 にアクセス
- Vue.jsアプリケーションが表示されることを確認
- 「Go Concurrent Tasks」のタイトルと課題一覧が表示される

#### バックエンド
ブラウザまたはcurlで以下を確認：

```bash
# ヘルスチェック
curl http://localhost:8080/health
# レスポンス例: {"status":"healthy","timestamp":"2025-06-15T..."}

# ルートエンドポイント
curl http://localhost:8080/
# 利用可能なエンドポイント一覧が表示される
```

## ディレクトリ構造
```
.
├── README.md           # 課題説明
├── README_SETUP.md     # この環境構築ガイド
├── docker-compose.yml  # Docker Compose設定
├── Makefile           # Make コマンド定義
├── backend/           # Go バックエンド
│   ├── Dockerfile
│   ├── go.mod
│   └── main.go        # エントリポイント
└── frontend/          # Vue.js フロントエンド
    ├── Dockerfile
    ├── package.json
    ├── vite.config.js
    ├── index.html
    └── src/
        ├── main.js
        ├── App.vue
        └── style.css
```

## 開発の進め方

### バックエンド開発
1. `backend/`ディレクトリで作業
2. ファイルを変更すると自動的に再起動される
3. 新しいパッケージを追加する場合：
   ```bash
   docker-compose exec backend go get <package-name>
   ```

### フロントエンド開発
1. `frontend/`ディレクトリで作業
2. Hot Module Replacement (HMR)により変更が即座に反映
3. 新しいパッケージを追加する場合：
   ```bash
   docker-compose exec frontend npm install <package-name>
   ```

## トラブルシューティング

### ポートが既に使用されている場合
```bash
# 使用中のポートを確認
lsof -i :8080  # バックエンド
lsof -i :5173  # フロントエンド

# docker-compose.ymlでポートを変更
```

### コンテナが起動しない場合
```bash
# ログを確認
docker-compose logs backend
docker-compose logs frontend

# クリーンアップして再起動
make clean
make build
make up
```

### 権限エラーが発生する場合
```bash
# Dockerグループに現在のユーザーを追加
sudo usermod -aG docker $USER
# ログアウト・ログインが必要
```

## 課題の実装

各課題の実装は以下のディレクトリ構造で行うことを推奨：

```
backend/
├── main.go
├── task1/         # 課題1: 並行ダウンローダー
│   ├── downloader.go
│   └── downloader_test.go
├── task2/         # 課題2: ワーカープール
│   ├── worker_pool.go
│   └── worker_pool_test.go
└── task3/         # 課題3: Webスクレイピング
    ├── crawler.go
    └── crawler_test.go
```

## その他のコマンド

```bash
# サービスの停止
make down

# コンテナに入って作業
make backend-shell
make frontend-shell

# テストの実行
make test

# コードフォーマット
make fmt
```