# memo-app
シンプルなメモアプリです。

# Requirement
- Ruby 3.0.0
- sinatra 2.1.0
- webrick 1.7.0

# Install
## アプリのダウンロード
リポジトリkaisumi/memo-appで［Code］ボタンからZipでダウンロードし、解凍
![image](https://user-images.githubusercontent.com/39044468/146695298-5e260bc9-8d5d-42a9-a5fb-5f09cd139d90.png)
## Rubyのインストール
このアプリの実行にはRuby 3.0.0以降が必要です。お使いの環境に応じて[公式サイト](https://www.ruby-lang.org/ja/)からインストールしてください。
## gemのインストール
コマンドラインを使用して、memo-app直下で以下を実行
```
bundle install
```

# Usage
## 起動方法
1. コマンドラインでmemo-appに移動し、以下を実行
```
./sinatra-up
```
2. ブラウザでlocalhost:4567にアクセス
![image](https://user-images.githubusercontent.com/39044468/146695456-1e9ee933-399c-4853-853f-ab4a1dfaa951.png)
## 使用方法
### メモの追加
1. トップで［追加］を選択
2. タイトルとメモを記入し、［保存］を選択
メモがmemo-app/sinatra-webapp/memos/に保存され、トップに表示されます。
### メモ内容の変更
1. トップで該当するメモのタイトルを選択
2. ［変更］をクリック
3. メモの内容を変更し、［変更］を選択
### メモの削除
1. トップで該当するメモのタイトルを選択
2. ［削除］を選択
memo-app/sinatra-webapp/memos/のメモが削除されます。
## 終了方法
1. ブラウザを閉じる
2. sinatraを起動していたシェルの画面でCtrl+cを押下
3. シェルを閉じる

# Author
- 木村　亜矢
- LANGUE Lab.
- ｋａｉｓｕｍｉ＠ｌａｎｇｕｅ－ｌａｂ．ｃｏｍ（半角に置き換えて使用してください）

# License
このアプリはフィヨルドブートキャンプのプラクティスとして開発されたアプリであり、該プラクティスの答案として審査する以外の複製・利用を禁じます。
