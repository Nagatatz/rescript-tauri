# 要件定義: `@rescript-tauri/plugin-http`

| 項目 | 内容 |
|---|---|
| 開発 ID | `20260509-058-plugin-http` |

## 1. ゴール

`@tauri-apps/plugin-http` v2.5.9 (89 行 / 5 export — 1 関数 + 4 型) の **stable public surface 100%** を独立パッケージとして提供。

## 2. 対象 API

**関数 (1):**
- `fetch(input, ~init=?)` — Web Fetch API のラッパー。`input` は `string | URL | Request`、`init` は `RequestInit & ClientOptions`、戻り値は `Response`。

**型 (4):**
- `proxy` — `{all?, http?, https?}` — `string | proxyConfig` の polymorphic 値
- `proxyConfig` — `{url, basicAuth?: {username, password}, noProxy?}`
- `clientOptions` — `{maxRedirections?, connectTimeout?, proxy?, danger?}`
- `dangerousSettings` — `{acceptInvalidCerts?, acceptInvalidHostnames?}`

## 3. 設計判断

- `fetch` の `input` / `init` / `Response` は Web Fetch API 型。ReScript で完全に型付けすると DOM bindings の大量追加が必要。**polymorphic 'input / 'init / 'response で受け流す**実装にして、呼び出し側で型注釈を付ける形で運用する。
- Tauri 固有の `clientOptions` / `proxy` / `proxyConfig` / `dangerousSettings` は record 型として明示的に公開する。利用者は `init` パラメータに `clientOptions` フィールドを混ぜて渡す（Web RequestInit と spread した object として）。

## 4. 完了条件

- 100% シンボルカバー
- 専用 CI 2 件 + matrix + release.yml
- ドキュメント更新
- monorepo build + test 全件 pass
