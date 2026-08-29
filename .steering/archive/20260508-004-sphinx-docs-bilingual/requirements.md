# 要求定義: sphinx-docs の英日 2 箇国語化（フル）

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-004 |
| タイトル | sphinx-docs-bilingual |
| 起票日 | 2026-05-08 |
| 起票者 | ユーザー指示 |
| 影響範囲 | `sphinx-docs/` 配下のみ。コードへの影響なし |

## 1. 背景

bootstrap 時点で `sphinx-docs/` には以下のフレームワークが配置済み:

- `pyproject.toml`: Sphinx 9.1, Furo theme, MyST, sphinx-intl, sphinxcontrib-budoux 等の依存
- `conf.py`: `language = "en"`, `locale_dirs = ["locale/"]`, `sitemap_locales = ["en", "ja"]`
- `Makefile`: `gettext` / `update-po` / `build-ja` / `build-all` ターゲット完備
- `locale/ja/LC_MESSAGES/`: ディレクトリ存在（`.gitkeep` のみ、`.po` 未生成）
- 12 個の `.md` ファイル (`index.md`, `user/*.md`, `dev/*.md`)

ただし以下が未整備:

- `conf.py` / `pyproject.toml` / 全 `.md` に placeholder (`{{PROJECT_NAME}}`, `{{AUTHOR}}`, `{{GITHUB_URL}}`, `{{PROJECT_NAME_SLUG}}`, `{{PROJECT_DESCRIPTION}}`) 残存
- 全 12 `.md` がテンプレートスタブ（`<!-- Add ... here -->` プレースホルダー多数）
- `html_baseurl = ""` TODO
- 日本語 `.po` ファイル未生成

ユーザー指示「フル (インフラ + コンテンツ充実 + 日本語翻訳)」に従い、本ステアリングで一括対応する。

## 2. 動機

- **`sphinx-docs/` の実体化**: フレームワークがあるのに動かない / 内容が空の状態を解消する。
- **README §Documentation index と整合**: README で「External-facing user/contributor docs will be developed in `sphinx-docs/` with English as the base language and Japanese translations provided through Sphinx i18n」と宣言した状態を実現する。
- **CI `docs.yml` の有効化**: 既に `.github/workflows/docs.yml` が `sphinx-docs/**` の変更で起動するよう設定済み（active workflow）。コンテンツが入れば実質的に CI が機能する。
- **Phase 1 リリース時の公開準備**: GitHub Pages (現状 `html_baseurl = ""` TODO) を Phase 1 リリース時に有効化するため、URL を含む完全な構成にしておく。
- **i18n 規約のドキュメント化**: 「英語ベース + Sphinx i18n で日本語提供」というポリシーを sphinx-docs 自身の `dev/setup.md` / `dev/building.md` で実証する。

## 3. スコープ

### 3.1 対象 (in-scope)

| カテゴリ | 対象 |
|---|---|
| placeholder 解消 | `sphinx-docs/conf.py` (5 箇所), `sphinx-docs/pyproject.toml` (2 箇所), 12 `.md` ファイル全体 |
| URL 設定 | `html_baseurl` を GitHub Pages URL に確定 |
| 英語コンテンツ整備 | 12 `.md` を rescript-tauri 固有の内容に書き換え（既存テンプレートスタブを破棄）|
| 日本語翻訳 | `make update-po` で 12 `.po` 生成 → 全 msgid を日本語訳 |
| ビルド検証 | `make build-all` で en + ja サイトが生成され、Pagefind 検索が動作 |
| 関連ドキュメント更新 | README §Documentation index に sphinx-docs 公開先を追記（必要時）|

### 3.2 対象外 (out-of-scope)

- GitHub Pages 公開設定（リポジトリ private のため Pages 非有効。Phase 1 リリース時に visibility 切替と同時に有効化）。
- `docs.yml` workflow の改修（active で動作中、サイトデプロイは Pages 有効化時に走る）。
- 既存 `docs/*` (PRD / functional-design / architecture / 等) の改修。`sphinx-docs/` から `docs/` への参照は「リポジトリ内の内部設計ドキュメント」として GitHub URL 経由でリンクする。
- コードへの一切の変更（`packages/`, `examples/` は未着手のため）。
- `.steering/` 内の他の作業ディレクトリへの言及。

## 4. 設計上の派生決定（要承認）

### 4.1 placeholder 値の確定

| placeholder | 確定値 | 根拠 |
|---|---|---|
| `{{PROJECT_NAME}}` | `rescript-tauri` | README タイトルと一致 |
| `{{PROJECT_NAME_SLUG}}` | `rescript-tauri` | npm スコープ・GitHub repo 名と一致 |
| `{{PROJECT_DESCRIPTION}}` | `Production-ready ReScript bindings for Tauri 2.x's official JS SDK (@tauri-apps/api).` | GitHub repo description と一致 |
| `{{AUTHOR}}` | `Nagatatz and rescript-tauri contributors` | LICENSE と一致 |
| `{{GITHUB_URL}}` | `https://github.com/Nagatatz/rescript-tauri` | 既存 repo |
| `html_baseurl` | `https://nagatatz.github.io/rescript-tauri/` | GitHub Pages デフォルトパス（`SPHINX_SITE_PREFIX` 環境変数で `/rescript-tauri` プレフィックスを動的挿入する仕組みは conf.py 既設）|

