# 設計: GitHub Repository Settings の整備

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` |
| 作成日 | 2026-05-08 |

## 1. 派生決定の確定（要承認）

requirements.md §5 に対し、本設計で以下を採用する:

| § | 採用 | 内容 |
|---|---|---|
| 5.1 Topics | **案 A** | `rescript / tauri / tauri-2 / bindings / desktop / ipc / monorepo` の 7 つ |
| 5.2 Has Projects | **案 A** | 無効化（false） |
| 5.3 Has Discussions | **案 A** | 現状維持（false）。`config.yml` を Issue ベースに置換 |
| 5.4 Branch protection | 別ステアリング | public 化後に対応 |
| 5.5 Actions sha_pinning_required | **案 A** | true 化（既存 workflow の SHA 移行は別ステアリング） |

## 2. 実行コマンド（Claude が `gh` で実行）

実行時は `gh auth status` で `Nagatatz` 認証 + `repo` scope を再確認してから順次実行する。

### 2.1 Topics

```bash
gh api -X PUT repos/Nagatatz/rescript-tauri/topics \
  -F 'names[]=rescript' \
  -F 'names[]=tauri' \
  -F 'names[]=tauri-2' \
  -F 'names[]=bindings' \
  -F 'names[]=desktop' \
  -F 'names[]=ipc' \
  -F 'names[]=monorepo'
```

検証: `gh repo view Nagatatz/rescript-tauri --json repositoryTopics` で 7 つの topic が返ること。

### 2.2 Homepage URL

```bash
gh api -X PATCH repos/Nagatatz/rescript-tauri \
  -f homepage='https://nagatatz.github.io/rescript-tauri/'
```

検証: `gh repo view Nagatatz/rescript-tauri --json homepageUrl` で URL が返ること。

### 2.3 Has Projects 無効化

```bash
gh api -X PATCH repos/Nagatatz/rescript-tauri \
  -F has_projects=false
```

検証: `gh repo view Nagatatz/rescript-tauri --json hasProjectsEnabled` が `false`。

### 2.4 Private vulnerability reporting 有効化

```bash
gh api -X PUT repos/Nagatatz/rescript-tauri/private-vulnerability-reporting
```

検証: `gh api repos/Nagatatz/rescript-tauri/private-vulnerability-reporting` で `{"enabled": true}` 等が返ること。

### 2.5 Vulnerability alerts (Dependabot) 有効化

```bash
gh api -X PUT repos/Nagatatz/rescript-tauri/vulnerability-alerts
```

検証: `gh api repos/Nagatatz/rescript-tauri/vulnerability-alerts` が **204 No Content**（有効化済みの signal）を返すこと。

### 2.6 Actions sha_pinning_required 有効化

```bash
# 既存の allowed_actions: "all" / enabled: true は維持し、sha_pinning_required のみ true に
gh api -X PUT repos/Nagatatz/rescript-tauri/actions/permissions \
  -F enabled=true \
  -f allowed_actions=all \
  -F sha_pinning_required=true
```

検証: `gh api repos/Nagatatz/rescript-tauri/actions/permissions` で `sha_pinning_required: true`。

## 3. コード変更: `.github/ISSUE_TEMPLATE/config.yml`

### 3.1 現状

```yaml
blank_issues_enabled: false
contact_links:
  - name: 質問・相談
    url: https://github.com/{{GITHUB_REPO}}/discussions
    about: 一般的な質問は Issue ではなく Discussions で
```

問題:
- `{{GITHUB_REPO}}` placeholder が解決されていない
- Discussions が無効（has_discussions: false）なので、リンク先が 404 になる

### 3.2 修正後

派生決定 5.3（Discussions 現状維持）を踏まえ、リンク先を Discussions ではなく既存の SECURITY.md ベース + 後段の README に倒す:

```yaml
blank_issues_enabled: false
contact_links:
  - name: 設計・RFC へのフィードバック
    url: https://github.com/Nagatatz/rescript-tauri/blob/main/docs/ideas/RFC-0001-core-api-design.md
    about: 設計 RFC や PRD への議論は当面 Issue ベースで受け付けます。Phase 1 後に Discussions 開設を検討します。
  - name: セキュリティ脆弱性の報告
    url: https://github.com/Nagatatz/rescript-tauri/security/advisories/new
    about: 公開 Issue ではなく GitHub Security Advisories で（SECURITY.md 参照）
```

`{{GITHUB_REPO}}` を `Nagatatz/rescript-tauri` に解消するだけでなく、Discussions リンクを削除して **現状機能している channel（GHSA + Issue）に誘導**するのが現実的。

## 4. コミット粒度

`git-conventions.md` の「1 コミット = 1 論理的変更」に従い:

| # | コミット | 内容 |
|---|---|---|
| 1 | 📝 Add steering for 20260508-008 (github-repo-settings) | ステアリング 3 ファイル配置 |
| 2 | 🔧 Resolve {{GITHUB_REPO}} placeholder in ISSUE_TEMPLATE/config.yml | コード変更（config.yml）|
| 3 | 📝 Mark steering 20260508-008 complete (record applied repo settings) | tasklist 全 [x] 化 + 適用結果記録 |

GitHub repo settings の変更自体（gh API 操作）は git commit には含まれない（外部システム変更）。tasklist と report で記録する。

## 5. worktree 運用

ドキュメントのみ + 1 ファイルの軽微なコード変更 + 外部 API 操作。worktree を**省略**し main 直接コミットで進める。steering 003 / 005 / 006 / 007 と同パターン。

## 6. テスト・検証戦略

### 6.1 各 gh API 操作の検証

各操作の直後に対応する read API（§2 の各項目末尾「検証」コマンド）で適用状態を確認。

### 6.2 集約検証

最後に `gh repo view --json` でまとめて差分を取り、tasklist に before / after を記録:

```bash
gh repo view Nagatatz/rescript-tauri --json \
  hasProjectsEnabled,homepageUrl,repositoryTopics,visibility,defaultBranchRef
```

### 6.3 markdown lint / yaml lint

`.github/ISSUE_TEMPLATE/config.yml` 修正後に YAML として valid であることを `gh api` 経由で間接確認（Issue 作成画面が壊れない）。

## 7. ユーザー手動作業（Claude 実行不可、tasklist Phase 5 に記録）

### 7.1 Branch protection

Free Plan + private の制約で API 不可。public 化後に別ステアリングで:

```bash
# public 化後の例
gh api -X PUT repos/Nagatatz/rescript-tauri/branches/main/protection \
  -F required_status_checks[strict]=true \
  -F enforce_admins=true \
  -F required_pull_request_reviews[required_approving_review_count]=1 \
  -F restrictions=null
```

### 7.2 Repository Insights → Community Profile 確認

GitHub Web UI で Settings → Insights → Community を開き、各項目の達成度を確認。LICENSE / README / CODE_OF_CONDUCT / CONTRIBUTING / Issue templates / PR template / Description が緑、SECURITY.md は private vulnerability reporting 有効化で緑になる想定。

## 8. リリース判定への影響

本ステアリング完了で `README.md` Visibility ブロックの 5 条件への直接影響はない（settings は条件リスト外）。ただし以下の状態が前進する:

| 項目 | 状態 |
|---|---|
| Settings 整備度 | bootstrap 直後 → 整備済み |
| Security 基本体制 | Dependabot alerts ON / GHSA ON |
| Discoverability | Topics + Homepage 設定済み（public 化即日効果） |
| Issue / PR template の placeholder | 解消 |
