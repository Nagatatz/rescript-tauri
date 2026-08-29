# 設計: CONTRIBUTING.md と docs/development-guidelines.md

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` |
| 作成日 | 2026-05-08 |

## 1. 派生決定の確定（要承認）

requirements.md §4 に対し、本設計で以下を採用する:

| § | 採用 | 内容 |
|---|---|---|
| 4.1 重複扱い | **案 A** | 重複箇所は概要 + `.claude/rules/*` への直接リンク。SSoT は rules 側 |
| 4.2 CONTRIBUTING.md の Phase 1 前の立場 | **案 A** | 「Phase 1 前は Issue のみ受付、PR フローは future state として記載」 |
| 4.3 development-guidelines.md の言語 | **案 A** | 日本語（既存 docs/* と同じ）|

## 2. ファイル構成

### 2.1 `CONTRIBUTING.md`（英語、ルート）

#### 章立て

```
# Contributing to rescript-tauri

(1) Project status
   - Phase 1 design phase, repo currently private
   - External PRs not yet accepted; Issues welcome
   - Link to README "Visibility" block for the public-switch criteria

(2) How you can help today
   - Open Issues for design feedback / RFC discussion
   - Star/watch the repo for release announcements

(3) Future PR workflow (post-Phase 1)
   - Branch naming (link to .claude/rules/git-conventions.md §Branch)
   - Commit message style (emoji prefix; link to .claude/rules/git-conventions.md §Commit)
   - PR scope (one logical change per PR; link to .claude/rules/git-conventions.md §コミット粒度)
   - Steering workflow for medium+ changes (link to .claude/rules/steering-workflow.md)
   - Required tests (link to .claude/rules/testing.md)
   - Required doc comments (link to .claude/rules/code-comments.md)
   - CI gates summary (link to .github/workflows/README.md)
   - Definition of Done (link to .claude/rules/definition-of-done.md)

(4) Local development
   - Pointer to docs/development-guidelines.md (Japanese, internal-detailed)
   - Quick build/test commands (mirror README)

(5) Reporting bugs and feature requests
   - Use GitHub Issues with the existing templates under .github/ISSUE_TEMPLATE/
   - For security issues: pointer to SECURITY.md (TBD; for now contact maintainer email)

(6) Code of Conduct
   - TBD (planned for Phase 1 release)

(7) License
   - All contributions are under MIT (link to LICENSE)
```

#### 本文方針

- 1 ページ完結。各セクション 1〜3 段落程度。
- 詳細は `.claude/rules/*` および `docs/development-guidelines.md` に委譲し、CONTRIBUTING.md には**概要 + 該当ファイルへのリンク**を載せる。
- Phase 1 前の立ち位置を冒頭で明示（外部 PR 未受付）。
- "Future PR workflow" セクションは Phase 1 リリース時にそのまま正式版に昇格できる粒度で書く。
- Code of Conduct / SECURITY.md は TBD として明示（追加対応は別ステアリング）。

### 2.2 `docs/development-guidelines.md`（日本語、`docs/`）

#### ヘッダー

既存 `docs/*` のパターンに準拠:

```markdown
# 開発ガイドライン (Development Guidelines)

| 項目 | 内容 |
|---|---|
| プロダクト | `@rescript-tauri/core` および周辺パッケージ群 |
| 対象 | Phase 1 以降の全実装作業 |
| 作成日 | 2026-05-08 |
| 関連 | [docs/architecture.md](./architecture.md), [docs/functional-design.md](./functional-design.md), [docs/repository-structure.md](./repository-structure.md), [.claude/rules/](../.claude/rules/) |
| ステータス | Draft |

> 本書は「**どう開発するか**」の実務指針。コーディング規約や Git 規約自体は `.claude/rules/*` を SSoT とし、本書はそれらを開発者の動線に沿って組み立て直す。
```

#### 章立て（日本語）

```
1. 開発の全体フロー
   1.1 ステアリング起動 → worktree 隔離 → 実装 → コミット → マージ
   1.2 軽微な変更 vs 中規模以上の判断（→ .claude/rules/permission-modes.md, steering-workflow.md）
   1.3 Definition of Done の各フェーズ（→ .claude/rules/definition-of-done.md）

2. ローカル開発環境
   2.1 必要ツール（pnpm >= 9, ReScript >= 12.0.0, Node.js Active LTS, Rust + Cargo は examples 用）
   2.2 推奨 IDE（VS Code + rescript-vscode）
   2.3 リポジトリ初期化（pnpm install）
   2.4 環境変数（`.env.example` を `.env` にコピー）

3. ビルド・テスト・lint コマンド
   3.1 全 workspace ビルド（CLAUDE.md と同期）
   3.2 core パッケージのインクリメンタル
   3.3 型レベル + vitest テスト
   3.4 examples ビルド（個別実行手順）

4. テスト方針（3 段構え）
   4.1 型レベルテスト（コンパイル成功 = pass）
   4.2 ランタイムテスト（vitest + happy-dom + Mocks）
   4.3 examples ビルド（3 OS マトリクス）
   4.4 詳細は .claude/rules/testing.md / docs/functional-design.md §5 / §7

5. 新モジュール追加時の手順
   5.1 `packages/core/src/<Name>.res` と `<Name>.resi` の作成
   5.2 `.resi` doc comment の必須要素（→ code-comments.md, functional-design.md 各モジュール仕様）
       - モジュールサマリ（1〜3 文）
       - Tauri 公式 URL を `See:` 行で各 public シンボルに付与
       - パラメータ・戻り値の説明（パラメータ 2 つ以上で必須）
   5.3 `tests/<name>_*.res` で型レベルテスト追加
   5.4 必要なら `tests/runtime/<name>_test.mjs` で vitest 追加
   5.5 `Tauri.res` re-export の更新（functional-design.md §2.13 参照）
   5.6 `.github/workflows/doc-link-lint.yml` の grep 対象に含まれることを確認
   5.7 `examples/` で典型ユースケースを追加（必要時）

6. コーディング規約（実装パターン）
   6.1 `.resi` を必ず併設（`.res` と 1:1）
   6.2 polymorphic variant（`[#light | #dark]`）の活用方針
   6.3 opaque type + `@send` でクラス API を表現
   6.4 `%identity` キャストでクラス継承を表現（WebviewWindow → Window）
   6.5 `result<'a, e>` での失敗表現（`*Exn` 派生命名）
   6.6 詳細は .claude/rules/code-comments.md / docs/architecture.md §3, §5

7. コミット粒度・メッセージ
   7.1 1 コミット = 1 論理的変更（→ git-conventions.md §コミット粒度）
   7.2 絵文字プレフィックス + 英語動詞（→ git-conventions.md §コミットメッセージ）
   7.3 ステアリング tasklist の同期（各コミットに含める）

8. PR レビュー観点
   8.1 自動レビュー: code-reviewer agent / build-resolver / debugger
   8.2 セキュリティ関連変更: security-reviewer 必須（→ definition-of-done.md Phase 4）
   8.3 リリース前: definition-of-done.md Phase 4 全項目チェック
   8.4 doc-link-lint / examples-build / 3 OS の CI 全緑

9. リリース手順（Phase 1 以降の実装後に詳細化）
   9.1 release-manager agent で changelog 生成
   9.2 各パッケージ独立 semver
   9.3 .github/workflows/release.yml の tag push トリガ
   (本セクションは Phase 1 リリース直前に詳細化、現時点は概要のみ)

10. 参照
   - .claude/rules/*（規約 SSoT）
   - docs/functional-design.md（モジュール別 API 仕様）
   - docs/architecture.md（設計原則・横断ポリシー）
   - .github/workflows/README.md（CI ワークフロー一覧）
   - docs/repository-structure.md（ディレクトリ正本）
```

#### 本文方針

- ねらい: 既存メンテナ・Claude Code が実装作業に着手する際の手元参照。
- SSoT は `.claude/rules/*` および設計書側にあるため、本書は「**規約をどの順序で適用するか**」「**どこを見ればよいか**」のナビゲーション。
- 章 5（新モジュール追加時の手順）と章 8（PR レビュー観点）は実用度が高いので具体的に書く。
- 章 9（リリース手順）は Phase 1 実装後に詳細化する旨を明示し、現時点は概要のみ。

### 2.3 `README.md` の軽微修正

| 該当 | before の要旨 | after の要旨 |
|---|---|---|
| §Development setup 末尾 | `Detailed contributor guidance will be added to docs/development-guidelines.md during Phase 1.` | `For contributor-facing details (development flow, local setup, module-addition recipes), see docs/development-guidelines.md (Japanese).` |
| §Contributing | `... A CONTRIBUTING.md will be added at the Phase 1 release.` | `... See CONTRIBUTING.md for how to engage today (issues only) and the future PR workflow.` |
| §Visibility | `... and CONTRIBUTING.md is added.` | `... (CONTRIBUTING.md is already in place; see the Contributing section below).` （または条件箇条書きから当該項目を「✅ already in place」マーキング）|

最後の §Visibility 修正は「条件 1 つ充足」をユーザーが視覚的に把握できるよう、`LICENSE` の扱い（"already in place"）と同じ表記パターンに揃える。

## 3. コミット粒度

`git-conventions.md` の「1 コミット = 1 論理的変更」に従い分割:

| # | コミット | 内容 |
|---|---|---|
| 1 | 📝 Add steering for 20260508-003 (contributing-and-dev-guidelines) | `.steering/20260508-003-contributing-and-dev-guidelines/` 3 ファイル配置 |
| 2 | ✨ Add docs/development-guidelines.md (Japanese, internal-facing) | `docs/development-guidelines.md` 新規 |
| 3 | ✨ Add CONTRIBUTING.md (English, future-PR-aware) | `CONTRIBUTING.md` 新規 |
| 4 | 📝 Resolve broken link and update visibility checklist in README | `README.md` 軽微修正 |
| 5 | 📝 Mark steering 20260508-003 tasks complete | tasklist.md 全 [x] 化 |

各コミット末尾で対応する `tasklist.md` の項目を `[x]` 化する。コミット 5 はマージタスクのチェックも含む（worktree なしのため Phase 5 マージステップは不要、push のみ）。

## 4. worktree 運用

ドキュメントのみの新規追加 + 軽微修正のため、`.claude/rules/steering-workflow.md` の「git worktree 運用」規約（**「コード実装」**を対象）には該当せず、worktree を**省略する**。`git-conventions.md` の例外規定（「CLAUDE.md や `docs/` のみのドキュメント更新」）も併せて、main 直接コミットで進める。

> ただし `CONTRIBUTING.md` はルート直下で `docs/` 配下ではないため、厳密には git-conventions.md 例外規定の文言からは外れる。本ステアリングでは「ドキュメントのみの追加で衝突リスクが極めて低い」と判断し、main 直接で進める。今後この種のルート直下ドキュメント（`SECURITY.md`, `CODE_OF_CONDUCT.md` 等）が増える場合は `.claude/rules/git-conventions.md` の例外規定文言を「ルート直下の `*.md` ドキュメント」を含む形に拡張するか、判断を別ステアリングで再検討する。

## 5. テスト戦略

ドキュメントのみの変更のためユニットテストは不要。検証は以下:

1. **broken link の解消確認**: `README.md` から `docs/development-guidelines.md` および `CONTRIBUTING.md` へのリンクが有効
2. **`.claude/rules/*` への参照リンクが正しく解決**: 各 rule ファイルが実在することを ls で確認
3. **既存パターンの踏襲**: `docs/development-guidelines.md` のヘッダーが他の `docs/*` と整合
4. **markdown lint**: IDE 診断で新規 warning なし

## 6. リリース判定への影響

本ステアリング完了で `README.md` Visibility ブロックの 4 条件のうち 1 つを充足:

- [ ] 最初の `@rescript-tauri/core` npm publish
- [ ] `examples/*` 全ワークスペースが 3 OS でビルド
- [ ] `docs/functional-design.md` §6 の CI ワークフローを実体化
- [x] **`CONTRIBUTING.md` を追加** ← 本ステアリングで充足
- [x] `LICENSE` (MIT) ← 既達

残 3 条件は別ステアリング（Phase 1 実装着手系）で扱う。
