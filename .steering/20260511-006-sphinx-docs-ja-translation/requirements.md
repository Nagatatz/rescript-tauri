# Requirements: sphinx-docs `locale/ja/` 翻訳更新

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-006 |
| 種別 | ドキュメント追加（外部公開 sphinx-docs 翻訳） |
| 作成日 | 2026-05-11 |
| 関連 | steering 001 / 002 / 003 / 004 / 005 (新規 user guide 追加群) |

---

## 1. 背景

本日中に 5 つの新規ユーザーガイドが sphinx-docs に追加された:

- `sphinx-docs/user/plugin-shell.md`（steering 001）
- `sphinx-docs/user/plugin-notification.md`（steering 002）
- `sphinx-docs/user/plugin-log.md`（steering 003）
- `sphinx-docs/user/plugin-os.md`（steering 004）
- `sphinx-docs/user/plugin-clipboard-manager.md`（steering 005）

これらの各 steering で日本語 `.po` 生成は明示的に "後続 sub-steering" に分離されていた。

また `index.md` / `installation.md` も同じ steering 群で更新されているため、対応する `index.po` / `installation.po` も古い entry を含んでいる。

本ステアリングは sphinx-docs `make build-ja` のターゲットを再び `make html` と等価な品質まで戻すことを目的とする。

## 2. ゴール

1. 5 つの新規 user guide に対応する `.po` ファイルを `sphinx-docs/locale/ja/LC_MESSAGES/user/` に生成する。
   - `plugin-shell.po` / `plugin-notification.po` / `plugin-log.po` / `plugin-os.po` / `plugin-clipboard-manager.po`
2. 既存 `index.po` / `installation.po` の新規 entry を最新の `.md` ソースに合わせて更新する。
3. 各 `.po` の **見出し (H1 / H2 / H3) と短いラベル（テーブルヘッダ、Compatibility 表の Component 列、Public API 表の Symbol 列等）のみを日本語化** する。長文の散文・コードコメント・URL リンク本文は `msgstr ""` のまま残し、Sphinx の fallback で英語表示させる。
4. `make build-ja` が clean に通る（warning は許容、error は不可）ことを確認する。

## 3. 非ゴール

- 5 ページの全文翻訳は対象外（user の判断により、見出しのみ訳出）。長文は後続 sub-steering で人手翻訳を行う。
- 既存 `plugin-fs.po` / `plugin-dialog.po` の翻訳品質向上は対象外。
- 新規 user guide の英語版本体への修正は対象外。
- Sphinx tooling (`pyproject.toml`) / Makefile の変更は対象外。

## 4. 翻訳方針（見出しのみ訳の具体例）

各 `.po` は `make update-po` で生成された後、以下のルールで msgstr を埋める:

| msgid の種類 | 例 | 翻訳方針 |
|---|---|---|
| ページタイトル (H1) | `` `@rescript-tauri/plugin-shell` `` | そのまま（パッケージ名は識別子） |
| セクション見出し (H2 / H3) | `Install` / `Capabilities` / `Pitfalls` | 日本語に訳す（インストール / 権限設定 / 注意点） |
| テーブルヘッダ | `Function` / `Returns` / `Notes` / `Symbol` / `Purpose` | 日本語に訳す（関数 / 戻り値 / 備考 / シンボル / 用途） |
| 互換性表 Component 列 | `Upstream ...` / `Rust ...` / `OS` | 日本語に訳す |
| 短いラベル本文 | "Linux / macOS / Windows / iOS / Android" 等のリスト | そのまま（識別子） |
| 長文の散文・段落 | "ReScript bindings for the [Tauri 2.x ... plugin]..." | `msgstr ""` のまま |
| コードブロック | `pnpm add ...` / `rescript` コード | そのまま英語（コードは訳さない） |
| `{note}` ブロック本文 | "The Phase 2 implementation is feature-complete..." | `msgstr ""` のまま |

`plugin-fs.po` / `plugin-dialog.po` の既存翻訳は完訳に近いため、それらに合わせる必要はない（ステアリング決定）。

## 5. 受け入れ基準

- `sphinx-docs/locale/ja/LC_MESSAGES/user/` に 5 つの新規 `.po` が追加されている
- 既存 `index.po` / `installation.po` の `Generator` / `POT-Creation-Date` が新しくなり、新規 msgid が含まれている
- 各新規 `.po` の H1 / H2 / H3 / テーブルヘッダの msgstr が日本語で埋まっている
- 長文 msgid の msgstr は空 (`msgstr ""`) のまま
- `make -C sphinx-docs build-ja` が完了する（error なし）
- `.mo` ファイルは commit に含めない（`.gitignore` 済み or generated artifact）

## 6. リスク・補足

- **並列セッション**: 同日に複数の sphinx-docs steering が走っており、index.md / installation.md が継続的に変化している。マージ直前に最新 main を取り込んで `make update-po` を再走させる必要がある可能性。
- **disk pressure (93%)**: `make build-ja` は HTML / inv ファイルを生成するため数 MB 増える。`.venv` は既に展開済み (209M) で追加 install 不要。
- **`.mo` ファイル**: `.gitignore` を確認し、既存 `.mo` がトラッキングされている場合はそれに合わせる（既存 `changelog.mo` 等は tracked なので、新規 `.mo` も commit に含める方針が一貫している）。
- **Sphinx output format**: `make update-po` は `sphinx-intl update` を呼び、polib による .po フォーマットを生成する。生成された `.po` のフォーマッティングは `polib` のデフォルトに従う。
