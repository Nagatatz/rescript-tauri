# Design: sphinx-docs `user/plugin-os.md`

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-004 |
| 関連 | requirements.md / steering 056 / `packages/plugin-os/src/PluginOs.resi` |

---

## 1. 出力ファイル

| ファイル | 状態 |
|---|---|
| `sphinx-docs/user/plugin-os.md` | 新規作成 |
| `sphinx-docs/user/index.md` | 編集（Phase 2 packages テーブル / toctree） |
| `sphinx-docs/user/installation.md` | 編集（cross-ref 行 / follow-up 注記） |

`sphinx-docs/locale/ja/LC_MESSAGES/user/plugin-os.po` は本ステアリングでは作成**しない**（後続 sub-steering）。

## 2. `plugin-os.md` のセクション設計

### 2.1 構成方針（plugin-fs.md / plugin-notification.md 準拠）

```
タイトル + リード文（upstream リンク付き）
   ↓
{note} ブロック: publish status
   ↓
[Checkpoint i] Install
   ↓
[Checkpoint i] Capabilities
   ↓
[Checkpoint ii] Sync getters (7 関数)
   ↓
[Checkpoint iii] Async getters (2 関数 + permission flow)
   ↓
[Checkpoint iv] Polymorphic variants + pattern match 例
   ↓
[Checkpoint iv] Pitfalls
   ↓
Compatibility
   ↓
See also
```

各 checkpoint は単独 commit 可能な粒度。

### 2.2 リード文

```markdown
ReScript bindings for the [Tauri 2.x OS info
plugin](https://v2.tauri.app/plugin/os-info/) — sync getters for
platform / family / arch and async getters for locale / hostname.
The 100% stable public surface of `@tauri-apps/plugin-os` v2.3.x
is covered.
```

upstream URL は `src/PluginOs.resi` で参照されている `https://v2.tauri.app/plugin/os-info/` を一次ソースとする（user prompt の `/plugin/os/` ではなくこちらが正）。個別シンボル URL は `https://v2.tauri.app/reference/javascript/os/#<symbol>`。

### 2.3 Checkpoint i: Install + Capabilities

#### Install

`pnpm add @rescript-tauri/plugin-os @tauri-apps/plugin-os` / `peerDependencies` 説明 / `rescript.json` 追加 / Rust 側 `tauri::Builder::default().plugin(tauri_plugin_os::init())`。

#### Capabilities

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "os:default"
  ]
}
```

`os:default` で `locale` / `hostname` の async IPC が許可される旨を一文で記載（sync getters は capability を要さない）。

### 2.4 Checkpoint ii: Sync getters (7 関数)

upstream で `window.__TAURI_OS_PLUGIN_INTERNALS__` を直接読むため、`Mocks.mockIPC` ではテストできず、`globalThis.window.__TAURI_OS_PLUGIN_INTERNALS__` を stub する旨を冒頭に注記。

```rescript
open RescriptTauriPluginOs

Console.log(PluginOs.eol())          // "\n" on POSIX, "\r\n" on Windows
Console.log(PluginOs.platform())     // #linux | #macos | ... (10 variants)
Console.log(PluginOs.version())      // OS version string
Console.log(PluginOs.family())       // #unix | #windows
Console.log(PluginOs.osType_())      // #linux | #windows | #macos | #ios | #android
Console.log(PluginOs.arch())         // #x86 | #x86_64 | ... (11 variants)
Console.log(PluginOs.exeExtension()) // "exe" on Windows, "" elsewhere
```

各関数を表で再確認:

| 関数 | 戻り値 | 備考 |
|---|---|---|
| `eol()` | `string` | OS-specific line terminator |
| `platform()` | `platform` variant | コンパイル時に固定 |
| `version()` | `string` | カーネル / リリース文字列 |
| `family()` | `family` variant | POSIX 系か Windows か |
| `osType_()` | `osType` variant | upstream `type()` のリネーム |
| `arch()` | `arch` variant | 11 アーキテクチャ対応 |
| `exeExtension()` | `string` | `"exe"` / `""` |

### 2.5 Checkpoint iii: Async getters (2 関数 + permission flow)

`locale` / `hostname` は IPC (`plugin:os|locale` / `plugin:os|hostname`) 経由で、戻り値が `promise<Nullable.t<string>>`。`Nullable.null` が "unavailable" を表すこと、capability `os:default` の `allow-locale` / `allow-hostname` が必要なことを明記。

```rescript
open RescriptTauriPluginOs

