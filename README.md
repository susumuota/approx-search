approx-search
=============

曖昧検索, approximate pattern matching を可能にする Emacs Lisp ラ
イブラリ.


## 概要

他人の書いたプログラムや, 遠い昔に自分で書いたプログラムをメンテ
している時, 難しい単語やスペルミスした単語がうまく検索できなくて
困ったことありませんか? そういう時に曖昧検索できると便利だと思っ
てこのライブラリを書きました.

以前 Levenshtein distance(*1) というアルゴリズムを使って曖昧検索
を実装したのですが, あまりにも遅すぎるため, いまいち使えませんで
した. 今回は正規表現ベースのアルゴリズムを使って高速に曖昧検索で
きるようにしました.

基本的なアイデアは, 入力された文字列から曖昧検索のための正規表現
を生成するというもので, Migemo(*2) を参考にしました. Migemo の場
合はローマ字入力から日本語の正規表現を生成しますが, このライブラ
リでは入力から曖昧検索の正規表現を生成します. 具体的にはこんな感
じです.

  (approx-generate-regexp "abcd")
  => "\\(bcd\\|acd\\|abd\\|abc\\|a.cd\\|ab.d\\|ab.cd\\)"

この生成された正規表現を `re-search-forward' に渡して曖昧検索を実
現しています. 入力された文字数を N 個とすると, だいたい 3N 個程度
のパターンを生成して, その OR パターンで正規表現検索します.

曖昧度(ambiguousness)を指定できるようにしました. 曖昧度を大きくす
ると再帰的にパターンを生成して, より曖昧な検索が可能となります.
デフォルトの曖昧度は 1 です. M-x approx-set-ambiguousness で曖昧
度を設定できます.

インクリメンタルサーチ(isearch)にも対応しています. Meadow でも動
作するように修正しました(*3).

Migemo を使った曖昧検索はできません. Migemo に対応することもでき
ますが, 作者がこのライブラリを使う場面は主にプログラムを編集する
時(つまり Migemo を off にしている時)なので, 今のところ Migemo で
利用できるようにする必要はあまり感じていません.


(*1) Levenshtein distance (edit distance, 編集距離) については以
     下を参照.
     http://www.merriampark.com/ld.htm

(*2) http://migemo.namazu.org/

(*3) http://www.bookshelf.jp/cgi-bin/goto.cgi?file=meadow&node=approx-search


## 設定方法

かなりテキトーなものですが, Makefile を付属しました. Makefile の
先頭部分を適当に編集した後,

  % make
  % make install

でインストールできます.

~/.emacs に

  (add-to-list 'load-path "~/elisp")
  (require 'approx-search)
  (if (boundp 'isearch-search-fun-function)
      (require 'approx-isearch)
    (require 'approx-old-isearch))
  (approx-isearch-set-enable)

と書きます.

Mmigemo と併用する場合, Migemo の設定の後に以下のように書くと,
M-x migemo-toggle-isearch-enable で Migemo を無効にした場合のみ
approx-isearch が有効にできます(逆に Migemo を有効にしたら
approx-isearch が無効になります).

  (add-to-list 'load-path "~/elisp")
  (require 'approx-search)
  (if (boundp 'isearch-search-fun-function)
      (require 'approx-isearch)
    (require 'approx-old-isearch))

  (if migemo-isearch-enable-p
      (approx-isearch-set-disable)
    (approx-isearch-set-enable))

  (defadvice migemo-toggle-isearch-enable (before approx-ad-migemo-toggle-isearch-enable activate)
    "migemo を使う時は approx-search を使わない."
    (if migemo-isearch-enable-p
        (approx-isearch-set-enable) ; NOT disable!!! before advice なので
      (approx-isearch-set-disable)))



## 使い方

[1] approx-search-{forward,backward}

  M-x approx-search-forward
    曖昧検索を使って STRING を point から前方検索して見つかった位置を返す.

  M-x approx-search-backward
    曖昧検索を使って STRING を point から後方検索して見つかった位置を返す.

    例:
      (approx-search-forward "approximately")
      (approx-search-backward "approximately")
        "aproximately", "appproximately", "apploximately" にもマッチする.

  M-x approx-set-ambiguousness
    曖昧度を設定する. この値を大きくすると許容できる曖昧度が増す.
    デフォルトは 1.


[2] isearch

  M-x approx-isearch-enable-p
    曖昧検索を使った isearch が有効か否かを返す.

  M-x approx-isearch-set-enable
    曖昧検索を使った isearch を有効にする.

  M-x approx-isearch-set-disable
    曖昧検索を使った isearch を無効にする.

  M-x approx-isearch-toggle-enable
    曖昧検索を使った isearch の有効/無効を切り換える.

  変数 approx-isearch-auto-p
    通常の search で見つからなかった場合のみ曖昧検索を行う.
    デフォルトは nil.
