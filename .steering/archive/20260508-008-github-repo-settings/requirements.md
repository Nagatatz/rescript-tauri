# 要求定義: GitHub Repository Settings の整備

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-008 |
| タイトル | github-repo-settings |
| 起票日 | 2026-05-08 |
| 起票者 | ユーザー指示 |
| 影響範囲 | GitHub repository 設定（外部システム）+ `.github/ISSUE_TEMPLATE/config.yml` の placeholder 解消 |

## 1. 背景

bootstrap (commit `7dbf6b1`) 以降、GitHub repository は private で作成され (steering 005 / 6 / 7 の作業を経て) MIT LICENSE / CONTRIBUTING.md / SECURITY.md / CODE_OF_CONDUCT.md / Description / sphinx-docs まで整備が進んだが、**repository 設定そのもの**（topics / homepage / vulnerability reporting / dependabot alerts / actions security / templates の placeholder 等）は bootstrap 直後の初期値のまま。

steering 005 Phase 5 では「Settings → Security → Private vulnerability reporting を有効化」を user 手動 TODO として記録していたが未対応。drift analysis (steering 006) でも repo 設定整備は触れられていなかった。

## 2. 動機

- **steering 005 Phase 5 の TODO 解消**: SECURITY.md で案内している GHSA `Report a vulnerability` ボタンが Security タブに表示されるようにする。
- **dependency security の最低ライン確保**: `Dependabot alerts` が現在 disabled。public 化前でも有効化しておけば、後の依存追加時に upstream 脆弱性を検知できる。
- **discoverability**: 現在 topics 未設定 / homepage 空。public 化時 (Phase 1 リリース) に外部からの発見性が低い。今のうちに整えておけば、visibility 切替で即座に効力を持つ。
- **Issue templates の TBD 解消**: `.github/ISSUE_TEMPLATE/config.yml` に `{{GITHUB_REPO}}` placeholder が残存。bootstrap 時の漏れ。
- **Actions security 強化**: `sha_pinning_required` が false。GitHub 公式は third-party action の pinning を推奨しており、有効化のコストはほぼゼロ。

## 3. 現状調査結果（2026-05-08、`gh repo view` + `gh api` 経由、read-only）

| 項目 | 現状 | 推奨 |
|---|---|---|
| Default branch | `main` | OK、変更不要 |
| Visibility | PRIVATE | Phase 1 リリース時に public 化（steering 005 で記録済み） |
| Description | "Production-ready ReScript bindings for Tauri 2.x (@tauri-apps/api)" | OK |
| Homepage URL | (空) | **設定**: `https://nagatatz.github.io/rescript-tauri/` |
| License | MIT (検出済み) | OK |
| Has Issues | true | OK |
| Has Wiki | false | OK（docs/ で十分） |
| Has Projects | true（未使用） | **無効化**（クリーン化、必要になったら再有効化） |
| Has Discussions | false | Phase 1 後に検討、現状のまま |
| Topics | (null) | **設定**: rescript / tauri / tauri-2 / bindings / desktop / ipc / monorepo（推奨 7 個） |
| Security policy | SECURITY.md 認識済み | OK |
| Branch protection (main) | **設定不可** (Free Plan + private repo の制約、HTTP 403) | public 化後に対応（本ステアリング外） |
| Private vulnerability reporting | 未設定 (HTTP 404) | **有効化** |
| Vulnerability alerts (Dependabot) | **無効** (HTTP 404 "alerts are disabled") | **有効化** |
| Actions workflow permissions | enabled / all / sha_pinning_required: false | **`sha_pinning_required: true` 化** |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | 日本語、構造 OK | OK |
| `.github/ISSUE_TEMPLATE/feature_request.yml` | 日本語、構造 OK | OK |
| `.github/ISSUE_TEMPLATE/config.yml` | **`{{GITHUB_REPO}}` placeholder 残存** | **`Nagatatz/rescript-tauri` に置換**、Discussions 無効状態の整合確認 |
| `.github/PULL_REQUEST_TEMPLATE.md` | 日本語、構造 OK | OK |

## 4. スコープ

### 4.1 対象 (in-scope)

A. **gh CLI で実行可能な settings 変更（Claude 実行）**:
- Topics 設定
- Homepage URL 設定
- Has Projects 無効化
- Private vulnerability reporting 有効化
- Vulnerability alerts (Dependabot) 有効化
- Actions sha_pinning_required 有効化

B. **コード変更**:
- `.github/ISSUE_TEMPLATE/config.yml` の placeholder 解消、Discussions 無効状態に整合させる

C. **ユーザー手動が必要な項目の手順書化**:
- Branch protection 設定（public 化後、別タスク）
- Has Discussions 有効化判断（Phase 1 後）
- Repository Insights → Community Profile での充足状況確認

### 4.2 対象外 (out-of-scope)

- visibility の private → public 切替（Phase 1 リリース時、`README.md` Visibility ブロックの 5 条件達成後）
- Branch protection 設定（free plan + private の制約、public 化後に別ステアリング）
- GitHub Sponsors / Funding 設定
- Webhooks / Apps の追加
- secret scanning（GitHub Advanced Security 必要、コスト発生）
- Code scanning（CodeQL 等、Phase 1 で言語が出揃ってから検討）
- Pages 公開設定（visibility 切替時に有効化）

## 5. 設計上の派生決定（要承認）

### 5.1 Topics の選定

