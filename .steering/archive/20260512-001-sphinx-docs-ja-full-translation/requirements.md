# Requirements: sphinx-docs JA 完全翻訳

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-12 |
| 関連 | `.steering/20260509-050-sphinx-docs-ja-translation/`, `.steering/20260511-006-sphinx-docs-ja-translation/`, `.steering/20260511-022-po-refresh-suffix-removal/` |

## 1. 背景

`sphinx-docs/locale/ja/LC_MESSAGES/` 配下に **21 ファイル / 419 件の未翻訳 msgstr** が残存していることをユーザーから指摘された（2026-05-12 確認）。

原因の分類:

1. **新規ページの初回翻訳が未着手** — `plugin-http` / `plugin-shell` / `plugin-clipboard-manager` は英語版のみ追加され `.po` 生成後に翻訳本体が入っていない
2. **suffix-removal による msgid 変化** — steering 20260511-020 / 022 で `plugin-{log,notification,os}` の msgid が変化し、対応する msgstr が untranslated に戻った
3. **過去翻訳の取りこぼし** — `changelog` / `quickstart` / `dev/architecture` 等の継続的に追記されているページで翻訳が追いついていない

## 2. ゴール

`sphinx-docs/locale/ja/LC_MESSAGES/` 配下の **すべての .po ファイルで未翻訳 msgstr を 0 件** にする。

### 2.1 対象ファイル（21 件、419 entries）

| 優先 | ファイル | 未翻訳 / 全体 |
|---|---|---|
| 🔴 | `user/plugin-http.po` | 85 / 86 |
| 🔴 | `user/plugin-shell.po` | 73 / 97 |
| 🔴 | `user/plugin-clipboard-manager.po` | 51 / 68 |
| 🟠 | `user/changelog.po` | 34 / 45 |
| 🟠 | `user/plugin-log.po` | 25 / 96 |
| 🟠 | `user/plugin-notification.po` | 21 / 87 |
| 🟠 | `user/plugin-os.po` | 19 / 88 |
| 🟡 | `user/schema.po` | 16 / 50 |
| 🟡 | `user/plugin-fs.po` | 12 / 71 |
| 🟡 | `dev/architecture.po` | 11 / 40 |
| 🟡 | `user/quickstart.po` | 10 / 27 |
| 🟢 | `dev/building.po` | 9 / 72 |
| 🟢 | `user/configuration.po` | 9 / 77 |
| 🟢 | `user/index.po` | 9 / 70 |
| 🟢 | `user/plugin-dialog.po` | 9 / 60 |
| 🟢 | `dev/contributing.po` | 9 / 37 |
| 🟢 | `dev/index.po` | 5 / 11 |
| 🟢 | `user/installation.po` | 4 / 29 |
| 🟢 | `dev/setup.po` | 3 / 39 |
| 🟢 | `dev/project-structure.po` | 3 / 26 |
| 🟢 | `index.po` | 2 / 15 |

## 3. 非ゴール (Non-Goals)

- 既存翻訳 msgstr の品質改善（rewording / 用語統一）— 本作業は **空 msgstr の埋め込みのみ**
- `.mo` の手動再ビルド — Sphinx ビルド時に自動生成
- 新規日本語ページの追加 — 既存英語ページの翻訳のみ
- 英語版（msgid）の修正

## 4. 受け入れ条件

- 21 ファイルすべてで `msgstr ""` のエントリが 0 件になる（ヘッダ msgid `""` を除く）
- `pnpm --filter sphinx-docs build` または `cd sphinx-docs && make html` で日本語ビルドがエラーなく完走する（CI が green になる）
- 翻訳テキストはコードブロック / リンク URL / 変数プレースホルダ（`{0}` 等）を破壊していない

## 4.1 実態判明後の補足 (2026-05-12 追記)

T1–T3 完了後に `msgattrib --untranslated --no-obsolete` で精密検査したところ、当初 awk スクリプトが multi-line msgstr (`msgstr ""\n"..."` の連続行形式) を空文字列として誤検出していたことが判明。当初 419 件と見積もった未翻訳の大半は誤検出で、**実態は以下のとおり**:

- T1 (`plugin-http.po`): 真に 85/86 未翻訳 → 完了
- T2 (`plugin-shell.po`): 真に 73/97 未翻訳 → 完了
- T3 (`plugin-clipboard-manager.po`): 真に 51/68 未翻訳 → 完了
- 他 17 ファイル: すべて完全翻訳済み（awk 誤検出。msgattrib では 0 件）
- 残存問題: `user/index.po` の 1 件 untranslated + 3 件 fuzzy のみ → 別途修正

最終的な翻訳作業件数: 3 大規模ファイル + `user/index.po` の 4 修正 = 約 213 entries / 4 ファイル。

## 5. 制約

- 419 entries は長時間タスク。`steering-workflow.md` の Checkpoint 計画に従い、**ファイル単位でコミット** する（21 commit）
- 各 commit は `.po` 単体 + tasklist 更新の最小単位とし、中断時に最後の green commit から再開可能にする
- `git mv` は不要、ファイル名変更なし
- 翻訳トーンは既存翻訳済みエントリ（msgstr 入り）に合わせる（です・ます調、技術用語は英字併記）
