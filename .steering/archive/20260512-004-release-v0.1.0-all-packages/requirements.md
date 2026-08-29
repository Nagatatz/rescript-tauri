# Requirements: Release v0.1.0 — All 10 Packages

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-12 |
| リリース日 | 2026-05-12 (即日実施予定) |
| 関連 | `.steering/20260512-003-bulk-package-reservation-tooling/`, `.steering/20260512-002-npm-trusted-publishing/`, `.steering/20260509-029-phase1-release-followups/`, `.steering/20260509-046-phase2-release-checklist/` |

## 1. 背景

直前のステアリングで以下が完了している:

- ✅ 全 10 パッケージ npm 上で `0.0.0-reserved` 予約済み
- ✅ 全 10 パッケージ Trusted Publisher (GitHub Actions OIDC) 設定済み
- ✅ `release.yml` が OIDC publish に対応済み (tag prefix で 10 パッケージ識別)
- ✅ Phase 1 / Phase 2 リリースチェックリスト整備済み

ユーザーから「同一 commit で全パッケージを bump して即時リリース」の指示を受領 (2026-05-12)。

## 2. ゴール

**1 つの cut commit** で 10 パッケージすべての v0.1.0 リリースを準備し、tag push でリリースを実行する:

1. 10 個の `packages/*/package.json` の `version`: `0.0.0` → `0.1.0`
2. 10 個の `packages/*/CHANGELOG.md` の `## Unreleased` → `## 0.1.0 (2026-05-12)`
3. `sphinx-docs/user/changelog.md` の既存 4 セクション (`core` / `schema` / `plugin-fs` / `plugin-dialog`) を `(Unreleased)` → `0.1.0 (2026-05-12)` に更新
4. `sphinx-docs/user/changelog.md` に未掲載の 6 プラグイン (`plugin-shell` / `plugin-notification` / `plugin-log` / `plugin-os` / `plugin-clipboard-manager` / `plugin-http`) のセクションを **新規追加** （既存 Phase 2 セクションと同じスタイル）
5. tag push (`v0.1.0` → `schema-v0.1.0` → 8 plugin tags) で 10 パッケージを npm 公開
6. 公開後の検証: `npm view ... version` / GitHub Releases / スモーク試験

## 3. 非ゴール

- リリース後の Phase 3 計画起点 (`.steering/` 移動 / アナウンス) — 別作業
- Tauri.rs / Discord / Twitter 等のアナウンス — 別作業
- `.steering/archive/` 30 日経過分の整理 — 別作業
- core 以外の README 更新 — README は既に互換マトリクス記載済み

## 4. 受け入れ条件

### 4.1 Cut commit (Stage 1)

- [ ] 10 個の `packages/*/package.json` の `version` フィールドが `0.1.0`
- [ ] 10 個の `packages/*/CHANGELOG.md` の最初の `## ` ヘッダが `## 0.1.0 (2026-05-12)`
- [ ] `sphinx-docs/user/changelog.md` の既存 4 セクションヘッダから `(Unreleased)` が消えて `0.1.0 (2026-05-12)` になっている
- [ ] `sphinx-docs/user/changelog.md` に 6 プラグイン分の新セクションが追加されている（最低限: ヘッダ + Canonical link + Added 要約）
- [ ] 単一 commit `📝 Cut all packages v0.1.0 (2026-05-12)` でまとめる
- [ ] commit 後に `pnpm --recursive build` が成功する
- [ ] commit 後に `pnpm --recursive test` が成功する

### 4.2 リリース実行 (Stage 2)

- [ ] commit を origin/main に push し、GitHub Actions 全 CI が green
- [ ] `v0.1.0` タグを push → `@rescript-tauri/core@0.1.0` が npm に公開される
- [ ] 残り 9 タグを push → 各パッケージが npm に公開される
- [ ] GitHub Releases ページに 10 件の Release が出現

### 4.3 公開後検証 (Stage 3)

- [ ] 10 パッケージすべて `npm view <pkg> version` が `0.1.0` を返す
- [ ] 10 パッケージすべて `npm view <pkg> dist-tags` が `latest: 0.1.0` (reserved タグは残存可)
- [ ] 9 plugin パッケージで `npm view <pkg> peerDependencies` が `@rescript-tauri/core ^0.1.0` を含む
- [ ] スモーク試験: `pnpm add @rescript-tauri/core @tauri-apps/api rescript @rescript/core` が peerDep error なく完了

## 5. 制約

- **`core` を最初に publish する**: 9 plugin の `peerDependencies` が `@rescript-tauri/core ^0.1.0` を要求するため、core の公開を確認してから plugin tags を push する
- 各 tag push 後、release.yml の完了を確認してから次の tag を push（並列実行を避け、npm registry のスロットルを回避）
- `npm publish` は実行されたら **unpublish は 72 時間以内のみ可能** で、それ以降は `npm deprecate` でしか対処できない。タグ push 前に必ずユーザー確認を取る
- pre-release のため後方互換性は不要 (CLAUDE.md memory)
- ディスク使用率 93% （14 GB 空き）。`pnpm install --recursive` で追加スペース消費の可能性があるが、既存 `node_modules` があるため大きな増加はない見込み
