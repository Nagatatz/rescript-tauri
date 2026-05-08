# 要求定義: CONTRIBUTING.md と docs/development-guidelines.md の整備

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-003 |
| タイトル | contributing-and-dev-guidelines |
| 起票日 | 2026-05-08 |
| 起票者 | ユーザー指示 (前ステアリング 002 完了後の next task 選定) |
| 影響範囲 | ドキュメントのみ（コード未着手の bootstrap 段階）|

## 1. 背景

bootstrap (commit `7dbf6b1`) 以降、README / PRD / architecture から `CONTRIBUTING.md` および `docs/development-guidelines.md` への参照を散発的に追加してきたが、本体のファイルは未作成。

具体的な参照元（grep 結果）:

| 参照元 | 言及内容 |
|---|---|
| `README.md` §Visibility (line 7) | visibility 切替条件の 1 つに `CONTRIBUTING.md` 追加を含む |
| `README.md` §Development setup (line 123) | `docs/development-guidelines.md` を Phase 1 で追加と明記（**broken link 状態**）|
| `README.md` §Contributing (line 203) | `CONTRIBUTING.md` を Phase 1 リリース時に追加と明記 |
| `docs/product-requirements.md` §2.3 / §10.4 / §9 | ナガタペルソナの期待 / Phase 3 達成条件 / bus factor 対策として `CONTRIBUTING.md` |
| `docs/architecture.md` §9 リスク | bus factor 1 対策として `CONTRIBUTING.md / governance` |
| `docs/repository-structure.md` §4 / `.claude/rules/documentation.md` | `development-guidelines.md` がドキュメント表に記載済み |

これらの broken link / 未実体ファイルを解消し、visibility 切替条件の 1 つを満たす。

## 2. 動機

- **broken link の解消**: README から `docs/development-guidelines.md` へのリンクが現在 dead link。IDE 診断でも warning 化していた（前ステアリング 001/002 の経過で確認済み）。
- **visibility 切替条件の前進**: `README.md` Visibility ブロックで宣言した 4 条件のうち `CONTRIBUTING.md` 追加を Phase 1 リリース前に充足。
- **PRD / architecture との整合**: 複数箇所で参照されているのに本体不在の状態を解消し、ドキュメント網を完成に近づける。
- **後で着手する Phase 1 実装の基盤**: 開発フロー・ローカルセットアップ・コミット粒度などを参照可能な状態にしておくことで、`packages/core/` の実装着手時に判断材料が揃っている。

## 3. スコープ

### 3.1 対象 (in-scope)

| ファイル | 言語 | 配置 | 主読者 |
|---|---|---|---|
| `CONTRIBUTING.md` | 英語 | リポジトリルート（README と同階層、GitHub の標準位置）| 外部コントリビュータ（Phase 1 リリース後の実 PR 受付を見据えた将来形）|
| `docs/development-guidelines.md` | 日本語 | `docs/` 直下（既存 PRD / functional-design / architecture と同じ）| 内部メンテナ・Claude Code |
| `README.md` 軽微修正 | 英語 | 既存 | — |

### 3.2 対象外 (out-of-scope)

- `CODE_OF_CONDUCT.md` — Phase 1 リリース時に追加検討（CONTRIBUTING.md 内で「TBD」言及のみ）。
- `GOVERNANCE.md` — Phase 3 ロードマップ項目。CONTRIBUTING.md からは現時点で言及しない。
- `.github/ISSUE_TEMPLATE/*` の新規作成 — 既存テンプレートに依存し、改修は別ステアリング。
- `.github/PULL_REQUEST_TEMPLATE.md` の改修 — 既存テンプレートに依存。
- `.claude/rules/*` の改修 — 本ステアリングは新規 2 ファイル整備のみ。既存 rules はリンク参照される側。
- 既存日本語 docs / CLAUDE.md / `.claude/rules/*` の英訳 — 前回ユーザー指示（CLAUDE 系は日本語維持）に従う。

## 4. 設計上の派生決定（要承認）

### 4.1 既存 `.claude/rules/*` との重複扱い

`CONTRIBUTING.md` と `development-guidelines.md` は、内容が `.claude/rules/git-conventions.md` / `code-comments.md` / `testing.md` / `steering-workflow.md` 等と一部重複しうる。

