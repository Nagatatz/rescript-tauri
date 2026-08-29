# Requirements: sphinx-docs/user/plugin-http.md

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260511-007 |
| パッケージ | `@rescript-tauri/plugin-http` |
| 目的 | エンドユーザー向けの公開ドキュメント (`sphinx-docs/user/plugin-http.md`) を追加し、`installation.md` の follow-up note（最後の未着手ガイド）を解消する |

## 背景

- `packages/plugin-http/` は steering 058 で実装済み (`@tauri-apps/plugin-http` v2.5.9 の stable surface 100% カバー)。README / CHANGELOG / runtime test / types test は揃っている。
- 本日 6 つの新規 user guide が追加された結果、唯一未追加の guide が plugin-http のみとなった。`installation.md` の follow-up note も最後の 1 件を残すのみ。
- plugin-http の特殊性: upstream `fetch` は Web Fetch API ラッパーで、`Request` / `Response` / `RequestInit` などの DOM 型を意図的に bind していない（polymorphic `'input` / `'init` / `'response` で受け流す）。これは他 plugin と本質的に異なるため、ユーザーガイドで明示的に解説する必要がある。
- ja 翻訳 .po は別 sub-steering (`20260511-006-sphinx-docs-ja-translation`) で扱う。本作業では英語版 `.md` のみ追加する。

## 機能要件

1. **公開ドキュメント追加**: `sphinx-docs/user/plugin-http.md` を新規作成
   - Status / Install / Capabilities / Minimal example / Public API / Pitfalls / Compatibility / See also の 8 セクション
   - 既存 `plugin-fs.md` / `plugin-dialog.md` / `plugin-log.md` / `plugin-clipboard-manager.md` の文体・構造に準拠
2. **公開 API カバレッジ**: `PluginHttp.resi` の全シンボルを表で網羅
   - 1 関数: `fetch(input, ~init=?)`
   - 5 型: `basicAuth` / `proxyConfig` / `proxy<'proxyValue>` / `dangerousSettings` / `clientOptions<'proxyValue>`
3. **plugin-http 固有事項の明示**
   - **Web Fetch API ラッパーであり、`fetch` 戻り値は polymorphic `'response`** (DOM 型は intentional に非バインド)
   - **CORS bypass**: Rust 側 routing による異なるオリジンへのアクセス可能性
   - polymorphic 型注釈の書き方（`let response: 'response = await Http.fetch(...)` または `Obj.magic`）
   - `proxy<'proxyValue>` の `'proxyValue` 型パラメータの使い分け（`string` vs `proxyConfig`）
   - `dangerousSettings` の名称が "dangerous" な理由（TLS 検証無効化のセキュリティリスク）
4. **Rust 側設定例**
   - `Cargo.toml` への `tauri-plugin-http = "2"` 追加
   - `tauri::Builder` での `.plugin(tauri_plugin_http::init())` 登録
   - allowed URLs の `tauri.conf.json` 設定例（Tauri 2.x の cors permissions）
5. **capability 設定**
   - `http:default` + `http:allow-fetch` 等の permission 例
6. **周辺ドキュメント更新**
   - `sphinx-docs/user/index.md`: "Phase 2 packages" 表に plugin-http 行を追加（最終位置 / schema の直前）、toctree にも追加、ヘッダのパッケージ数を "eight" → "nine" に更新
   - `sphinx-docs/user/installation.md`: "See the ... guides" cross-ref に plugin-http を追加、**follow-up note を全削除**（plugin-http が最後の対象だったため）

## 非機能要件

- `pnpm run check` で Biome 警告が出ないこと（`.md` は Biome 対象外なので影響なし）
- `pnpm --recursive build` が成功すること
- ja 翻訳 .po は更新しない（別 sub-steering）

## Non-goals

- runnable demo (`examples/plugin-http-demo/`) の追加（CHANGELOG の "Deferred to follow-up sub-steerings" に明示済み、別 steering に分離）
- 完全な Web Fetch API バインディング（`Request` / `Response` の型化）— 同じく CHANGELOG で deferred
- ja 翻訳 .po の更新
- plugin-http 自体の API 拡張

## 受け入れ条件

- [ ] `sphinx-docs/user/plugin-http.md` が新規作成され、8 セクションがすべて存在する
- [ ] `index.md` の Phase 2 packages 表と toctree に plugin-http が含まれる、ヘッダ数が "nine" に更新済み
- [ ] `installation.md` の follow-up note が削除されている（最後の未着手 guide が解消されたため）
- [ ] `installation.md` の "See the ... guides" cross-ref に plugin-http が含まれる
- [ ] `pnpm run check` で diff 由来の警告が出ない
- [ ] `pnpm --recursive --workspace-concurrency=1 build` が成功する
- [ ] `grep -n "plugin-http" sphinx-docs/user/installation.md sphinx-docs/user/index.md` で適切な cross-ref が確認できる
