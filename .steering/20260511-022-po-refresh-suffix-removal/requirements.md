# Requirements: plugin-{log,notification,os} 翻訳 .po refresh

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260511-022 |
| 作成日 | 2026-05-11 |
| 起点 | steering 20260511-020 フォローアップ |

## 背景

steering 020 で `PluginLog.LogLevel` / `PluginNotification.Importance,Visibility` / `PluginOs.osType_` の suffix 付き API を `@unboxed` variant や `OsType` サブモジュールに置換した。同時に `sphinx-docs/user/plugin-{log,notification,os}.md` の英語ソースも更新したが、対応する `sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-{log,notification,os}.po` の msgid が stale なまま残っており、日本語サイトビルド時に新しい英語テキストへの翻訳がフォールバック表示される。

既存パターン `b57ad6c` "Refresh .po files after note refactor" と同様に、`make update-po` で .po を再生成し、新規・変更された msgid に対応する `msgstr` を日本語訳で埋める。

## ゴール

- `sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-{log,notification,os}.po` の msgid を最新 .md と同期させる
- 新規・変更された msgid すべてに日本語翻訳を付与する（`msgstr ""` で空のまま残さない）
- `make build-ja` がエラー・新規 fuzzy 警告なく完了する

## スコープ

### 含むもの

- `sphinx-docs/Makefile` の `update-po` ターゲットを実行（`uv run sphinx-build -b gettext` → `uv run sphinx-intl update -l ja`）
- 影響を受ける 3 ファイル: `plugin-log.po` / `plugin-notification.po` / `plugin-os.po`
- 変更された msgid に日本語翻訳を充当（fuzzy / untranslated を解消）
- `make build-ja` 検証

### 含まないもの

- 他 plugin (clipboard-manager / dialog / fs / http / shell) や user / dev / index 系の .po — steering 020 で変更してないため触らない
- 新規ページ追加
- 翻訳ガイドラインの整備

## 受け入れ基準

- `sphinx-intl stat` で plugin-{log,notification,os}.po に untranslated / fuzzy が残っていない（変更分について）
- `make build-ja` が成功
- 既存翻訳の意図しない上書きが無い（git diff レビュー）

## 非ゴール / 後続作業

- 他言語追加
- 翻訳メモリ TM の導入
