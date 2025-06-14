package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "Go並行処理課題 - バックエンド環境構築完了")
	})

	fmt.Println("サーバーがポート8080で開始されました")
	http.ListenAndServe(":8080", nil)
}