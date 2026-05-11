# Phase 1 (`v0.1.0`) リリース当日チェックリスト

> 作業日: TBD（Phase 1 リリース確定時に追記）
> 担当: メンテナ（@Nagatatz）

実装はすべて main にマージ済み。本ドキュメントはリリース当日に **GitHub と npm 上で実施する手動操作** を 1 ページにまとめる。

## 1. リリース前確認（前日まで）

- [ ] PRD §8 リリースゲート全項目が ✓ になっていること
  - [x] 12 モジュール完備（Core / Event / Window / Webview / WebviewWindow / Path / App / Dpi / Image / Menu / Tray / Mocks）
  - [x] 全モジュール `.resi` 必須 + 各公開シンボルに Tauri 公式 URL
  - [x] examples 4 つが 3 OS で CI 緑（hello-world / window-management / ipc-typed / streaming-ipc）
  - [x] 互換マトリクス (`README.md`) 記載
- [ ] `docs/product-requirements.md` §10 残課題のうち Phase 1 リリース前確定分が「確定済み」になっていること
  - [x] #1 Tauri.res re-export → 確定済み (steering 023)
  - [x] #7 ReScript v11 サポート → 除外確定 (steering 002)
  - [ ] #3 invokeExn 命名 → 確定（`invokeExn` で実装済み、PRD 表記の確認のみ）
  - [ ] #6 Belt-only ユーザー向け shim → 提供しない確定（PRD 表記の確認のみ）

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

> **`NPM_TOKEN` は不要**: 本リポジトリは npm Trusted Publishing (OIDC) を採用しているため、Automation token を Repository secret として登録する必要はない。`release.yml` の `permissions: id-token: write` により、publish 時に短命トークンが自動発行される (steering 20260512-002)。

## 3. Branch protection 設定

GitHub UI → Settings → Branches → Add branch protection rule for `main`:

- [ ] Require a pull request before merging
- [ ] Require approvals: **0**（ソロメンテ運用、Phase 2 で 1 に上げる）
- [ ] Require status checks to pass before merging:
  - [ ] `build-core`
  - [ ] `tests-core-types`
  - [ ] `tests-core-runtime`
  - [ ] `doc-link-lint`
  - [ ] `examples-build (ubuntu-latest)`
  - [ ] `examples-build (macos-latest)`
  - [ ] `examples-build (windows-latest)`
- [ ] Require branches to be up to date before merging
- [ ] Restrict who can push to matching branches: **only repo admins**
- [ ] Allow force pushes: **off**
- [ ] Allow deletions: **off**

## 4. GitHub Security Advisories (GHSA) 有効化

GitHub UI → Settings → Code security and analysis:

- [ ] Private vulnerability reporting: **Enabled**
- [ ] Dependency graph: **Enabled** (auto for public repos)
- [ ] Dependabot alerts: **Enabled**
- [ ] Dependabot security updates: **Enabled**
- [ ] Secret scanning: **Enabled** (auto for public repos)
- [ ] Push protection for secrets: **Enabled**

参考: steering 008 §3「GitHub repository settings」に詳細がある。

## 5. リリース実行

```bash
# 1. main を最新に同期
git checkout main && git pull --ff-only

# 2. CHANGELOG / バージョンを更新
#    - sphinx-docs/user/changelog.md の "Unreleased" を "0.1.0 (YYYY-MM-DD)" に
#    - packages/core/package.json の "version": "0.0.0" → "0.1.0"
#    - 単発コミット: 📝 Cut v0.1.0 changelog
git add packages/core/package.json sphinx-docs/user/changelog.md
git commit -m "📝 Cut v0.1.0 changelog"
git push

# 3. tag を切って push
git tag -a v0.1.0 -m "v0.1.0 — Phase 1 release"
git push origin v0.1.0

# 4. release.yml ワークフローが自動で:
#    - core を build / test
#    - npm publish --provenance
#    - gh release create v0.1.0 --generate-notes
#    まで実行する
#
# 進捗は GitHub Actions タブで確認。失敗時は workflow_dispatch + dry_run=true でリハーサル可能。
```

## 6. リリース後検証

- [ ] `npm view @rescript-tauri/core version` が `0.1.0` を返すこと
- [ ] `npm view @rescript-tauri/core dist-tags` が `latest: 0.1.0` であること
- [ ] GitHub Releases ページに `v0.1.0` Release が出来ていること（auto-generated notes 付き）
- [ ] sphinx-docs サイト（GitHub Pages）が更新済みの changelog を表示していること
- [ ] 別ディレクトリでスモーク試験:
  ```bash
  mkdir /tmp/rt-smoke && cd /tmp/rt-smoke
  pnpm init -y
  pnpm add @rescript-tauri/core @tauri-apps/api rescript @rescript/core
  pnpm exec rescript -version  # >= 12.0.0 表示
  ```
- [ ] 互換マトリクス (`README.md`) の「Tauri 2.x / ReScript >= 12」表記が `npm view` の peerDependencies と一致すること

## 7. 告知（オプション）

- [ ] [ReScript Forum](https://forum.rescript-lang.org/) に Phase 1 リリースアナウンス
- [ ] [Tauri Discord](https://discord.com/invite/tauri) #showcase に投稿
- [ ] X/Twitter / Bluesky 等での告知

## 8. Phase 2 起点準備

- [ ] `.steering/` の完了済みディレクトリ (steering 002〜029) のうち最終コミット日が 30 日以上前のものを `.steering/archive/` へ移動（30 日経過後）
- [ ] Phase 2 の planning steering を 1 件作成（`@rescript-tauri/schema` のスコープ確定 / `plugin-fs` / `plugin-dialog` の優先順）

---

## 連絡先

- メンテナ: @Nagatatz
- リポジトリ: https://github.com/Nagatatz/rescript-tauri
- 関連 PRD: `docs/product-requirements.md` §8
