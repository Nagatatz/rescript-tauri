# Design: Release v0.1.0 — All 10 Packages

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-12 |
| 関連 | requirements.md |

## 1. Cut commit の構成

### 1.1 対象ファイル (22 files)

| カテゴリ | 件数 | 変更 |
|---|---|---|
| `packages/*/package.json` | 10 | `"version": "0.0.0"` → `"version": "0.1.0"` |
| `packages/*/CHANGELOG.md` | 10 | `## Unreleased` → `## 0.1.0 (2026-05-12)` |
| `sphinx-docs/user/changelog.md` (既存 4 + 新規 6) | 1 | 4 セクションヘッダ更新 + 6 セクション新規追加 |
| `.steering/20260512-004-release-v0.1.0-all-packages/tasklist.md` | 1 | T1-Tn を `[x]` 更新（commit に含める） |

合計 22 ファイル。

### 1.2 macOS BSD sed コマンド

```bash
RELEASE_DATE="2026-05-12"

# 10 packages: version bump + CHANGELOG date
for pkg in core schema plugin-fs plugin-dialog plugin-shell plugin-notification plugin-log plugin-os plugin-clipboard-manager plugin-http; do
  sed -i '' 's/"version": "0.0.0"/"version": "0.1.0"/' "packages/$pkg/package.json"
  sed -i '' "s/^## Unreleased\$/## 0.1.0 ($RELEASE_DATE)/" "packages/$pkg/CHANGELOG.md"
done

# sphinx-docs: existing 4 sections
for pkg in core schema plugin-fs plugin-dialog; do
  sed -i '' "s/^## \`@rescript-tauri\/$pkg\` (Unreleased)\$/## \`@rescript-tauri\/$pkg\` 0.1.0 ($RELEASE_DATE)/" sphinx-docs/user/changelog.md
done
```

### 1.3 sphinx-docs 新規 6 セクション

6 プラグインのセクションを `sphinx-docs/user/changelog.md` の既存セクション末尾 (line 109 付近、`## Repository-level updates` の直前) に挿入する。各セクションは:

```markdown
## `@rescript-tauri/<plugin>` 0.1.0 (2026-05-12)

Canonical: [`packages/<plugin>/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/<plugin>/CHANGELOG.md)

### Added

- <1-3 行のサマリ>
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/<plugin> ^X.Y.0`.
```

各 6 セクションの中身は本デザイン §1.4 で確定。

### 1.4 6 プラグインの sphinx-docs セクション本文

```markdown
## `@rescript-tauri/plugin-shell` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-shell/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-shell/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-shell` v2.3.5 — 100% of the
  stable public surface (`openPath` / `Command.{create,createRaw,
  sidecar,sidecarRaw,spawn,execute,onClose,onError,onStdoutData,
  onStderrData}` / `Child.{pid,kill,write}` / `EventEmitter`).
