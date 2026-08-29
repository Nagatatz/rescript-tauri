# Design: sphinx-docs/user/plugin-http.md

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-007 |
| 関連 | requirements.md, tasklist.md |
| 参考スタイル | `sphinx-docs/user/plugin-fs.md`, `sphinx-docs/user/plugin-dialog.md`, `sphinx-docs/user/plugin-log.md` |

## 1. ページ構造

```
# `@rescript-tauri/plugin-http`

(イントロ 1〜2 段落: Web-Fetch ラッパー + CORS bypass の特徴)

```{note}
Status note
```

## Install
  - JS pnpm add / peerDeps / rescript.json deps
  - Rust Cargo.toml / Builder
  - allowed URLs の tauri.conf.json 例

## Capabilities
  - http:default permission JSON

## Minimal example
  - 型注釈パターン (let response: 'response = await ...)
  - GET + JSON 簡易例

## Public API
  - 1 関数 + 5 型の表
  - ### fetch シグネチャと polymorphic 戻り値の扱い
  - ### clientOptions / proxy / proxyConfig / basicAuth
  - ### dangerousSettings

## Pitfalls
  - ### DOM Web Fetch types are intentionally unbound
  - ### Use a type annotation or Obj.magic
  - ### proxy<'proxyValue> per-slot value selection
  - ### dangerousSettings ships disabled

## Compatibility
  - 表

## See also
  - source / package README / upstream
```

## 2. セクション別設計

### 2.1 Intro

```markdown
# `@rescript-tauri/plugin-http`

ReScript bindings for the [Tauri 2.x HTTP fetch
plugin](https://v2.tauri.app/plugin/http-client/) — a Web Fetch
API wrapper that routes through the Rust side to bypass webview
CORS, plus typed proxy / TLS configuration. The 100% stable
public surface of `@tauri-apps/plugin-http` v2.5.9 is covered.
```

### 2.2 Status note

```{note} 形式で「Phase 2+ feature-complete in main、初 npm publish 待ち」を 4 行。`plugin-http-v0.1.0` 名で。

### 2.3 Install

- `pnpm add @rescript-tauri/plugin-http @tauri-apps/plugin-http`
- peerDeps: `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-http ^2.0.0`
- `rescript.json` の `dependencies` に追加
- Rust 側:
  ```toml
  [dependencies]
  tauri-plugin-http = "2"
  ```
  ```rust
  fn main() {
      tauri::Builder::default()
          .plugin(tauri_plugin_http::init())
          .run(tauri::generate_context!())
          .expect("error while running app");
  }
  ```
- `tauri.conf.json` の allowed origins は Tauri 2.x の capability で扱う旨を 1 文だけ示し、詳細は次セクションへ

### 2.4 Capabilities

```json
{
  "$schema": "../gen/schemas/desktop-schema.json",
  "identifier": "default",
  "windows": ["main"],
  "permissions": [
    "core:default",
    "http:default",
    {
      "identifier": "http:default",
      "allow": [{ "url": "https://api.example.com/*" }]
    }
  ]
}
```

- 解説: `http:default` で `fetch` API 利用許可。allowed URLs は scoped permission の `allow` で個別に指定する
- 上流 docs の "URL access" 節へリンク
- ローカルホスト・任意 URL を許す `**` 表記の注意（dev 用途のみ）

### 2.5 Minimal example

```rescript
open RescriptTauriPluginHttp

