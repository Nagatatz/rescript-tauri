# plugin-http-demo

Tauri 2.x desktop example exercising
[`@rescript-tauri/plugin-http`](../../packages/plugin-http)
against the public JSONPlaceholder mock REST API.

## Status

Phase 2 — shipped (added 2026-05-11 via steering 009). The
frontend ReScript piece builds with
`pnpm --filter plugin-http-demo build`; the Rust side requires
the Tauri toolchain (`pnpm tauri dev` from this directory). The
example is included in the `examples-build` CI matrix and is
exercised on Linux / macOS / Windows on every PR.

## Run locally

```bash
cd examples/plugin-http-demo
pnpm install
pnpm tauri dev
```

The window needs network access to
`https://jsonplaceholder.typicode.com/*`. The
`http:default` capability in
`src-tauri/capabilities/default.json` is intentionally scoped to
that single origin.

## What it does

Four buttons drive `PluginHttp.fetch` against JSONPlaceholder.
Each step uses an inline structural type to access the
polymorphic `'response` (status, json / text, headers) — see the
[plugin-http user guide](../../sphinx-docs/user/plugin-http.md)
for the broader idiom catalogue.

| Step | Button id | APIs exercised | Notes |
|---|---|---|---|
| 1 — GET | `btn-get` | `fetch(url)` + `response.status` + `response.json()` | Fetches `users/1`, prints `status` + `user.name` |
| 2 — POST | `btn-post` | `fetch(url, ~init={method, headers, body})` | POSTs a JSON body to `posts`, prints the server-assigned `id` |
| 3 — clientOptions | `btn-client-options` | `~init={connectTimeout, maxRedirections}` | Demonstrates the Tauri-specific `clientOptions` extension fields |
| 4 — headers / status / text | `btn-headers` | `response.headers.get(...)` + `response.text()` | Prints the response status, `content-type`, and a 60-character body preview |

## Why JSONPlaceholder

[JSONPlaceholder](https://jsonplaceholder.typicode.com/) is a
free public mock REST API — no API keys, no auth, returns stable
test data over HTTPS. The single-origin allow-list in
`capabilities/default.json` keeps the example reproducible and
makes it obvious how to swap in your own host.

## Capability tightening for production

The demo uses a scoped allow-list:

```json
{
  "permissions": [
    "core:default",
    {
      "identifier": "http:default",
      "allow": [{"url": "https://jsonplaceholder.typicode.com/*"}]
    }
  ]
}
```

For real apps, enumerate every host the app talks to under
`allow`. Avoid `**` (matches every URL) outside of local
development.

## See also

- Package source:
  [`packages/plugin-http`](../../packages/plugin-http)
- User guide:
  [`sphinx-docs/user/plugin-http.md`](../../sphinx-docs/user/plugin-http.md)
- Upstream Tauri docs:
  [Tauri 2.x http plugin](https://v2.tauri.app/plugin/http-client/)
- Upstream JS reference:
  [http module](https://v2.tauri.app/reference/javascript/http/)
