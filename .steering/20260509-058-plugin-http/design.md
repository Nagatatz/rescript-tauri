# 設計: `@rescript-tauri/plugin-http`

```rescript
type basicAuth = {
  username: string,
  password: string,
}

type proxyConfig = {
  url: string,
  basicAuth?: basicAuth,
  noProxy?: string,
}

// Proxy.all / .http / .https accept either a URL string or a full proxyConfig.
// Use polymorphic 'proxyValue to accept both.
type proxy<'proxyValue> = {
  all?: 'proxyValue,
  http?: 'proxyValue,
  https?: 'proxyValue,
}

type dangerousSettings = {
  acceptInvalidCerts?: bool,
  acceptInvalidHostnames?: bool,
}

type clientOptions<'proxyValue> = {
  maxRedirections?: int,
  connectTimeout?: int,
  proxy?: proxy<'proxyValue>,
  danger?: dangerousSettings,
}

@module("@tauri-apps/plugin-http")
external fetch: ('input, ~init: 'init=?) => promise<'response> = "fetch"
```

`proxy` and `clientOptions` are parameterized on `'proxyValue` so callers can use either `string` (URL only) or `proxyConfig` (full config) without losing type safety.

`fetch` is fully polymorphic (`'input` / `'init` / `'response`). The DOM Fetch API is too large to bind faithfully here; users annotate at the call site.

## テスト
- 型レベル: 4 型 + fetch を `_check_` で参照
- ランタイム: vitest で `globalThis.fetch` を stub し、`PluginHttp.fetch` 経由で呼び出した時に upstream の `fetch` が同じ引数で呼ばれることを確認