- Runnable example
  [`examples/plugin-shell-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-shell-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-shell ^2.3.0`.

## `@rescript-tauri/plugin-notification` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-notification/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-notification/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-notification` v2.3.3 — 100% of
  the stable public surface (15 functions + 8 records +
  `Schedule` module + `Importance` / `Visibility` `@unboxed`
  variants).
- The upstream `sendNotification(Options | string)` overload is
  split into `sendNotification` / `sendNotificationText` so the
  argument type stays static.
- Runnable example
  [`examples/plugin-notification-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-notification-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-notification ^2.3.0`.

## `@rescript-tauri/plugin-log` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-log/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-log/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-log` v2.8.0 — 100% of the
  stable public surface (5 log functions + `attachLogger` +
  `attachConsole` + `LogLevel` `@unboxed` variant).
- `LogLevel.t` is an `@unboxed` polymorphic-variant wrapper over
  the upstream numeric enum (`Trace`=1 … `Error`=5) so the runtime
  representation stays wire-compatible.
- Runnable example
  [`examples/plugin-log-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-log-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-log ^2.0.0`.

## `@rescript-tauri/plugin-os` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-os/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-os/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-os` v2.3.2 — 100% of the
  stable public surface (6 sync getters + `OsType.get` (sync) +
  `locale` / `hostname` (async) + 4 polymorphic variants).
- `OsType.get` lives in an `OsType` submodule because `type` is
  reserved at the top level of a ReScript module.
- Runnable example
  [`examples/plugin-os-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-os-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-os ^2.0.0`.

## `@rescript-tauri/plugin-clipboard-manager` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-clipboard-manager/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-clipboard-manager/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-clipboard-manager` v2.3.2 —
  100% of the stable public surface (6 functions: `writeText` /
  `readText` / `writeImage` / `readImage` / `writeHtml` /
  `clear`).
- `readImage` returns `RescriptTauriCore.Image.t` (the existing
  core image handle, reused via `peerDependencies`).
- Runnable example
  [`examples/plugin-clipboard-manager-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-clipboard-manager-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-clipboard-manager ^2.0.0`.

## `@rescript-tauri/plugin-http` 0.1.0 (2026-05-12)

Canonical: [`packages/plugin-http/CHANGELOG.md`](https://github.com/Nagatatz/rescript-tauri/blob/main/packages/plugin-http/CHANGELOG.md)

### Added

- Bindings for `@tauri-apps/plugin-http` v2.5.9 — 100% of the
  stable public surface (`fetch` + 5 record / variant types:
  `proxy<'proxyValue>` / `proxyConfig` / `basicAuth` /
  `clientOptions<'proxyValue>` / `dangerousSettings`).
- The DOM `Request` / `Response` / `RequestInit` types are
  intentionally polymorphic; the call site picks a strategy
  (annotation / `Obj.magic` / external binding).
- Runnable example
  [`examples/plugin-http-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-http-demo).
- `peerDependencies`: `@rescript-tauri/core ^0.1.0`,
  `@tauri-apps/plugin-http ^2.0.0`.
```

## 2. リリース実行戦略

### 2.1 タグ push 順序

```
Stage 2.1: cut commit を main に push
   ↓ (CI が green になるまで待つ)
Stage 2.2: v0.1.0 (core) を push → npm 公開を確認
   ↓ (release.yml 完了 = npm view @rescript-tauri/core version → 0.1.0)
Stage 2.3: 9 plugin tags を順次 push (schema → plugin-fs → … → plugin-http)
   ↓ (各 tag 完了を待ってから次へ)
Stage 2.4: 全 10 パッケージの公開を検証
```

### 2.2 タグ push コマンド (順序保証版)

```bash
# Stage 2.2: core (最重要 — peerDep の基盤)
git tag -a v0.1.0 -m "v0.1.0 — Phase 1 release (core)"
git push origin v0.1.0
# ⏸ ここで release.yml の完了を待つ
# 確認: gh run watch (もしくは GitHub UI)
npm view @rescript-tauri/core version  # → 0.1.0 を確認

# Stage 2.3: 9 plugins (1 タグずつ完了確認推奨)
for pkg in schema plugin-fs plugin-dialog plugin-shell plugin-notification plugin-log plugin-os plugin-clipboard-manager plugin-http; do
  tag="${pkg}-v0.1.0"
  git tag -a "$tag" -m "$tag — Phase 1+2 release"
  git push origin "$tag"
  echo "Pushed $tag — wait for release.yml to complete before next push"
  # 推奨: gh run watch
done
```

### 2.3 並列性の判断

release.yml は tag prefix で 1 パッケージのみ処理するため、複数 tag を並列 push しても **互いに干渉しない**。

ただし以下のリスクで **逐次 push を推奨**:

- npm registry のレート制限 (短時間に複数 publish でスロットルされる事例あり)
- CI failure 発生時の切り分けが容易 (どの tag が失敗したか自明)
- 万一 publish 失敗時に途中で止めて修正 → 再実行できる

## 3. 公開後検証

### 3.1 npm 状態

```bash
for pkg in core schema plugin-fs plugin-dialog plugin-shell plugin-notification plugin-log plugin-os plugin-clipboard-manager plugin-http; do
  full="@rescript-tauri/$pkg"
  printf "  %-44s " "$full"
  ver=$(npm view "$full" version 2>/dev/null)
  lat=$(npm view "$full" dist-tags.latest 2>/dev/null)
  printf "version=%s  latest=%s\n" "$ver" "$lat"
done
```

期待: 全 10 行で `version=0.1.0  latest=0.1.0`

### 3.2 peerDependencies 検証

```bash
for pkg in schema plugin-fs plugin-dialog plugin-shell plugin-notification plugin-log plugin-os plugin-clipboard-manager plugin-http; do
  echo "--- @rescript-tauri/$pkg ---"
  npm view "@rescript-tauri/$pkg" peerDependencies
done
```

期待: 各パッケージで `@rescript-tauri/core: '^0.1.0'` を含む。

### 3.3 GitHub Releases

```bash
gh release list --limit 15
```

期待: 10 件の release (`v0.1.0` / `schema-v0.1.0` / 8 plugin tags) が並ぶ。

### 3.4 スモーク試験

```bash
mkdir /tmp/rt-smoke && cd /tmp/rt-smoke
pnpm init -y
pnpm add @rescript-tauri/core @rescript-tauri/schema rescript-schema \
         @rescript-tauri/plugin-fs @tauri-apps/plugin-fs \
         @tauri-apps/api rescript @rescript/core
pnpm exec rescript -version  # → 12.x.x
cd / && rm -rf /tmp/rt-smoke
```

`peerDependencies` の resolution エラー無く install 完了することを確認。

## 4. リスク・回避策

| リスク | 影響 | 対策 |
|---|---|---|
| `pnpm --recursive build` がディスク不足で失敗 | cut commit 検証不可 | 失敗時は `pnpm store prune` で空き確保 |
| OIDC publish が想定外のエラー | publish 失敗 | release.yml の前段で test 失敗なら tag 削除 + 修正 + 再 tag |
| core publish 後に plugin が peerDep error | 想定外 | core 0.1.0 が npm 上で resolve 可能か確認してから plugin push |
| 途中で usage limit / セッション中断 | リリース部分完了 | tag 単位で完結する設計なので、最後の green commit + 残 tag push で再開可能 |
| `npm publish` が `403 - You cannot publish over the previously published versions: 0.1.0` | tag 再 push 不可 | バージョンを `0.1.1` 以降に上げる必要あり (deprecate 推奨) |
| sphinx-docs ビルドが新セクションでエラー | docs CI failure | cut commit 前に `cd sphinx-docs && make html` でローカル確認可能 (uv 環境必要) |
| 並列 tag push でレース状態 | 起きにくいが理論的可能 | 逐次 push を推奨 |

## 5. ロールバック計画

publish 後に重大な問題が判明した場合:

```bash
# 72 時間以内: unpublish (使い切り)
npm unpublish @rescript-tauri/<pkg>@0.1.0
# 72 時間超: deprecate (再 publish 可能)
npm deprecate @rescript-tauri/<pkg>@0.1.0 "0.1.0 has a critical issue; use 0.1.1"
```

修正後 `0.1.1` を切り直す手順は標準（version bump + tag push）。

## 6. 並列化判断

並列実装不要:

- cut commit は 1 つにまとめる方針なのでファイル並列処理は意味なし
- リリース実行は順序依存（core → plugins）
- sed + Edit 中心の作業で、1 セッションで十分対応可能
