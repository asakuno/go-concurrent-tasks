# 課題1: 並行ダウンローダー（初級）
## 機能要件

### コマンドライン引数

URLリストファイルのパス（1行1URL）
出力ディレクトリのパス
同時ダウンロード数（デフォルト: 3）


### ダウンロード機能

HTTP/HTTPSに対応
ファイル名は元のURLから生成（例: https://example.com/image.jpg → example_com_image.jpg）
既存ファイルはスキップ


### 進捗表示

各ファイルのダウンロード開始・完了・エラーをリアルタイム表示
全体の進捗（例: [5/10] Downloading...）
ダウンロードサイズの表示


### エラーハンドリング

タイムアウト（30秒）
リトライ機能（最大3回）
エラーログをファイルに記録



## 入出力仕様
bash# 実行例
go run downloader.go -urls urls.txt -out ./downloads -concurrent 5

### urls.txt の内容
https://golang.org/doc/gopher/frontpage.png
https://go.dev/images/go_google_case_study_carousel.png
https://raw.githubusercontent.com/golang-samples/gopher-vector/master/gopher.png

### 出力例
[1/3] Starting download: https://golang.org/doc/gopher/frontpage.png
[1/3] Downloaded: frontpage.png (125.3 KB)
[2/3] Starting download: https://go.dev/images/go_google_case_study_carousel.png
[2/3] Error: connection timeout (will retry 1/3)
[2/3] Downloaded: go_google_case_study_carousel.png (89.7 KB)
[3/3] Starting download: https://raw.githubusercontent.com/...
[3/3] Downloaded: gopher.png (215.4 KB)

Summary:
- Total files: 3
- Successful: 3
- Failed: 0
- Total size: 430.4 KB
- Duration: 2.34s
## テストケース

正常系：10個のURLを5並列でダウンロード
異常系：存在しないURL、タイムアウト、大きなファイル（100MB以上）
境界値：空のURLリスト、同時接続数0または負の値


# 課題2: ワーカープールパターン（中級）
## 機能要件

### タスク定義
gotype Task struct {
    ID     int
    Type   string // "prime", "factorial", "fibonacci"
    Input  int
    Result interface{}
    Error  error
}

### ワーカープール

ワーカー数は起動時に指定（デフォルト: CPUコア数）
ジョブキューのサイズ指定可能（デフォルト: ワーカー数×2）
グレースフルシャットダウン対応


### タスクタイプ

素数判定：与えられた数が素数かどうか
階乗計算：n!を計算（大きな数はbig.Intを使用）
フィボナッチ数：n番目のフィボナッチ数を計算


### モニタリング

処理速度（タスク/秒）
各ワーカーの稼働率
キューの待機タスク数
エラー率



## 入出力仕様
go// メイン関数の使用例
func main() {
    pool := NewWorkerPool(5, 100) // 5ワーカー、キューサイズ100
    pool.Start()
    
    // タスクの投入
    tasks := generateTasks(1000) // 1000個のランダムタスク生成
    results := make(chan Task, 1000)
    
    for _, task := range tasks {
        pool.Submit(task)
    }
    
    // 結果の収集
    pool.GetResults(results)
    
    // 統計情報の表示
    stats := pool.GetStats()
    fmt.Printf("Processed: %d tasks\n", stats.Processed)
    fmt.Printf("Errors: %d\n", stats.Errors)
    fmt.Printf("Average time per task: %v\n", stats.AvgProcessingTime)
    
    pool.Shutdown()
}
## パフォーマンス要件

1000タスクを10秒以内に処理
メモリ使用量は100MB以下
CPU使用率は利用可能なコア数に応じて効率的に分散

## テストケース

負荷テスト：10000タスクを投入
エラー処理：意図的にパニックを起こすタスク
動的ワーカー数調整（ボーナス機能）


# 課題3: Webスクレイピングツール（上級）
## 機能要件

### クローリング設定
gotype Config struct {
    StartURL        string
    MaxDepth        int           // 再帰の深さ制限
    MaxPages        int           // 最大ページ数
    ConcurrentLimit int           // 同時接続数
    RequestDelay    time.Duration // リクエスト間隔
    AllowedDomains  []string      // クロール対象ドメイン
    ExcludePatterns []string      // 除外URLパターン（正規表現）
}

### 収集データ
gotype PageInfo struct {
    URL         string
    Title       string
    StatusCode  int
    Links       []string
    Images      []string
    LoadTime    time.Duration
    ContentSize int64
    Depth       int
    Error       string
}

### 高度な機能

robots.txt の尊重
User-Agentの設定
クッキー/セッション管理
JavaScriptレンダリング（オプション）
進捗の永続化（中断・再開機能）


## 出力形式

JSON形式での保存
サイトマップ生成（XML）
統計レポート（HTML）
リアルタイムダッシュボード（ターミナルUI）



## 実装例の構造
go// 主要なインターフェース
type Crawler interface {
    Start(ctx context.Context) error
    Stop() error
    GetStats() Statistics
}

type URLFrontier interface {
    Add(url string, depth int) error
    Get() (string, int, bool)
    Size() int
}

type RateLimiter interface {
    Wait(ctx context.Context, domain string) error
}

// 使用例
crawler := NewCrawler(config)
ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
defer cancel()

// 進捗表示用のゴルーチン
go func() {
    ticker := time.NewTicker(1 * time.Second)
    for range ticker.C {
        stats := crawler.GetStats()
        fmt.Printf("\rProcessed: %d, Queue: %d, Errors: %d", 
            stats.Processed, stats.Queued, stats.Errors)
    }
}()

if err := crawler.Start(ctx); err != nil {
    log.Fatal(err)
}
## エラーハンドリング要件

ネットワークエラー：3回リトライ、指数バックオフ
パースエラー：ログに記録して継続
メモリ不足：URLキューのサイズ制限
無限ループ検出：同一URLの重複チェック

## パフォーマンス目標

1000ページ/分の処理速度
メモリ使用量：1GBページあたり1MB以下
応答時間：95パーセンタイルで5秒以内

## テストサイト
go// ローカルテストサーバーの実装も含める
func StartTestServer() *httptest.Server {
    // テスト用のWebサイトを生成
    // - 深い階層構造
    // - 循環リンク
    // - 大きなページ
    // - 遅いレスポンス
    // - エラーページ
}
### 評価基準

正確性：すべてのリンクを漏れなく収集
効率性：並行処理の効果的な活用
安定性：長時間動作、エラー耐性
拡張性：新しい機能の追加が容易
可読性：コードの構造化、ドキュメント

各課題には段階的な実装アプローチがあります：

Step 1: 基本機能の実装
Step 2: エラーハンドリングの追加
Step 3: パフォーマンス最適化
Step 4: 追加機能の実装
