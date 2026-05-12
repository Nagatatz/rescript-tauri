# Requirements: main ブランチ直 push 禁止

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260512-006-protect-main-branch |
| 作成日 | 2026-05-12 |
| ステータス | Draft |

## 1. 背景

現在の `main` ブランチは GitHub 上で無保護 (`gh api /repos/Nagatatz/rescript-tauri/branches/main/protection` が `404 Branch not protected` を返す) で、誤った `git push` でリリース履歴が破壊されるリスクがある。

`.claude/rules/steering-workflow.md` の現行手順は worktree でローカル merge → `git push origin main` という流れだが、ヒューマンエラーやスクリプト誤実行で worktree を経由しない commit が main に直接 push される事故を物理的に防ぎたい。

## 2. ゴール

- リポジトリ admin (= Nagatatz) を含めて `main` への直 push を **GitHub 側で物理的にブロック** する
- force push と branch deletion を禁止する
- 既存の worktree → merge → main 反映フローを **PR ベース** に置き換え、関連ルール文書を整合させる

## 3. Non-goals

- CI required status checks の必須化（後続作業で検討）
- ruleset への移行（legacy branch protection で十分）
- 他ブランチ（`worktree-*`）の保護
- multi-user 想定の review 必須化

## 4. 制約

- GitHub 個人アカウント (`Nagatatz`) 配下のリポジトリのため、`required_approving_review_count` を 1 以上にすると solo dev は self-merge できなくなる → **0 とする**
- `enforce_admins=true` でも `required_approving_review_count=0` なら author 自身による merge は可能
- 既存の `git merge worktree-foo --no-ff` → `git push origin main` 直接 push は protection 適用後に拒否される → ワークフロー doc 更新が必須

## 5. 受け入れ条件

- [ ] `gh api /repos/Nagatatz/rescript-tauri/branches/main/protection` が 200 を返し、以下を含むこと:
  - `enforce_admins.enabled == true`
  - `required_pull_request_reviews.required_approving_review_count == 0`
  - `allow_force_pushes.enabled == false`
  - `allow_deletions.enabled == false`
- [ ] `git push origin main` をローカル main から直接実行すると拒否される（手動検証）
- [ ] `.claude/rules/steering-workflow.md` の worktree マージ手順が PR ベースに更新されている
- [ ] `.claude/rules/git-conventions.md` のブランチ運用ルールに PR フローが反映されている
- [ ] `.claude/rules/definition-of-done.md` の Phase 4 / 5 が PR フローを前提とした記述になっている
- [ ] 上記ドキュメント更新自体が PR 経由で main にマージされている（dogfood 検証）
