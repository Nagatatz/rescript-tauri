# Design: main ブランチ直 push 禁止

## 1. 全体方針

GitHub legacy branch protection API (`PUT /repos/{owner}/{repo}/branches/{branch}/protection`) を `gh api` 経由で適用する。Rulesets ではなく legacy を選択する理由:

- 単一ブランチ (`main`) のみが対象で複雑な条件は不要
- 設定が JSON 1 ドキュメントで完結し、可逆 (`gh api -X DELETE ...`) が容易
- `gh api` で完全にスクリプタブル

## 2. Branch protection ペイロード

```json
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0,
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_linear_history": false,
  "required_conversation_resolution": false,
  "lock_branch": false,
  "allow_fork_syncing": false
}
```

### 各キーの根拠

| キー | 値 | 根拠 |
|---|---|---|
| `enforce_admins` | `true` | admin (= Nagatatz) も含めて直 push を物理ブロック。これが本作業のコア |
| `required_pull_request_reviews.required_approving_review_count` | `0` | solo dev が self-merge できるよう承認数 0。PR の存在自体は強制 |
| `dismiss_stale_reviews` | `false` | review が 0 必須なので無関係。明示的に false |
| `require_code_owner_reviews` | `false` | CODEOWNERS 未設定。将来追加時に再考 |
| `require_last_push_approval` | `false` | 同上 |
| `restrictions` | `null` | push 可能ユーザー制限は PR 経由前提なので不要 |
| `allow_force_pushes` | `false` | リリースタグ整合性のため必須ブロック |
| `allow_deletions` | `false` | main 削除事故防止のため必須ブロック |
| `required_linear_history` | `false` | 既存の `--no-ff` merge commit スタイルを維持 |
| `required_conversation_resolution` | `false` | solo dev では PR コメント解決を強制しても意味が薄い |
| `lock_branch` | `false` | lock すると read-only 化するので不可 |
| `allow_fork_syncing` | `false` | fork からの sync は本リポジトリでは未使用 |
| `required_status_checks` | `null` | 現状 GitHub Actions 名が安定していないため null。後続作業で `tests-*` を required にする検討 |

## 3. 適用後のワークフロー変更

### 3.1 旧フロー（protection 適用前）

```bash
# worktree で実装後
cd /path/to/main-repo
git merge worktree-feature --no-ff -m "Merge branch 'worktree-feature'"
git push origin main
git worktree remove .claude/worktrees/feature
git branch -d worktree-feature
```

### 3.2 新フロー（protection 適用後）

```bash
# worktree で実装後
cd /path/to/main-repo
git push origin worktree-feature
gh pr create --base main --head worktree-feature --title "..." --body "..."
gh pr merge worktree-feature --merge --delete-branch  # merge commit を作って remote branch 削除
git pull origin main  # ローカル main を最新化
git worktree remove .claude/worktrees/feature  # ローカル worktree 後片付け
# remote branch は --delete-branch で削除済み、ローカルブランチは git fetch で消える
```

`--merge` を選ぶ理由: 既存 history が `--no-ff` merge commit 主体のため整合を取る。`--squash` / `--rebase` は採用しない。

## 4. ドキュメント更新範囲

| ファイル | 更新内容 |
|---|---|
| `.claude/rules/steering-workflow.md` | 「worktree マージ・クリーンアップ手順」を PR ベースに書き換え。CWD 安全原則は維持 |
| `.claude/rules/git-conventions.md` | 「ブランチ運用ルール」の手順 3〜5 を PR フローに更新。例外条項（.steering/, docs/ のみの直接コミット）は **削除**（branch protection で物理的に不可能になるため） |
| `.claude/rules/definition-of-done.md` | Phase 4 のマージ前チェック項目、Phase 5 のマージ後チェック項目を PR フローに合わせる |

例外条項削除の影響: 今後 `.steering/` ファイルや `docs/` 更新も含めてすべて PR 経由になる。solo dev では PR 作成 → 即 self-merge で運用負荷は小さい。

## 5. dogfood 戦略

本作業自体を新フローで完了させる:

1. 本 steering の `requirements.md` / `design.md` / `tasklist.md` までは branch protection **適用前** に main へ直接コミット（既存の例外条項に従う）
2. branch protection を適用
3. worktree `worktree-protect-main-branch` を作成
4. その worktree で rule docs を更新
5. `git push origin worktree-protect-main-branch` → `gh pr create` → `gh pr merge --merge --delete-branch`
6. ローカルの worktree / branch をクリーンアップ
7. 旧フロー時代の「直接 push 例外」は新ルールに合わせて削除済みのため、以後のすべての変更が PR 経由になる

## 6. ロールバック計画

問題が発生した場合:

```bash
gh api -X DELETE /repos/Nagatatz/rescript-tauri/branches/main/protection
```

これで protection が即時解除される。doc 変更は git revert で戻す。
