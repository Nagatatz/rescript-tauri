# タスクリスト: GitHub Repository Settings の整備

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` / `design.md` |
| 作成日 | 2026-05-08 |

## Phase 0: 事前承認

- [x] requirements.md レビュー・承認
- [x] design.md レビュー・承認（特に §1 の派生決定 4 つ + §3 の config.yml 修正方針）
- [x] tasklist.md レビュー・承認

## Phase 1: ステアリング配置

- [x] **commit 1**: ステアリング 3 ファイルを main に配置 → コミット `📝 Add steering for 20260508-008 (github-repo-settings)`

## Phase 2: GitHub repo settings 変更（Claude が `gh api` で実行、外部システム）

各操作の前後で「コマンド」と「検証結果（取得値）」を tasklist に記録（commit 3 で反映）:

- [x] §2.1 Topics 設定（7 値: bindings/desktop/ipc/monorepo/rescript/tauri/tauri-2）
- [x] §2.2 Homepage URL 設定（`https://nagatatz.github.io/rescript-tauri/`）
- [x] §2.3 Has Projects 無効化
- [ ] ⚠️ §2.4 Private vulnerability reporting 有効化 → **失敗 (HTTP 404)**。GitHub の制約「private vulnerability reporting can only be enabled for a public repository」のため、private 状態では API も Web UI も有効化不可。**public 化後（Phase 1 リリース時の visibility 切替後）に再対応** — Phase 5 引き継ぎへ移動済み
- [x] §2.5 Vulnerability alerts (Dependabot) 有効化（204 No Content 確認）
- [x] §2.6 Actions sha_pinning_required 有効化
- [x] §6.2 集約検証: `gh repo view --json` で `hasProjectsEnabled=false`, `homepageUrl=https://nagatatz.github.io/rescript-tauri/`, `repositoryTopics=[7 値]`, `visibility=PRIVATE` を確認

## Phase 3: コード変更（main 直接、worktree なし）

- [x] **commit 2**: `.github/ISSUE_TEMPLATE/config.yml` を design §3.2 に従い置換（`{{GITHUB_REPO}}` 解消、Discussions リンクを削除し RFC + GHSA リンクに置換）→ コミット `🔧 Resolve {{GITHUB_REPO}} placeholder in ISSUE_TEMPLATE/config.yml`

## Phase 4: マージ準備

- [x] **commit 3**: tasklist.md を全 `[x]` 化 + 適用結果（gh API レスポンスの要点）を本書末尾に記録 + GHSA を Phase 5 に移動 → コミット `📝 Mark steering 20260508-008 complete (record applied repo settings)`
- [ ] `git push origin main` で全コミットを反映

## Phase 5: ユーザー手動作業 / 後続タスク（Claude 実行不可・別ステアリング、引き継ぎメモ）

下記は本ステアリングの対象外。public 化後（Phase 1 リリース）または後続ステアリングで対応:

- [ ] **Private vulnerability reporting 有効化** ← 本 steering で gh API 試行したが HTTP 404、GitHub の制約「private vulnerability reporting can only be enabled for a public repository」により private 状態では有効化不可。**visibility public 化と同時に再対応**: `gh api -X PUT repos/Nagatatz/rescript-tauri/private-vulnerability-reporting` を再実行
- [ ] **Branch protection** 設定（visibility public 化後）— `design.md` §7.1 のコマンド例を参照
- [ ] **Repository Insights → Community Profile** で達成度確認（visibility 切替後）
- [ ] **Workflow SHA pinning 移行**: 既存 `.github/workflows/*` の `actions/*@vN` 参照を SHA に置換（本 steering で `sha_pinning_required: true` を立てたため、新規 workflow には強制が効くが既存は手動移行）
- [ ] **Discussions 有効化判断**: Phase 1 後に必要性を再評価（現状の `config.yml` は Discussions リンクを削除済み）

---

## 適用結果記録

### Before（2026-05-08、現状調査時点）

```
homepageUrl: ""
hasProjectsEnabled: true
repositoryTopics: null
private-vulnerability-reporting: 404 Not Found
vulnerability-alerts: 404 "Vulnerability alerts are disabled."
actions/permissions: { enabled: true, allowed_actions: "all", sha_pinning_required: false }
ISSUE_TEMPLATE/config.yml: contains {{GITHUB_REPO}} placeholder
```

### After（commit 2 完了時点 + gh API 適用後）

```
homepageUrl: "https://nagatatz.github.io/rescript-tauri/"            ✅
hasProjectsEnabled: false                                            ✅
repositoryTopics: ["bindings","desktop","ipc","monorepo",
                   "rescript","tauri","tauri-2"] (7 件)              ✅
private-vulnerability-reporting: 404 (private 制約のため未対応)       ⏳ Phase 5
vulnerability-alerts: HTTP 204 No Content (= enabled)                ✅
actions/permissions: { enabled: true, allowed_actions: "all",
                       sha_pinning_required: true }                  ✅
ISSUE_TEMPLATE/config.yml: placeholder 解消 + RFC/GHSA リンクに置換   ✅
```

5/6 の gh API 操作 + 1/1 のコード変更が成功。GHSA のみ private repo 制約で Phase 5 に移行。
