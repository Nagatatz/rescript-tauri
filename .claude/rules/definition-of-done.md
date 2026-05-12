# Definition of Done (完了定義)

作業の完了条件を一元管理する Single Source of Truth。各フェーズのチェック項目を順に満たすこと。

## Phase 1: 計画（コード着手前）

- [ ] ステアリング番号を採番した（→ `steering-workflow.md` ステアリング番号の採番）
- [ ] `EnterWorktree` で worktree を作成し、隔離された作業環境を用意した（→ `steering-workflow.md` git worktree 運用）
- [ ] worktree 内に `.steering/[YYYYMMDD]-[NNN]-[開発タイトル]/` ディレクトリを作成した
- [ ] `requirements.md` を作成し、ユーザーの承認を得た
- [ ] `design.md` を作成し、ユーザーの承認を得た
- [ ] `tasklist.md` を作成し、ユーザーの承認を得た
  - tasklist.md には実装タスクとセットでテスト作成タスクを含めること

**例外:** タイポ修正、1行の設定変更など明らかに軽微な修正はステアリングワークフローを省略してよい（ただし PR フロー自体は branch protection により省略不可）。

## Phase 2: 実装（コーディング中）

### コメント付与

変更・追加したコードに、コメント規約に従ったコメントが付与されていること（→ `code-comments.md`）。

- [ ] コメント規約で定義された必須コメントがすべて付与されている

### テスト

変更内容に対応するユニットテストが作成・更新されていること（→ `testing.md`）。

- [ ] テストがプロジェクトのテストディレクトリに配置されている
- [ ] テスト省略の場合は tasklist.md に理由を明記している

### tasklist.md リアルタイム更新

- [ ] タスクに着手したら、即座に `tasklist.md` の該当タスクを `[x]` に更新した
- [ ] 実装中に新たに必要なタスクが判明した場合は、`tasklist.md` に追記した

## Phase 3: コミット前（各コミット前）

### ビルド・テスト

- [ ] ビルドが成功する（`CLAUDE.md` のビルドコマンドを使用）
- [ ] テストが全件パスする（`CLAUDE.md` のテストコマンドを使用）

### 自己検証

- [ ] プロジェクトに型チェックツールがある場合、型エラーがないことを確認した
- [ ] プロジェクトにリンターがある場合、警告・エラーがないことを確認した

### コミット規約

- [ ] コミットメッセージが絵文字プレフィックス + 英語動詞で始まる形式に従っている（→ `git-conventions.md`）
- [ ] 1つのコミットに1つの論理的な変更のみ含まれている

### ドキュメント更新

変更内容に応じて、以下のドキュメントを**該当コードのコミットに含めて**更新すること（→ `documentation.md`）。

| ドキュメント | 更新タイミング |
|-------------|---------------|
| `CLAUDE.md` | プロジェクト構成・開発規約に影響する変更時 |
| `README.md` | セットアップ手順・機能概要に影響する変更時 |
| `docs/` | 設計・要件に影響する変更時 |
| `sphinx-docs/` | ユーザー向け機能説明に影響する変更時（存在する場合） |

- [ ] 上記ドキュメントの更新が必要か確認し、必要なら更新した

### ステアリングファイルの同梱

- [ ] `.steering/` ディレクトリ内ファイルを実装コードと同じコミットに含めた
- [ ] コミットタスクの場合は `tasklist.md` を `[x]` に更新してからコミットした

## Phase 4: PR 作成・マージ前（main マージ前）

- [ ] `tasklist.md` の全タスク（マージタスク自体を含む）が `[x]` になっている
- [ ] マージタスクの `[x]` 更新がマージ前の最終コミットに含まれている
- [ ] `AskUserQuestion` でユーザーに PR 作成・main へのマージ可否を確認した（→ `steering-workflow.md`）
- [ ] セキュリティ関連モジュールの変更がある場合、セキュリティレビューを実施した
- [ ] `git push origin <ブランチ名>` で worktree ブランチを push した
- [ ] `gh pr create --base main --head <ブランチ名>` で PR を作成した

## Phase 5: マージ後（PR self-merge 完了後）

- [ ] `gh pr merge <PR番号> --merge --delete-branch` で self-merge し remote branch を削除した
- [ ] CWD をメインリポジトリに移動した（worktree 削除の前に必須）
- [ ] `git pull origin main` でローカル main を最新化した
- [ ] worktree を削除した（`git worktree prune` または `git worktree remove`）
- [ ] ローカル worktree ブランチを削除した（`git branch -d`、remote は `--delete-branch` 済み）
- [ ] 反映手順を順守した（→ `steering-workflow.md` worktree から main への反映手順）
- [ ] クリーンアップ完了の検証を実施した:
  - `git worktree list` で main のみ表示される
  - `git branch --list 'worktree-*'` の出力が空である
  - `.claude/worktrees/` が空またはディレクトリが存在しない

## 禁止事項

- ステアリングファイルを作成せずにコード変更を行うこと
- ユーザーが「すぐに実装して」と言った場合でも、最低限 `requirements.md` と `tasklist.md` は作成すること
- 既存の `.steering/` ディレクトリのドキュメントを使い回すこと（新しい作業には必ず新しいディレクトリを作成する）
