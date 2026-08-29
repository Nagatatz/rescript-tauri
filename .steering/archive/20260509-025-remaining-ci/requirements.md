# Steering 025: 残り CI workflows (compat × 2 + release)

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | functional-design §6, PRD §8 |
| ブランチ | `worktree-phase1-remaining-ci` |

## 背景

Phase 1 リリース要件 (PRD §8) に「CI 全プラットフォーム緑」と互換マトリクスが含まれる。functional-design §6 で計画されている 9 つの workflow のうち、現状 6 つが active (steering 017 で 5 個 + 既存 docs.yml)。残る 3 つは:

- `compat-tauri-latest.yml` — nightly で `@tauri-apps/api` の最新 minor を取り込んで build 確認
- `compat-rescript-prerelease.yml` — nightly で ReScript 12.x 次期マイナー / 次期メジャー prerelease で build 確認
- `release.yml` — git tag push トリガで npm publish + GitHub Release 作成

## 要求

### compat-tauri-latest.yml

- スケジュール: 毎日 06:00 UTC（任意の時刻でよい）
- `pnpm install` 後、`@tauri-apps/api@latest` をインストールし直して build 確認
- core の build / tests / examples の hello-world build を実行
- 失敗したら issue は自動で立てない（重複防止のため slack 通知や GH issue は Phase 2）
- 手動 dispatch も許可

### compat-rescript-prerelease.yml

- スケジュール: 毎日 06:00 UTC
- npm の `rescript@next` または `rescript@beta` を取り込み（dist-tag）
- 取り込めなかった場合（dist-tag が無い）はジョブを skip しつつ exit 0
- core build + tests を実行

### release.yml

- トリガ: `v*` パターンの tag push
- ワークフロー:
  1. checkout (with fetch-depth: 0 / tags: true)
  2. Node + pnpm セットアップ
  3. `pnpm install --frozen-lockfile`
  4. `pnpm --filter @rescript-tauri/core build`
  5. `pnpm --filter @rescript-tauri/core test`
  6. `cd packages/core && npm publish --provenance --access public` (provenance for npm trust)
  7. `gh release create $TAG --generate-notes` で GitHub Release 草案を作る
- secrets: `NODE_AUTH_TOKEN` (npm) を assume。これは repo settings で本人が登録する想定（CI workflow ファイル側では `secrets.NPM_TOKEN` を参照、無い場合は publish step を skip）
- workflow が secret 未設定でも syntactically 通る形にしておく（dry-run モードに fallback）

### Action SHA pinning

steering 028 (parallel session) で全 action は SHA pinning 済み。新 workflow も同じ規約に従う。

### README 更新

`.github/workflows/README.md` の「Planned for Phase 1」テーブルを「Active」に移し、それぞれの内容を記載。

## Non-goals

- Slack 通知 / GitHub Issue 自動作成 (Phase 2)
- Mobile (iOS / Android) ビルド確認 (Phase 3+)
- changelog 自動生成（Phase 2 で `changesets` 等を導入予定）

## 受け入れ条件

- [x] `compat-tauri-latest.yml` 作成、syntax 検証
- [x] `compat-rescript-prerelease.yml` 作成、syntax 検証
- [x] `release.yml` 作成、syntax 検証
- [x] `.github/workflows/README.md` を更新
- [x] 既存 6 workflow への影響なし
- [x] `pnpm --filter @rescript-tauri/core build` 緑