| 案 | 内容 | 推奨 |
|---|---|---|
| A | 重複箇所は **概要のみ + `.claude/rules/*` への直接リンク** で済ます。SSoT は rules 側 | ✅ Recommended（SSoT を rules に集約、二重メンテを避ける）|
| B | CONTRIBUTING.md / development-guidelines.md に詳細を再掲して self-contained にする | — (二重メンテ負荷)|
| C | 一切のリンクを使わず、`.claude/rules/*` は完全に内部用、外部向けには別途同等内容を書く | — (rules 公開済みなので意義なし)|

### 4.2 CONTRIBUTING.md の Phase 1 前の立場

| 案 | 内容 | 推奨 |
|---|---|---|
| A | 「現状（Phase 1 前）は外部 PR 受付なし、Issue のみ歓迎」を冒頭で明示し、PR フローセクションは "future state" として記載 | ✅ Recommended（README §Contributing と整合、誤解を招かない）|
| B | Phase 1 前提で full PR フローを書き、Phase 1 リリースで disclaimer のみ削除 | — (今すぐ PR が来た場合に運用未定で混乱)|
| C | Phase 1 リリース時まで CONTRIBUTING.md を作らず保留 | — (visibility 切替条件未達のまま)|

### 4.3 development-guidelines.md の言語

| 案 | 内容 | 推奨 |
|---|---|---|
| A | 日本語（既存 docs/* と同じ。内部メンテナ向け）| ✅ Recommended（前回ユーザー指示「CLAUDE 系・既存 docs/ は日本語維持」と整合）|
| B | 英語（README と同じ。コントリビュータが docs/ を直接読みに来る場合を想定）| — |
| C | 英日併記 | — (sphinx-docs 以外で 2 箇国語維持はメンテナンス負荷大)|

## 5. 受け入れ条件

- [ ] `CONTRIBUTING.md` がリポジトリルートに存在し、英語で記述され、Phase 1 前後の立ち位置を明示している
- [ ] `docs/development-guidelines.md` が日本語で存在し、既存 `docs/*` のヘッダー・メタテーブル・序文パターンに揃っている
- [ ] README §Development setup の `docs/development-guidelines.md` リンクが有効化される（broken link 解消）
- [ ] README §Visibility の切替条件チェックリストが「CONTRIBUTING.md は追加済み」を反映する形に更新される（条件 4 つのうち残り 3 つ）
- [ ] CONTRIBUTING.md / development-guidelines.md とも `.claude/rules/*` への直接リンクで詳細委譲し、二重メンテを発生させない
- [ ] design.md §1 の派生決定 3 つ (4.1 / 4.2 / 4.3) が反映される
- [ ] 既存 `.github/ISSUE_TEMPLATE/` / `PULL_REQUEST_TEMPLATE.md` を変更しない（スコープ外）

## 6. 影響を受けないこと

- 既存 `.claude/rules/*` の内容と配置
- 既存 `docs/*` の内容（README リンクの有効化のための軽微調整は除く）
- CI ワークフロー
- リポジトリ構造（`docs/repository-structure.md` §4 で `development-guidelines.md` は既に表に記載済み、行追加不要）

## 7. リスク

| リスク | 影響度 | 対応 |
|---|---|---|
| `.claude/rules/*` と CONTRIBUTING.md の内容ドリフト | 中 | CONTRIBUTING.md は概要 + リンクに留め、SSoT は rules 側 |
| Phase 1 実装着手前にコントリビューションフローを固め過ぎ、後で再改訂が必要になる | 低 | "future state" / "TBD" マーカーで Phase 1 リリース時の改訂ポイントを明示 |
| 日本語 `development-guidelines.md` を読めない外部コントリビュータが現れる | 低 | CONTRIBUTING.md (英語) で開発概要をカバー、詳細は内部メンテナ向け前提で進める。外部受付開始は Phase 1 リリース後 |

## 8. 後続タスクへの引き継ぎ

本ステアリングが完了した段階で、未充足の visibility 切替条件は以下 3 つ:

1. `@rescript-tauri/core` の最初の npm publish
2. `examples/*` 各ワークスペースが 3 OS マトリクスでビルド成功
3. `docs/functional-design.md` §6 で定義された CI ワークフローの実体化

これらは Phase 1 実装着手の対象であり、別ステアリングで扱う。