let printEnv = async () => {
  let host = await PluginOs.hostname()
  let lang = await PluginOs.locale()
  Console.log2("hostname:", host->Nullable.toOption->Option.getOr("(unknown)"))
  Console.log2("locale:",   lang->Nullable.toOption->Option.getOr("(unknown)"))
}
```

`Nullable.toOption` で `Option<string>` に変換するパターンを 1 行で示す。

### 2.6 Checkpoint iv: Polymorphic variants + pattern match

4 variant をそれぞれ列挙表で示す:

```rescript
// platform: 10 variants
[#linux | #macos | #ios | #freebsd | #dragonfly | #netbsd | #openbsd | #solaris | #android | #windows]

// osType: 5 variants
[#linux | #windows | #macos | #ios | #android]

// arch: 11 variants
[#x86 | #x86_64 | #arm | #aarch64 | #mips | #mips64 | #powerpc | #powerpc64 | #riscv64 | #s390x | #sparc64]

// family: 2 variants
[#unix | #windows]
```

OS 別分岐の代表例として `platform()` を pattern match する短いサンプルを掲載:

```rescript
let labelForPlatform = () =>
  switch PluginOs.platform() {
  | #macos => "macOS"
  | #linux | #freebsd | #dragonfly | #netbsd | #openbsd | #solaris => "Unix-like"
  | #windows => "Windows"
  | #ios => "iOS"
  | #android => "Android"
  }
```

総当たり性 (exhaustive) を ReScript コンパイラが保証することに 1 行触れる。

### 2.7 Checkpoint iv: Pitfalls

3 つのサブセクション:

1. **`type()` → `osType_()` rename** — ReScript で `type` は予約語のため。サフィックス `_` 付き。
2. **Sync getters don't go through IPC** — `Mocks.mockIPC` ではテスト不能。`globalThis.window.__TAURI_OS_PLUGIN_INTERNALS__` を stub する（実装側 README §1 と同様）。実装側のテスト `tests/runtime/plugin_os.test.mjs` への参照リンク。
3. **`#x86_64` is a valid variant tag** — ReScript の polymorphic variant タグは `_` を含めて識別子として扱えるため、`#x86_64` などはそのまま記述可能（特別な escape は不要）。

### 2.8 Compatibility テーブル

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-os` | `^2.0.0` (peer) |
| Rust `tauri-plugin-os` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows / iOS / Android |

### 2.9 See also

- Source: `https://github.com/Nagatatz/rescript-tauri/tree/main/packages/plugin-os`
- Upstream docs: `https://v2.tauri.app/plugin/os-info/`
- Upstream JS reference: `https://v2.tauri.app/reference/javascript/os/`

`examples/plugin-os-demo` のリンクは未存在のため**追加しない**。

## 3. `index.md` の編集方針

### 3.1 Phase 2 packages テーブルに 1 行追加

```markdown
| `@rescript-tauri/plugin-os` | OS info (platform / arch / family / locale / hostname) | [plugin-os](plugin-os.md) |
```

挿入位置: 既存テーブルの末尾。`plugin-notification` の直後 / `schema` の前。並列セッション (001/003) が他の plugin を先にマージしていれば、その後ろに自然に追加。

### 3.2 `toctree` directive に追加

```
plugin-os
```

挿入位置: テーブルと同じ並び (`plugin-notification` の後 / `schema` の前)。

### 3.3 "four add-on packages" の文言更新

現状の index.md は steering 002 マージ後に "four add-on packages" となっているはず。本 steering で 1 件追加するため、"five add-on packages" に更新する。並列セッション 001 / 003 が先にマージされた場合は、最新の数値に合わせて調整する。

## 4. `installation.md` の編集方針

### 4.1 cross-ref 行 (line 72-74)

現状:
```
See the [plugin-fs](plugin-fs.md), [plugin-dialog](plugin-dialog.md),
and [schema](schema.md) guides for the matching ReScript / Rust /
capability setup.
```

更新後 (plugin-notification は既にマージ済み / 並列 001 003 がまだなら以下になる):
```
See the [plugin-fs](plugin-fs.md), [plugin-dialog](plugin-dialog.md),
[plugin-notification](plugin-notification.md), [plugin-os](plugin-os.md),
and [schema](schema.md) guides for the matching ReScript / Rust /
capability setup.
```

並列セッションで他のプラグインが先にマージされていれば、その並びに `[plugin-os](plugin-os.md)` を追加するのみ。

### 4.2 follow-up 注記 (line 76-84)

現状:
```
Dedicated user guides for `@rescript-tauri/plugin-shell`,
`@rescript-tauri/plugin-notification`, `@rescript-tauri/plugin-log`,
`@rescript-tauri/plugin-os`, and
`@rescript-tauri/plugin-clipboard-manager` are scheduled for follow-up
sub-steerings. Until then, refer to each package's own README
(`packages/plugin-{shell,notification,log,os,clipboard-manager}/README.md`)
for full API coverage and copy-pasteable examples.
```

`@rescript-tauri/plugin-os` を除外し、README パス glob 内の `os,` も除外する。並列マージ状況に応じて他項目の除外は別 steering に委ねる。

## 5. テスト戦略

ドキュメント追加のみのため自動テスト不要。手動検証:

1. **Markdown 構造**: 4 つの checkpoint が独立に commit 可能になっていること
2. **API シンボル整合性**: 9 関数 + 4 polymorphic variant 名がすべて `packages/plugin-os/src/PluginOs.resi` に実在することを `grep` で検証
3. **`index.md` の整合性**: テーブルと toctree の両方に `plugin-os` が含まれていること
4. **`installation.md` の整合性**: cross-ref 行に追加され、follow-up 注記から除外されていること
5. **`examples/plugin-os-demo` への言及がない**: `grep -n 'plugin-os-demo' sphinx-docs/user/plugin-os.md` で出力なしを確認

## 6. 完了条件

requirements §5 の受け入れ基準すべてを満たすこと。
