# Steering 032: @rescript-tauri/plugin-fs パッケージ実装

| 項目 | 内容 |
|---|---|
| 作成日 | 2026-05-09 |
| 関連 | .steering/20260509-030-phase2-planning, PRD §4 (plugin-fs Should), architecture §4 |
| ブランチ | `worktree-phase2-plugin-fs` |

## 背景

Phase 2 計画 (steering 030) の Must スコープに `@rescript-tauri/plugin-fs` (upstream `@tauri-apps/plugin-fs` v2.5.x のバインディング) が含まれる。本 steering で **基本 14 関数の同期 API** を実装する。

upstream の API 表面は大きい（21 関数 + `FileHandle` クラス + `watch` 系 + `WatchEvent` variant tree）ため、本 steering は **同期的な単発 IO 関数群** に絞る。`FileHandle` 系（`open` / `create` + インスタンスメソッド ~10）と `watch` / `watchImmediate` + `WatchEvent` variant は **後続 sub-steering** に分離する。

## 要求

### A. パッケージ bootstrap

`packages/plugin-fs/` を新規作成、`@rescript-tauri/schema` と同じ構造で:

- `package.json` — `@rescript-tauri/plugin-fs`、`peerDependencies` を確定
- `rescript.json` — `@rescript-tauri/core` を依存に追加
- `src/PluginFs.res` / `PluginFs.resi`
- `tests/plugin_fs_signature.res` — 型レベル網羅
- `tests/runtime/plugin_fs.test.mjs` — vitest + Mocks 経由
- `vitest.config.mjs` — happy-dom
- `README.md`

### B. バインディング範囲（本 steering）

**関数（14):**
- `readTextFile`, `writeTextFile`
- `readFile`, `writeFile`
- `exists`, `remove`, `rename`
- `mkdir`, `readDir`
- `stat`, `lstat`, `truncate`, `copyFile`, `size`

**型:**
- `fileInfo` record（`isFile` / `isDirectory` / `isSymlink` / `size` / `mtime?` / `atime?` / `birthtime?` / mode 系）
- `dirEntry` record（`name` / `isFile` / `isDirectory` / `isSymlink`）
- 各関数の options record (`readFileOptions`, `writeFileOptions`, `mkdirOptions`, `removeOptions`, `renameOptions`, `copyFileOptions`, `statOptions`, `existsOptions`, `truncateOptions`, `readDirOptions`)
- `baseDir?: RescriptTauriCore.Path.BaseDirectory.t` を `~baseDir=?` ラベルで引数に統合

### C. core の `BaseDirectory` 再利用

upstream は `@tauri-apps/api/path` の `BaseDirectory` enum を使う。本バインディングは `@rescript-tauri/core` の `Path.BaseDirectory.t`（`type t = private int`）を peerDep 経由で参照し、独自 enum を持たない。

### D. テスト

- 型レベル: `plugin_fs_signature.res` で 14 関数 + 型を `_check_*` で参照
- runtime（happy-dom + Mocks）:
  - `readTextFile` で `Mocks.mockIPC` が呼ばれ、結果を取得
  - `writeTextFile` で IPC が呼ばれる
  - `mkdir` の options が透過する
  - `stat` で `fileInfo` が返る
  - `readDir` で `dirEntry[]` が返る

### E. README + 互換マトリクス

`packages/plugin-fs/README.md` に upstream 互換マトリクス記載:

| `@rescript-tauri/plugin-fs` | `@rescript-tauri/core` | `@tauri-apps/plugin-fs` |
|---|---|---|
| `^0.1.0` | `^0.1.0` | `^2.5.0` |

## Non-goals（本 steering スコープ外）

- `FileHandle` クラスバインディング（`open`, `create`, `read`, `write`, `seek`, `stat`, `truncate`, `close` 等）→ 後続 steering で
- `watch` / `watchImmediate` + `WatchEvent` variant tree → 後続 steering で
- `readTextFileLines`（AsyncIterable 戻り値、特殊）→ 後続 steering で
- `startAccessingSecurityScopedResource` / `stopAccessingSecurityScopedResource`（iOS 専用）→ 後続
- npm publish（Phase 2 全体 release-checklist で実施）
- examples 追加（別 steering で）

## 受け入れ条件

- [x] `packages/plugin-fs/` 雛形 + 全ファイル
- [x] 14 関数 + 関連 record / variant 型を `.resi` で公開
- [x] `pnpm --filter @rescript-tauri/plugin-fs build` 緑
- [x] `pnpm --filter @rescript-tauri/plugin-fs test` 緑
- [x] 既存 core / schema パッケージに regression なし
- [x] `docs/repository-structure.md` の `packages/plugin-fs/` 記述更新
