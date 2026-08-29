# Design: npm Trusted Publishing への移行

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-12 |
| 関連 | requirements.md |

## 1. `release.yml` の変更

### 1.1 削除する箇所

#### (a) `Determine publish mode` の env と分岐

**Before:**
```yaml
- name: Determine publish mode
  id: mode
  shell: bash
  env:
    NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
    DRY_RUN_INPUT: ${{ github.event.inputs.dry_run }}
  run: |
    set -euo pipefail
    if [ "${GITHUB_EVENT_NAME}" = "workflow_dispatch" ] && [ "${DRY_RUN_INPUT}" = "true" ]; then
      echo "::notice::workflow_dispatch with dry_run=true — skipping publish"
      echo "publish=false" >> "$GITHUB_OUTPUT"
    elif [ -z "${NPM_TOKEN}" ]; then
      echo "::warning::NPM_TOKEN secret not set — skipping publish; configure repo secret to enable"
      echo "publish=false" >> "$GITHUB_OUTPUT"
    else
      echo "publish=true" >> "$GITHUB_OUTPUT"
    fi
```

**After:**
```yaml
- name: Determine publish mode
  id: mode
  shell: bash
  env:
    DRY_RUN_INPUT: ${{ github.event.inputs.dry_run }}
  run: |
    set -euo pipefail
    if [ "${GITHUB_EVENT_NAME}" = "workflow_dispatch" ] && [ "${DRY_RUN_INPUT}" = "true" ]; then
      echo "::notice::workflow_dispatch with dry_run=true — skipping publish"
      echo "publish=false" >> "$GITHUB_OUTPUT"
    else
      echo "publish=true" >> "$GITHUB_OUTPUT"
    fi
```

理由: Trusted Publishing では token の有無で publish 可否を判定する意味がない。OIDC は GitHub Actions 実行時に必ず利用可能であり、npm 側の trusted publisher 設定で publish 権限が制御されるため、CI 側で skip ロジックを持つ必要がない。dry_run 入力のみで分岐する。

#### (b) `Publish target package` の env 削除

**Before:**
```yaml
- name: Publish target package
  if: steps.mode.outputs.publish == 'true'
  working-directory: ${{ steps.target.outputs.directory }}
  env:
    NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
  run: npm publish --provenance --access public
```

**After:**
```yaml
- name: Publish target package
  if: steps.mode.outputs.publish == 'true'
  working-directory: ${{ steps.target.outputs.directory }}
  run: npm publish --provenance --access public
```

理由: Trusted Publishing 経由では `NODE_AUTH_TOKEN` 不要。npm CLI が自動で OIDC token を npm registry に提示し、短命の publish token を取得する。

### 1.2 変更しない箇所

| 箇所 | 理由 |
|---|---|
| `permissions: id-token: write` | OIDC token 発行に必須。provenance でも使用済み |
| `permissions: contents: write` | `gh release create` に必要 |
| `actions/setup-node` の `registry-url: "https://registry.npmjs.org"` | npm publish 先指定として依然必要 |
| `--provenance --access public` | provenance は npm が Trusted Publishing で publish したことの証明として強く推奨 |
| `Determine target package` の tag prefix ロジック | 変更不要 |
| `gh release create` | 変更不要 |

## 2. リリースチェックリストの変更

### 2.1 Phase 1 チェックリスト (`.steering/20260509-029-phase1-release-followups/release-checklist.md`)

§2「リポジトリ visibility と secrets」を以下のように変更:

**Before:**
```markdown
## 2. リポジトリ visibility と secrets

- [ ] リポジトリを public 化（GitHub UI: Settings → General → Danger Zone → Change visibility）
- [ ] `NPM_TOKEN` を Repository secret として登録
  - npm の Account → Access Tokens → Generate new token → "Automation" タイプ
  - `gh secret set NPM_TOKEN` または GitHub UI → Settings → Secrets and variables → Actions → New repository secret
- [ ] `ANTHROPIC_API_KEY` は Phase 1 では不要（Claude Code Action は opt-in template のまま）
```

