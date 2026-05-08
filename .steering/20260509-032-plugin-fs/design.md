# Design: @rescript-tauri/plugin-fs パッケージ実装

## 1. ファイル配置

```
packages/plugin-fs/
├── src/
│   ├── PluginFs.res                    # 実装本体
│   └── PluginFs.resi                   # 公開シグネチャ
├── tests/
│   ├── plugin_fs_signature.res         # 型レベル網羅
│   └── runtime/
│       └── plugin_fs.test.mjs          # vitest + Mocks 経由
├── package.json                        # @rescript-tauri/plugin-fs
├── rescript.json
├── vitest.config.mjs
└── README.md

docs/
└── repository-structure.md             # 更新（packages/plugin-fs/ 着手済み）
```

## 2. 公開 API（本 steering スコープ）

### 関数（14）

| 関数 | シグネチャ | upstream invoke 名 |
|---|---|---|
| `readTextFile` | `(string, ~options=?) => promise<string>` | `plugin:fs\|read_text_file` |
| `writeTextFile` | `(string, string, ~options=?) => promise<unit>` | `plugin:fs\|write_text_file` |
| `readFile` | `(string, ~options=?) => promise<Uint8Array.t>` | `plugin:fs\|read_file` |
| `writeFile` | `(string, Uint8Array.t, ~options=?) => promise<unit>` | `plugin:fs\|write_file` |
| `exists` | `(string, ~options=?) => promise<bool>` | `plugin:fs\|exists` |
| `remove` | `(string, ~options=?) => promise<unit>` | `plugin:fs\|remove` |
| `rename` | `(string, string, ~options=?) => promise<unit>` | `plugin:fs\|rename` |
| `mkdir` | `(string, ~options=?) => promise<unit>` | `plugin:fs\|mkdir` |
| `readDir` | `(string, ~options=?) => promise<array<dirEntry>>` | `plugin:fs\|read_dir` |
| `stat` | `(string, ~options=?) => promise<fileInfo>` | `plugin:fs\|stat` |
| `lstat` | `(string, ~options=?) => promise<fileInfo>` | `plugin:fs\|lstat` |
| `truncate` | `(string, ~len=?, ~options=?) => promise<unit>` | `plugin:fs\|truncate` |
| `copyFile` | `(string, string, ~options=?) => promise<unit>` | `plugin:fs\|copy_file` |
| `size` | `string => promise<float>` | `plugin:fs\|size` |

### 型

- `fileInfo` — 19 フィールドのレコード型 (isFile / isDirectory / isSymlink / size / mtime?Date / atime?Date / birthtime?Date / readonly / fileAttributes? / dev? / ino? / mode? / nlink? / uid? / gid? / rdev? / blksize? / blocks?)
- `dirEntry` — 4 フィールド (name / isFile / isDirectory / isSymlink)
- 各関数 options record (10 種): `readFileOptions` / `writeFileOptions` / `mkdirOptions` / `removeOptions` / `renameOptions` / `copyFileOptions` / `statOptions` / `existsOptions` / `readDirOptions` / `truncateOptions`

### 再エクスポート

```rescript
module BaseDirectory = RescriptTauriCore.Path.BaseDirectory
```

`@rescript-tauri/core` の `Path.BaseDirectory.t` (private int) を peerDep 経由で再利用。独自 enum は持たない。

## 3. 主要設計判断

### 3.1 BaseDirectory の共有

upstream `@tauri-apps/plugin-fs` は `@tauri-apps/api/path` の `BaseDirectory` を再利用するので、本バインディングも `@rescript-tauri/core` の `Path.BaseDirectory` を再利用する。`PluginFs.BaseDirectory` はタイプエイリアスのみ。

### 3.2 invoke 形状の差分

upstream 関数のうち:
- `mkdir` / `stat` / `readDir` / `exists` / `remove` / `rename` / `copyFile` / `lstat` / `readFile` / `truncate` / `size` は `invoke('plugin:fs|<name>', {path, options})` 形（args = obj）
- `writeTextFile` / `writeFile` は `invoke('plugin:fs|<name>', encodedBytes, {headers: {path, options}})` 形（args = bytes、path は headers）

mockIPC は `(cmd, args)` のみ捕捉し headers を捨てる。テストでは:
- 前者: `args.path` / `args.options.*` を直接 assert
- 後者: cmd 名と args の存在確認のみ（path 検証は upstream の挙動依存なので避ける）

### 3.3 readTextFile のデコード

upstream は `read_text_file` の戻り値をバイト列として受け取り、フロント側で `TextDecoder.decode()` する。テストでは mock 戻り値に `TextEncoder.encode("hello")` の `Array.from(...)` を返し、フロントでデコードされた `"hello"` が得られることを検証。

### 3.4 vitest 環境

`@rescript-tauri/core` / `schema` と同じく `happy-dom`。`Mocks.mockIPC` / `Mocks.clearMocks` で `__TAURI_INTERNALS__.invoke` を差し替える。

### 3.5 peerDependencies

| Peer | 範囲 |
|---|---|
| `@rescript-tauri/core` | `^0.1.0` |
| `@tauri-apps/plugin-fs` | `^2.5.0` (v2.5.1 が最新の確認時点) |
| `rescript` | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |

## 4. テストカバレッジ

### 4.1 型レベル

`tests/plugin_fs_signature.res`:
- 14 関数 × `_check_*`
- `BaseDirectory.t` 値の存在確認

合計 15 lets。`.resi` の公開 let 数 = 15 と一致（PluginFs 専用）。

### 4.2 runtime（6 ケース）

- `readTextFile` の round-trip + UTF-8 デコード
- `writeTextFile` の cmd 確認（path は headers なので skip）
- `mkdir` の options 透過
- `stat` の `fileInfo` 構造
- `readDir` の `array<dirEntry>`
- `exists` の `bool`

## 5. 後続スコープ（本 steering で実装しない）

| 項目 | 想定 sub-steering |
|---|---|
| `FileHandle` (open / create + read / write / seek / stat / close) | `2026MMDD-NNN-plugin-fs-filehandle` |
| `watch` / `watchImmediate` + `WatchEvent` variant tree | `2026MMDD-NNN-plugin-fs-watch` |
| `readTextFileLines` (AsyncIterable 戻り値) | `2026MMDD-NNN-plugin-fs-iterables` |
| `startAccessingSecurityScopedResource` 等 | `2026MMDD-NNN-plugin-fs-ios-only` |

各々の優先度は plugin-dialog 完成後に再判定。

## 6. CI 影響

- core / schema 既存ジョブには影響なし（path filter で plugin-fs を拾わない）
- `plugin-fs` 専用 CI ジョブ追加は別 sub-steering（design.md §6 で取り扱う本 steering スコープ外項目）。当面は `pnpm --recursive build / test` で plugin-fs もカバーされる
- `release.yml` の `plugin-fs-v*` タグサポートは別 sub-steering

## 7. リスク

| リスク | 兆候 | 対策 |
|---|---|---|
| upstream `@tauri-apps/plugin-fs` v3 の API drift | upstream major | peerDep 範囲を `^2.5.0` に絞る、互換 CI で先行検知 |
| 既存 `core` の `Path.BaseDirectory.t` シグネチャ変更 | core が破壊変更 | `@rescript-tauri/core` を peerDep `^0.1.0` で固定、core 変更は plugin-fs minor で追従 |
| `writeTextFile` の args 形が headers ベースから変わる | upstream minor で内部実装変更 | テストは cmd 名のみ assert（headers 内部に依存しない設計） |