let getJson = async () => {
  let response: 'response =
    await PluginHttp.fetch("https://api.example.com/users")
  // The `fetch` return type is polymorphic; annotate or Obj.magic
  // for accessing DOM Response methods like `.json()` / `.status`.
  let body = (Obj.magic(response): {"json": unit => promise<'json>})["json"]()
  Console.log(await body)
}
```

- 上記コードは "polymorphic 戻り値 + Obj.magic アクセス" の典型パターンを示す
- 簡易 GET なら upstream の `fetch(url).then(r => r.json())` の感覚で使える旨を 1 文
- POST + init record（Tauri 拡張オプション込み）の追加コードも 1 例示

### 2.6 Public API

#### 2.6.1 シンボル表

| Symbol | Purpose |
|---|---|
| `fetch(input, ~init=?)` | Polymorphic Web-Fetch wrapper backed by Rust (bypasses webview CORS). `input` accepts `string` / `URL.t` / `Request`; `init` accepts `RequestInit & ClientOptions` |
| `proxy<'proxyValue>` | `{all?, http?, https?}` — `'proxyValue` is `string` (URL) or `proxyConfig` |
| `proxyConfig` | `{url, basicAuth?, noProxy?}` |
| `basicAuth` | `{username, password}` |
| `clientOptions<'proxyValue>` | `{maxRedirections?, connectTimeout?, proxy?, danger?}` |
| `dangerousSettings` | `{acceptInvalidCerts?, acceptInvalidHostnames?}` |

#### 2.6.2 fetch シグネチャ

```rescript
let fetch: ('input, ~init: 'init=?) => promise<'response>
```

- `'input`: `string` / `URL.t` / `Request` のいずれか。call site で annotate
- `'init`: 標準の `RequestInit` (method / headers / body / ...) と Tauri 拡張 `clientOptions` のマージ。JS object literal (`{"method": "POST", "proxy": {...}}`) を渡すのが実用的
- `'response`: DOM `Response`。`.json()` / `.text()` / `.status` などへのアクセスは call site で annotate するか `Obj.magic`

#### 2.6.3 clientOptions の各フィールド

| Field | Type | 用途 |
|---|---|---|
| `maxRedirections` | `int` (option) | 追従する redirect の上限。0 で disable |
| `connectTimeout` | `int` (option) | 接続タイムアウト（ms） |
| `proxy` | `proxy<'proxyValue>` (option) | 全 / HTTP / HTTPS プロキシ |
| `danger` | `dangerousSettings` (option) | TLS 検証無効化（**off by default**） |

#### 2.6.4 proxy / proxyConfig / basicAuth

- `proxy<'proxyValue>`: スロットごとに `string` (URL) または `proxyConfig` record を受ける
- `proxyConfig`: `url` 必須、`basicAuth` (proxy auth) / `noProxy` (bypass list, comma-separated) は optional
- `basicAuth`: `{username, password}` — `Proxy-Authorization` header に変換される

具体例:

```rescript
// Simple URL proxy
let init = {"proxy": {"all": "http://corp-proxy:8080"}}

// Full ProxyConfig with auth and bypass
let init = {
  "proxy": {
    "https": {
      "url": "http://corp-proxy:8443",
      "basicAuth": {"username": "alice", "password": "s3cret"},
      "noProxy": "localhost,*.internal",
    },
  },
}
```

#### 2.6.5 dangerousSettings

```rescript
let init = {
  "danger": {
    "acceptInvalidCerts": true,
    "acceptInvalidHostnames": true,
  },
}
```

- 「self-signed cert / dev mTLS / staging 環境専用」の用途を強調
- 本番環境では絶対に有効化しない旨を強調

### 2.7 Pitfalls

#### 2.7.1 DOM Web Fetch types are intentionally unbound

upstream の `fetch` は Web `Response` を返すが、`@rescript/core` の DOM 型は完全ではないため `'response` のまま受け流している。`fetch` シグネチャ全体が polymorphic な理由を 2〜3 文で説明し、3 つの実用パターンを示す:

1. **Type annotation**: `let response: 'response = await fetch(...)` で call site の context が型を決める
2. **Obj.magic**: 最小コストで Response メソッドにアクセス
3. **Inline object type**: `Obj.magic` の代わりに `(... : {"json": unit => promise<...>})` のような短い構造型を当てる

#### 2.7.2 `proxy<'proxyValue>` の単一型制約

`proxy<'proxyValue>` は単一の `'proxyValue` 型を持つため、HTTPS だけ `proxyConfig` で HTTP は `string` のような mixed 構成は ReScript 側で型エラーになる。回避するには JS object literal で `{"http": "...", "https": {"url": "..."}}` のように直接書くか、両スロットを同じ型に揃える。

#### 2.7.3 `dangerousSettings` ships disabled

`acceptInvalidCerts` / `acceptInvalidHostnames` は `init.danger` でしか有効化できず、record 未指定なら両方 `false` 扱い。Tauri 側の default が secure であることを強調。

### 2.8 Compatibility 表

| Component | Supported range |
|---|---|
| Upstream `@tauri-apps/plugin-http` | `^2.0.0` (peer) |
| Rust `tauri-plugin-http` | `2.x` |
| `@rescript-tauri/core` | `^0.1.0` (peer) |
| ReScript | `>=12.0.0` |
| `@rescript/core` | `>=1.6.0` |
| OS | Linux / macOS / Windows |

### 2.9 See also

- Source: `packages/plugin-http` (GitHub link)
- Package README: `packages/plugin-http/README.md` (GitHub link)
- Upstream docs: `https://v2.tauri.app/plugin/http-client/`
- Upstream JS reference: `https://v2.tauri.app/reference/javascript/http/`
- (Live demo は **未追加**、CHANGELOG の deferred 通りリンクしない)
- (典型 polymorphic fetch パターンの追加例題があれば後日 cross-ref)

## 3. 周辺ドキュメント更新

### 3.1 `sphinx-docs/user/index.md`

- Phase 2 packages ヘッダ: "eight add-on packages" → "nine add-on packages"
- Phase 2 packages 表に行追加（位置: clipboard-manager の後、schema の前）:
  ```
  | `@rescript-tauri/plugin-http` | HTTP fetch with CORS bypass + proxy / TLS config | [plugin-http](plugin-http.md) |
  ```
- toctree に `plugin-http` を追加（位置: `plugin-clipboard-manager` の後、`schema` の前）

### 3.2 `sphinx-docs/user/installation.md`

- "See the ... guides" cross-ref に plugin-http を追加（最後尾、`schema` の直前）:
  ```
  See the [plugin-fs](plugin-fs.md), [plugin-dialog](plugin-dialog.md),
  [plugin-notification](plugin-notification.md),
  [plugin-shell](plugin-shell.md),
  [plugin-log](plugin-log.md),
  [plugin-os](plugin-os.md),
  [plugin-clipboard-manager](plugin-clipboard-manager.md),
  [plugin-http](plugin-http.md), and
  [schema](schema.md) guides for the matching ReScript / Rust /
  capability setup.
  ```
- `{note}` follow-up note を **全削除**（plugin-http が最後の対象だったため、本作業完了で残ガイドはゼロ）
- 既存の `pnpm add @rescript-tauri/plugin-http` 行はそのまま

## 4. 検証戦略

- `pnpm run check` — `.md` は Biome 対象外、worktree CWD の既知 exclude 問題で全除外（影響なし）
- `pnpm --recursive --workspace-concurrency=1 build` — doc-only だが整合性のため
- `grep -n "plugin-http" sphinx-docs/user/installation.md sphinx-docs/user/index.md` — cross-ref 確認
- `grep -n "follow-up" sphinx-docs/user/installation.md` — note 削除確認
- ローカル sphinx build (`cd sphinx-docs && make html`) — Python 環境がある場合のみ、なければ CI 委譲

## 5. ロールバック条件

- 文体が他ガイドと著しく乖離 → 再起草
- sphinx ビルドが壊れる → 該当箇所を revert
- merge 時に index.md / installation.md で大量 conflict → ユーザーに相談、手動 resolution
