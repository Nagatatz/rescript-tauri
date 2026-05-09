# Requirements: sphinx-docs Japanese translation

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260509-050 |
| タイトル | sphinx-docs 日本語翻訳の追加 |
| 作成日 | 2026-05-09 |
| 関連 | `sphinx-docs/`, steering 042 (sphinx-docs 初期構築) |

## 1. 背景

`sphinx-docs/` は Phase 2 で構築済みで、Sphinx + Furo + sphinx-intl により多言語化（en / ja）対応の枠組みは整っている（steering 042）。`locale/ja/LC_MESSAGES/` に `.po` ファイルは存在するが、

- 一部の `msgstr` が空のまま（未翻訳）。
- Phase 2 で追加された 3 ページ（`user/plugin-fs.md`, `user/plugin-dialog.md`, `user/schema.md`）に対応する `.po` がまだ生成されていない。

その結果 `make build-ja` で日本語サイトを生成しても多くの本文が英語のまま表示される。本作業ではこのギャップを埋め、`build-ja` で読める日本語ドキュメントを完成させる。

## 2. 目的 / Goals

- ルート `index.md` および `user/`・`dev/` 配下の全 `.md` 1423 行分のソースについて、対応する `locale/ja/LC_MESSAGES/**.po` を最新化し、空の `msgstr` を日本語訳で埋める。
- `make build-ja` が警告ゼロで成功し、生成された `_build/html_ja/` が日本語化された UI / 本文を含むことを確認する。
- `.mo` ファイルは Sphinx ビルド時に自動生成されるため、手動コミットは行わない（既存運用に準拠）。

## 3. 非目標 / Non-goals

- 英語ソースの修正（誤字含む）。本作業は翻訳のみ。誤字を見つけた場合は別ステアリングで対応する。
- `sphinx-docs/` 以外（`docs/`, `README.md`, `CLAUDE.md` 等）の翻訳。
- 日本語独自のスクリーンショット差し替え。図表は英語と共通。
- 検索インデックス（Pagefind）多言語化。当面は英語版のみ対象（既存仕様）。

## 4. スコープ対象ファイル

### 4.1 既存 `.po`（空 `msgstr` を埋める）

- `locale/ja/LC_MESSAGES/index.po`
- `locale/ja/LC_MESSAGES/user/index.po`
- `locale/ja/LC_MESSAGES/user/installation.po`
- `locale/ja/LC_MESSAGES/user/quickstart.po`
- `locale/ja/LC_MESSAGES/user/configuration.po`
- `locale/ja/LC_MESSAGES/user/changelog.po`
- `locale/ja/LC_MESSAGES/dev/index.po`
- `locale/ja/LC_MESSAGES/dev/setup.po`
- `locale/ja/LC_MESSAGES/dev/building.po`
- `locale/ja/LC_MESSAGES/dev/architecture.po`
- `locale/ja/LC_MESSAGES/dev/contributing.po`
- `locale/ja/LC_MESSAGES/dev/project-structure.po`

### 4.2 新規生成して翻訳する `.po`

- `locale/ja/LC_MESSAGES/user/plugin-fs.po`
- `locale/ja/LC_MESSAGES/user/plugin-dialog.po`
- `locale/ja/LC_MESSAGES/user/schema.po`

## 5. 完了条件 / Acceptance Criteria

- [ ] `make gettext && make update-po` が成功する。
- [ ] 4.1 / 4.2 の全 `.po` の `msgstr ""` 件数が 0（ヘッダ部の空 `msgstr` を除く）。
- [ ] `make build-ja` が警告 / エラーなく成功する。
- [ ] `_build/html_ja/index.html` を開いた際、トップページのナビ・本文が日本語になっていることを目視で確認する（少なくとも `index`・`user/quickstart`・`user/plugin-fs`）。
- [ ] tasklist 全項目が `[x]` になり、コミット粒度が `git-conventions.md` に準拠する。

## 6. 翻訳方針

- 用語は `docs/glossary.md` のユビキタス言語定義に整合させる（IPC / Layer 1〜3 / Channel / Command 等）。
- API 名・パッケージ名・コマンド名・コード片・URL は翻訳しない。
- 英語の見出しはそのままでなく自然な日本語に置換する（例: "Quick Start" → "クイックスタート"）。
- BudouX 拡張により h1〜h3 の自動改行が効くため、見出しは句読点による不自然な改行を避け、自然な文章にする。
- 翻訳調ではなく、既存の `docs/`（日本語）と同等の文体（敬体「です・ます」よりも文末を簡潔にする「である調」を基本とするが、ユーザーガイド側は「です・ます」を併用してよい）。

## 7. リスク / 留意事項

- `myst_parser` の MyST シンタックス（`:::{note}` 等）はメッセージとして抽出されない場合がある。`make build-ja` の出力で UNTRANSLATED 警告が出たら個別に対応する。
- `gettext_compact = False` 設定により 1 ソース 1 `.po` となるため、ソース markdown を改名・分割した場合、対応する `.po` も rename / split が必要（本作業ではソース変更なしのため発生しない想定）。
- 既存 `.mo` ファイルがソース管理されているが、今後はビルド時生成に統一する方針も検討の余地あり（→ 本作業の非目標）。