| 案 | 内容 | 推奨 |
|---|---|---|
| A | 7 topics: `rescript / tauri / tauri-2 / bindings / desktop / ipc / monorepo` | ✅ Recommended（必要十分、検索ヒット率と過剰タギングの中間） |
| B | 12 topics 詳細版（+ `webview / ffi / desktop-app / cross-platform / typescript-alternative`） | — (一部は曖昧 / 重複) |
| C | 3 topics 最小版（`rescript / tauri / bindings` のみ） | — (検索ヒット率が低い) |

GitHub Topics の制約: 最大 20 個、各 50 文字以内、`a-z 0-9 -` のみ、先頭は alphanumeric。

### 5.2 Has Projects の扱い

| 案 | 内容 | 推奨 |
|---|---|---|
| A | **無効化**。現在未使用、リポ画面のクリーン化、後で必要になれば 1 click で再有効化可 | ✅ Recommended |
| B | true のまま放置 | — (タブが残るが空、informational なノイズ) |

### 5.3 Has Discussions の扱い

| 案 | 内容 | 推奨 |
|---|---|---|
| A | false のまま（現状維持）。Phase 1 後 / public 化後に再検討 | ✅ Recommended |
| B | 今すぐ有効化。`config.yml` の "質問は Discussions で" を機能させる | — (private のうちは外部から書き込めず実用性低い) |

派生対応: Discussions 無効状態を維持するため、`config.yml` の "質問は Discussions で" リンクを **Issue ベースの案内に置換** する（現実的なフォールバック）。

### 5.4 Branch protection

| 項目 | 状態 |
|---|---|
| 設定試行結果 | HTTP 403 "Upgrade to GitHub Pro or make this repository public to enable this feature." |
| 判断 | 本ステアリング外。public 化後に別ステアリングで対応（settings 内容も Phase 1 のチーム構成・CI が確定してから） |

### 5.5 Actions sha_pinning_required

| 案 | 内容 | 推奨 |
|---|---|---|
| A | **true 化**。third-party action は SHA で pin することを GitHub 自身が推奨。本プロジェクトの workflow は `actions/checkout@v6`、`astral-sh/setup-uv@v6` 等 tag 参照のため、有効化すると新規 workflow に強制が働く | ✅ Recommended（既存 workflow も後で SHA pinning 移行が望ましいが、本ステアリングではフラグだけ立てる） |
| B | false のまま | — (security 推奨に反する) |

派生対応: 既存 workflow (`docs.yml`、`*.template`) の tag → SHA 移行は **別ステアリング**で扱う。本 steering ではフラグ ON のみ。

## 6. 受け入れ条件

- [ ] Topics 設定: 5.1 採用案の値が `gh repo view --json repositoryTopics` で確認できる
- [ ] Homepage URL 設定: `https://nagatatz.github.io/rescript-tauri/` が `gh repo view --json homepageUrl` で確認できる
- [ ] Has Projects 無効化: `gh repo view --json hasProjectsEnabled` が `false`
- [ ] Private vulnerability reporting 有効化: `gh api repos/Nagatatz/rescript-tauri/private-vulnerability-reporting` が `enabled: true`
- [ ] Vulnerability alerts 有効化: `gh api repos/Nagatatz/rescript-tauri/vulnerability-alerts` が 204 (有効) を返す
- [ ] Actions sha_pinning_required 有効化: `gh api repos/Nagatatz/rescript-tauri/actions/permissions` で `sha_pinning_required: true`
- [ ] `.github/ISSUE_TEMPLATE/config.yml` から `{{GITHUB_REPO}}` 完全削除、Discussions 無効状態に整合
- [ ] 派生決定 5.1 / 5.2 / 5.3 / 5.5 が反映
- [ ] 5.4 (Branch protection) は別タスクとして手順書化済み

## 7. 影響を受けないこと

- 既存 `docs/` / `README.md` / `CLAUDE.md` / `LICENSE` の内容（settings の状態を文書に反映する微修正は別途検討、本ステアリングの主スコープ外）
- `.github/workflows/*` の内容（sha pinning 移行は別ステアリング）
- `packages/`, `examples/`, `sphinx-docs/`
- 既存の `.github/ISSUE_TEMPLATE/bug_report.yml` / `feature_request.yml` / `PULL_REQUEST_TEMPLATE.md`

## 8. リスク

| リスク | 影響度 | 対応 |
|---|---|---|
| Topics 選定が後で「外したい」「追加したい」になる | 低 | `gh api` で変更容易、別タスクで対応可 |
| Dependabot alerts 有効化で過去の依存に対し alert が大量発生 | 低 | 現状 sphinx-docs/uv.lock のみ。npm 依存はまだない。発生しても件数は限定的 |
| sha_pinning_required を立てた後、新規 workflow 追加時にユーザーが SHA pin を忘れて失敗 | 中 | 失敗時のエラーメッセージは明確。本 steering の tasklist にユーザー周知を含める |
| Has Projects 無効化により既存の Project board が消える | 低 | 現状未使用なので影響なし。確認の上で実行 |
| 私 (Claude) が gh API で意図しない設定変更を行う | 中 | 各変更コマンドを tasklist に明記し、AskUserQuestion で実行スコープを承認後に実行 |

## 9. 後続タスクへの引き継ぎ

本ステアリング完了後の TODO（別ステアリング）:

- **Branch protection 設定**: visibility public 化後に別ステアリングで対応
- **Workflow の SHA pinning 移行**: `docs.yml` / `*.template` の tag → SHA 化（本 steering で sha_pinning_required を true にしたため、新規 workflow には自動強制されるが既存は手動移行）
- **Repository Insights → Community Profile スコア確認**: visibility 切替後に user 手動で確認
