# Requirements — sphinx-docs top page plugin widget

| 項目 | 内容 |
|---|---|
| Steering ID | 20260513-001 |
| 作成日 | 2026-05-13 |
| 種別 | ドキュメント拡張 (sphinx-docs + ja .po) |

## 1. Background

`sphinx-docs/index.md` (ドキュメントサイトのトップページ) には現在、`User Guide` と `Developer Guide` の 2 枚の grid card と、Installation / Quick Start / Configuration / Changelog の Quick Links しか存在しない。一方、リポジトリには 9 個の add-on package (`@rescript-tauri/plugin-*` および `@rescript-tauri/schema`) が公開対象として揃っており、`sphinx-docs/user/index.md` には完全な一覧テーブルが存在する。

結果として、初訪ユーザーがトップに着地した時に「どんな plugin が使えるか」を即座に把握できず、User Guide を一段降りて初めて plugin 一覧に到達する。

## 2. Goals

- トップページ (`sphinx-docs/index.md`) から、現在公開対象の 9 個の add-on package すべてに 1 クリックで到達できるようにする。
- 表示は **grid widget** (Sphinx `sphinx-design` の `grid-item-card`) で行い、既存の User Guide / Developer Guide カードと視覚的にトーンを合わせる。
- 日本語版 (`sphinx-docs/locale/ja/`) も同一 PR で同期する (documentation.md 規約)。

## 3. Non-goals

- `README.md` のトップへの plugin 一覧追加は対象外 (別 steering とする)。
- plugin 個別ページ (`plugin-*.md`) の本文修正は対象外。
- `sphinx-docs/user/index.md` の plugin table の再構成は対象外 (同期する場合のみ最小変更)。

## 4. Functional requirements

- F1. トップページに「Plugins & add-ons」のような見出しと共に 9 枚の grid card を表示する。
- F2. 各カードは package 名・1 行要旨・該当 user ガイドへのリンクを持つ。
- F3. 既存の `User Guide` / `Developer Guide` カード、Quick Links、`:hidden:` toctree はそのまま維持する。
- F4. `sphinx-docs/locale/ja/LC_MESSAGES/index.po` に新規 msgid を反映し、fuzzy / untranslated を残さない。

## 5. Acceptance criteria

- A1. `cd sphinx-docs && make html` が warning 0 で成功する。
- A2. `cd sphinx-docs && make -e SPHINXOPTS="-D language=ja" html` が warning 0 で成功する。
- A3. ビルド出力 `_build/html/index.html` に 9 plugin 全パッケージ名と該当リンク (`user/plugin-fs.html` 等) が含まれる。
- A4. `sphinx-docs/locale/ja/LC_MESSAGES/index.po` に `#, fuzzy` マーカーおよび空 msgstr が残らない。
- A5. PR は self-merge され、worktree / `worktree-*` ブランチ / `.claude/worktrees/sphinx-docs-top-plugin-widget` が削除されている。

## 6. Out of scope risks

- sphinx-design の grid 列数を増やすとモバイル表示が崩れる可能性 → design.md で 1/2/3 列のレスポンシブ指定を決める。
- ja `.po` の翻訳語彙が既存ページと食い違うリスク → 既存 `user/index.po` の訳語を参照して統一する。