**After:**
```markdown
## 2. リポジトリ visibility と Trusted Publisher

- [ ] リポジトリを public 化（GitHub UI: Settings → General → Danger Zone → Change visibility）
- [ ] npm 側で `@rescript-tauri/core` の Trusted Publisher を設定
  - npm の package ページ → Settings → Publishing access → Trusted Publisher → "Add new"
  - 入力値:
    - Provider: **GitHub Actions**
    - Organization or user: `Nagatatz`
    - Repository: `rescript-tauri`
    - Workflow filename: `release.yml`
    - Environment: (空欄)
  - 公式手順: [Trusted Publishers (npm Docs)](https://docs.npmjs.com/trusted-publishers)
- [ ] `ANTHROPIC_API_KEY` は Phase 1 では不要（Claude Code Action は opt-in template のまま）

> **`NPM_TOKEN` は不要**: 本リポジトリは npm Trusted Publishing を採用しているため、Automation token を Repository secret として登録する必要はない。OIDC により短命トークンが自動発行される。
```

### 2.2 Phase 2 チェックリスト (`.steering/20260509-046-phase2-release-checklist/release-checklist.md`)

§0「前提条件」を以下のように変更:

**Before:**
```markdown
- [ ] `NPM_TOKEN` リポジトリシークレットが設定済み
  (Phase 1 release で対応済 — steering 029 §2)
```

**After:**
```markdown
- [ ] npm 側で各 Phase 2 パッケージの Trusted Publisher が設定済み
  (各パッケージごとに npm UI から登録: `@rescript-tauri/schema`, `@rescript-tauri/plugin-fs`, `@rescript-tauri/plugin-dialog`)
  - 入力値は Phase 1 と同じ (provider: GitHub Actions / repo: Nagatatz/rescript-tauri / workflow: release.yml)
  - 公式手順: [Trusted Publishers (npm Docs)](https://docs.npmjs.com/trusted-publishers)
```

§4「Dry-run」のフォールバック説明を整理（NPM_TOKEN の有無での publish skip という説明を、dry_run 入力でのみ skip する形に修正）。

## 3. 検証方法

### 3.1 構文検証

```bash
# yamllint がプロジェクトに無くても、actionlint で workflow を検証可能
# (ローカルに無ければインストールを促す)
which actionlint || echo "actionlint 未インストール — brew install actionlint で導入推奨"
actionlint .github/workflows/release.yml
```

### 3.2 dry-run 動作確認

GitHub UI → Actions → "release" → "Run workflow":
- Branch: `main`
- `dry_run`: `true`

実行後、以下が期待:

- `Determine target package` → core にフォールバック（既存挙動）
- `Determine publish mode` → `dry_run=true` のため publish=false
- `Publish target package` → skip
- `Create GitHub Release` → `startsWith(github.ref, 'refs/tags/')` が false なので skip

CI は green で完了するはず。

### 3.3 本番 publish 動作確認（実リリース時）

実際のリリース時:
1. npm 側で Trusted Publisher 設定済みを確認
2. tag push → release.yml が起動
3. `npm publish --provenance --access public` が成功すれば OIDC 統合が動作

トラブル時:
- npm UI で「This package does not have a trusted publisher configured」エラー → npm 側設定漏れ
- `OIDC token unavailable` エラー → `permissions: id-token: write` の確認

## 4. 並列化判断

並列化不要（変更ファイル少数）:
- `release.yml` (1 ファイル編集)
- 2 つのリリースチェックリスト編集
- 単一 commit で完結する規模

## 5. リスク・回避策

| リスク | 回避策 |
|---|---|
| Trusted Publisher 設定漏れで publish 失敗 | チェックリストに「設定済み確認」を必須化 |
| `workflow_dispatch` (dry_run=false) で意図せず publish される | dry_run 入力のデフォルトは `true` のまま維持 |
| dry_run 判定ロジック簡略化で既存挙動が壊れる | tag push trigger 時に dry_run input は undefined になり、`[ "${DRY_RUN_INPUT}" = "true" ]` が false になることを bash で確認 |
| npm 側で Trusted Publishing 未対応のパッケージがある場合 | npm のドキュメントで全パッケージ対応を確認（2025 以降は全パッケージ対応） |
| OIDC ベースの publish に問題があった場合のフォールバック | 一時的に `NPM_TOKEN` を再登録 + 旧ロジック復元（git revert で即座に戻せる） |
