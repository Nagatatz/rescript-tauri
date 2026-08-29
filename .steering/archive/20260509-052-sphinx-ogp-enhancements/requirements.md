# 要件定義: sphinx-docs OGP 設定の強化

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | `.steering/20260509-042-phase2-sphinx-docs/`, `.steering/20260509-050-sphinx-docs-ja-translation/` |

## 背景

`sphinxext-opengraph` は `.steering/20260509-042-phase2-sphinx-docs/` で導入済みだが、現状の設定は `ogp_site_url` / `ogp_site_name` / `ogp_type` の最小限のみ。
ja 翻訳サイトも `.steering/20260509-050-sphinx-docs-ja-translation/` で稼働しており、ソーシャル共有時に言語別 OGP メタを正しく出し分ける必要がある。

## 要求

ユーザー指示の優先順位 (4 → 3 → 2):

### R1. 多言語対応 (`og:locale` / `og:locale:alternate`)

- `make html` (英語ビルド) では `og:locale=en_US`, `og:locale:alternate=ja_JP` を出力
- `make build-ja` (日本語ビルド, `-D language=ja`) では `og:locale=ja_JP`, `og:locale:alternate=en_US` を出力
- ビルド時の `language` 設定に基づき動的に切り替わること

### R2. カスタムメタタグ (Twitter Card)

- 全ページに `<meta name="twitter:card" content="summary_large_image" />` を出力
- 将来 `twitter:site` 等を追加できる構造にしておく

### R3. description の自動抽出強化

- `ogp_description_length` を明示し、ソーシャル共有プレビューで充分な長さの抜粋を確保
- `ogp_enable_meta_description` を明示的に有効化

## 非目標

- OGP 画像 (`ogp_image`) の追加 — 別途検討 (steering 053+)
- Twitter `@site` ハンドルの設定 — プロジェクト Twitter アカウント未確定
- 多言語 OGP の i18n テンプレート上書き — Sphinx 標準の `language` 切替で十分

## 制約

- `sphinxext-opengraph 0.13.0` (uv.lock 確定済み) で動作すること
- 既存の `make build-all` (en + ja を 1 サイトに合成) フローを壊さないこと
- ruff lint / format / pytest がパスすること
- ステアリング規約 (`definition-of-done.md` / `testing.md`) に準拠すること