### 4.2 コンテンツ深度

| 案 | 内容 | 推奨 |
|---|---|---|
| A | 各 `.md` 50–150 行。要点 + 詳細は `docs/` や `CONTRIBUTING.md` にリンク委譲 | ✅ Recommended（SSoT は `docs/` 側に保ち sphinx-docs は外部公開用フォーマット）|
| B | 各 `.md` 200–400 行。`docs/` の内容を sphinx-docs に複製して self-contained 化 | — (二重メンテナンス負荷)|
| C | 各 `.md` 20–50 行のスケルトン + Phase 1 リリース時に充実予定の注記 | — (今回ユーザーが「フル」を選択したため不採用)|

### 4.3 翻訳トーン

| 案 | 内容 | 推奨 |
|---|---|---|
| A | です・ます調、技術用語は英語のまま（例: "Layer 1 (Raw)", "polymorphic variant"）、コードブロック内のコメント・文字列は翻訳しない | ✅ Recommended（既存 docs/* と同調、技術ドキュメント標準）|
| B | 全用語を日本語化（例: 「第 1 層」「多相バリアント」） | — (技術ドキュメントとしては読みづらい)|
| C | だ・である調 | — (フォーマルすぎる、ユーザーガイドに不適)|

### 4.4 quickstart / installation の API サンプル扱い

`sphinx-docs/user/quickstart.md` および `sphinx-docs/user/installation.md` は Phase 1 リリース後の手順に依存する。Phase 1 前の現時点で書く際の方針:

| 案 | 内容 | 推奨 |
|---|---|---|
| A | README と同じく「Phase 1 リリース後の予定 / target API」と注記しつつ、設計上の最終形を示す | ✅ Recommended（README と一貫性、設計 RFC + functional-design に基づく確定情報）|
| B | 空のまま「Phase 1 リリース時に追加予定」とだけ記載 | — (フル対応のメリットが消える)|

## 5. 受け入れ条件

- [ ] `conf.py` / `pyproject.toml` に `{{...}}` placeholder が残存していない
- [ ] 全 12 `.md` から placeholder と `<!-- Add ... -->` テンプレートコメントが消え、rescript-tauri 固有の内容に置き換わっている
- [ ] `html_baseurl = "https://nagatatz.github.io/rescript-tauri/"` が設定されている
- [ ] `make update-po` で 12 `.po` ファイルが `locale/ja/LC_MESSAGES/` 配下に生成されている
- [ ] 全 `.po` の msgid に対する msgstr が日本語で埋まっている（empty msgstr が残っていない、ただし copyright/license 行などの定型文は除く）
- [ ] `make build-all` が成功し、`_build/site/en/index.html` と `_build/site/ja/index.html` が生成される
- [ ] `make linkcheck` を走らせ broken link なし（外部 URL の一時的不達は許容、内部 link は必ず通る）
- [ ] `make lint` が pass する（ruff lint + format check）
- [ ] 4.1 / 4.2 / 4.3 / 4.4 の派生決定がすべて反映されている

## 6. 影響を受けないこと

- 既存 `docs/*` の内容
- ルート `README.md`, `CONTRIBUTING.md`, `LICENSE`
- `packages/`, `examples/`（未着手のため対象外）
- `.github/workflows/` 既存ファイル（追加・改修なし、`docs.yml` は既存設定のまま）
- `.claude/rules/*`

## 7. リスク

| リスク | 影響度 | 対応 |
|---|---|---|
| `make update-po` で生成された `.po` の msgid が大量で翻訳工数が読めない | 中 | design.md §3 で `.po` ファイル単位のサイズ感を見積もり、段階的にコミットする |
| `npx pagefind` が初回実行時に大きなパッケージをダウンロード | 低 | 既存 `docs.yml` workflow で過去に成功実績、ローカルでもエラー時はステアリング review で対応 |
| Phase 1 後に API 仕様が変わり、quickstart.md / installation.md / configuration.md に再改訂が必要 | 中 (既知) | 「target API、Phase 1 リリース後に詳細化」を明示し、変更検知できる体裁にする |
| GitHub Pages が repository private のうちは公開不可 | 低 (既知) | visibility 切替時に Pages を enable する手順を `.steering/` で別タスク化（本ステアリング外）|
| `git_last_updated_timezone = "Asia/Tokyo"` だが英語サイトの作成日表示にも影響 | 低 | 仕様通り、UTC+9 で統一（プロジェクトは Asia/Tokyo 拠点を想定）|

## 8. 後続タスクへの引き継ぎ

本ステアリング完了後の TODO（別ステアリングで対応）:

- GitHub Pages の有効化（visibility public 切替時、Phase 1 リリース時）
- `sphinx-docs/user/changelog.md` への Phase 1 リリースノート記載（リリース時）
- API 仕様変更があった場合の `quickstart.md` / `configuration.md` 改訂
