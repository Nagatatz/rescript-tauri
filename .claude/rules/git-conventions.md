# Git 規約

## コミットメッセージ

コミットメッセージには以下の絵文字プレフィックスを付与すること:

| 絵文字 | 用途 | 判定条件 |
|-------|------|---------|
| ✨ | 新機能追加 | 新しいファイル追加、または新しい関数/コンポーネントを追加 |
| 🐛 | バグ修正 | 条件分岐の修正、例外処理の追加、既存ロジックの修正 |
| ♻️ | リファクタリング | 関数の抽出・統合、名前変更、構造変更（機能変更なし） |
| 📝 | ドキュメント更新 | `.md` ファイルのみの変更、またはコメントのみの追加・修正 |
| 🎨 | UI やスタイルの改善 | スタイル変更、CSS/レイアウト関連の変更 |
| ⚡ | パフォーマンス改善 | クエリ最適化、キャッシュ追加、アルゴリズム改善 |
| 🔧 | 設定ファイルの変更 | ビルド設定、CI/CD 設定、設定ファイルの変更 |
| ✅ | テスト追加・修正 | テストファイルの追加・修正 |
| 🗑️ | 不要コード削除 | ファイル削除、不要コードの除去（コード量が純減） |

**判定優先順位**: 複数の絵文字が該当する場合、上の表の優先順位に従う（✨ が最優先）。

**フォーマット**: `<絵文字> <動詞で始まる簡潔な英語説明>`

**例**:
- `✨ Add user authentication endpoint`
- `🐛 Fix PDF parsing error for edge cases`
- `🔧 Configure CI pipeline for automated testing`

## コミット粒度

コミットは**最低でも機能単位**で分割すること。

**原則:**
- 1つのコミットには1つの論理的な変更のみを含める
- 機能の実装コード + 対応するテスト + 設定ファイル登録は同一コミットに含めてよい
- ドキュメント更新は、該当機能のコミットに含めるか、全機能実装後に1つのドキュメント更新コミットとしてまとめる
- tasklist.md の更新は各コミットに含めること
- 独立した機能はそれぞれ個別のコミットにすること

## ブランチ運用ルール

すべての変更は **`main` から新しいブランチを作成し、PR 経由でマージすること**。`main` への直 push は GitHub branch protection で**物理的にブロック**されており、例外なく PR フローを通る必要がある（steering 20260512-006 で適用）。

**手順:**
1. `main` ブランチから作業用ブランチを作成する（`EnterWorktree` 推奨、ブランチ命名規則に従う）
2. 作業用ブランチで実装・コミットを行う
3. 完了後、`tasklist.md` のマージタスクを含む全タスクを `[x]` に更新してコミットする
4. ユーザーに PR 作成・`main` へのマージ可否を確認する
5. 承認後、`git push origin <ブランチ名>` → `gh pr create` → `gh pr merge --merge --delete-branch` で self-merge し、worktree とローカルブランチを削除する（詳細は `steering-workflow.md` 「worktree から main への反映手順」参照）

**重要:** マージ前に `tasklist.md` の全タスク（マージタスク自体を含む）が `[x]` になっていることを確認すること。tasklist の更新はマージ前の最終コミットに含めること。

**branch protection の効果:**
- `git push origin main` は **403** で拒否される（admin を含む）
- `git push --force` は禁止
- `main` ブランチの削除は禁止
- すべての変更は PR レビュー必須（self-approve 可・required review count = 0）

軽微な変更（タイポ修正、設定 1 行、`.steering/` のみ、`CLAUDE.md` / `docs/` のみ）も PR を通ること。solo dev の場合は self-merge で即時反映できるため、PR 経由のオーバーヘッドは小さい。

## ブランチ命名規則

| プレフィックス | 用途 | 例 |
|--------------|------|-----|
| `feature/` | 新機能追加 | `feature/user-authentication` |
| `fix/` | バグ修正 | `fix/login-redirect-loop` |
| `refactor/` | リファクタリング | `refactor/repository-pattern` |
| `docs/` | ドキュメント更新 | `docs/update-architecture` |
| `test/` | テスト追加・修正 | `test/edge-cases` |
| `chore/` | 設定・依存関係等 | `chore/update-dependencies` |
