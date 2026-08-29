# 包括レビュー修正 — 設計 (design.md)

## 1. 進行戦略

| 項目 | 内容 |
|---|---|
| 作業形態 | 単一 worktree (`worktree-comprehensive-review-fixes`) で 4 スコープを順次実施 |
| コミット粒度 | 各スコープを 1〜複数の論理コミットに分け、絵文字プレフィックス規約に従う |
| 検証ループ | スコープごとに `pnpm --recursive build` + `pnpm --recursive test` + `pnpm run check` を実行し緑を確認してからコミット |
| 破壊変更の扱い | pre-1.0 のため後方互換 shim は作らない。examples / docs / tests を同一コミットで追従させる |

## 2. Scope A 詳細設計

### 2.1 README.md（ルート）

- L19-21 の Status / Visibility ブロックを以下に置換する想定:
  > **Status:** Phase 1 + Phase 2 implementations are merged on `main`. The `@rescript-tauri/core`, `@rescript-tauri/plugin-fs`, `@rescript-tauri/plugin-dialog`, and `@rescript-tauri/schema` packages are awaiting their first npm publish (`v0.1.0` track). CI matrices, release runbook, and Sphinx docs are in place.
  >
  > **Visibility:** the repository is **public**. The npm version badges above will populate once the first `0.1.0` releases ship.
- L223 の Contributing 段落を「External pull requests are welcome ...」に置換し、「pre-Phase-1」表現を消す。
- L62-71 の "Installation (planned; post Phase 1 release)" セクション見出しを "Installation (pending first npm publish)" 程度に整える。

### 2.2 CONTRIBUTING.md

- §1 Project status を「実装は merged。初回 npm publish 待ち」に書き換え。
- §3 を "Future PR workflow (post-Phase 1)" → "PR workflow"（現行運用）に変更。
- §3.7 CI gates を最新ワークフローと整合させる: `tests-{schema,plugin-fs,plugin-dialog}-types`, `tests-{schema,plugin-fs,plugin-dialog}-runtime`, `tests-coverage`, `lint-format`, `docs`, `compat-tauri-latest` (nightly), `compat-rescript-prerelease` (nightly) を列挙。

### 2.3 SECURITY.md

- L5 を「Phase 1+2 merged。初版 publish までは best-effort timeline」に書き換え。
- L32 の「Phase 1 design phase」フレーズも合わせる。

### 2.4 examples README

- 各 README の "Status" セクションを以下に統一:
  - hello-world: "Status: shipped — Phase 1 baseline; CI matrix で 3 OS ビルド済み"
  - plugin-fs-demo: "Status: shipped — `examples-build` matrix に含まれる"
  - plugin-dialog-demo: "Status: shipped — `examples-build` matrix に含まれる"
  - ipc-typed-with-schema: "Status: shipped — `examples-build` matrix に含まれる"
  - その他既存例（window-management / ipc-typed / streaming-ipc）の Status 欄欠落も追記。

### 2.5 sphinx-docs

- `index.md` / `dev/contributing.md` / `dev/setup.md` の「未着手」「Phase 1 で...」相当を読み取り段階で発見次第更新。

## 3. Scope B 詳細設計

### 3.1 docs/architecture.md

- L6 `対象: Phase 1〜Phase 3 全体` → `対象: Phase 0〜Phase 3 全体`。
- L143-145 の peerDep 例示を `^0.1.0` に修正:
  ```
  | `@rescript-tauri/plugin-fs` | 上流 ... | `@rescript-tauri/core ^0.1.0`, `@tauri-apps/plugin-fs ^2.0.0` |
  | `@rescript-tauri/schema`    | 独立    | `@rescript-tauri/core ^0.1.0`, `rescript-schema ^9.0.0`     |
  ```
- "0.1 → 1.0 の昇格条件" を一段落付け足す（運用方針として）。

### 3.2 dangling anchor 修正

- `docs/development-guidelines.md:175` および `sphinx-docs/user/configuration.md:16` の `§2.13` を、実体（functional-design §2.8 = `Tauri` 上位 re-export）または該当する別節に修正。読み取り時点で正しい節番号を確認。

### 3.3 削除対象ドキュメント

- `docs/migration-to-plugins.md` を `git rm` 削除。
- `docs/quality-measurement.md` を `git rm` 削除。
- `docs/repository-structure.md:64-67` の参照行を削除。
- `CLAUDE.md` / 他 docs から参照があれば削除する（grep で確認）。

### 3.4 PRD ステータス更新

- `docs/product-requirements.md:9` `ステータス: Draft` → `ステータス: Confirmed (Phase 1+2 merged, awaiting publish)`。
- §4 機能要件サマリー Phase 2 行（Schema/Plugin）の「優先度」列を `Should/Could` → `Must (Phase 2 — merged)`。
- §10 残課題 #2 (`Channel` 同梱) を「**確定済み (Phase 1 設計レビュー済 / Core.Channel 採用)**」に。
- §10 残課題 #3 (`invokeExn` 命名) を「**確定済み (`invokeExn` 採用)**」に。
- §10 残課題 #6 (Belt-only shim) は現状維持（提供しない）と現状の文面を維持。
- §8 マイルストーン表 Phase 1 / Phase 2 行を「merged」表記に。

### 3.5 functional-design.md

- L10 `ステータス: Draft` → `Confirmed (Phase 1+2 merged)`。
- L12 「`docs/architecture.md`（後続作成予定）」を「`docs/architecture.md`」に修正。
- §1.1 配置図の `examples/` ブロックに plugin-fs-demo / plugin-dialog-demo / ipc-typed-with-schema を追加。
- §5.3 を 7 例列挙に更新。
- §6 CI 表 `lint` 行を `lint-format` (Biome) として説明し直す。Phase 2 関連 workflow（`tests-{schema,plugin-fs,plugin-dialog}-{types,runtime}`, `docs`）を追加。
- §8 残課題 #2/#3 を確定済みに。

### 3.6 development-guidelines.md / glossary.md

- "Phase 1 で..." 表現を実装済み形に書き換え（`110, 159, 171, 250` 周辺）。
- glossary `@rescript-tauri/schema` 説明を「Phase 2 で merged、初版 publish 待ち」に更新。

### 3.7 examples 一覧整合

- `README.md:153` のレイアウト図コメント `# hello-world / window-management / ipc-typed / streaming-ipc` を 7 例列挙へ。
- `docs/functional-design.md:44-48,620` を 7 例列挙へ。
- `sphinx-docs/dev/project-structure.md` を 7 例列挙へ。

### 3.8 AGENTS.md

- 現状 CLAUDE.md とほぼ同じ内容だが Biome 行が欠落。CLAUDE.md と同期する形で「ビルド・実行コマンド」「常時適用される規約」セクションを揃える（CLAUDE.md と AGENTS.md が双子になるため、長期的には統一を計画するが本ステアリングでは差分解消のみ）。

## 4. Scope C 詳細設計

### 4.1 workflow テンプレ SHA pinning

両テンプレ既存の本番 workflow（`build-core.yml` 等）を grep して、`actions/checkout@<sha> # v<x.y.z>` の **実際に使われている SHA + バージョン表記** をコピーする。本番ワークフローに pinned 値があるはずなので、それを揃える。`anthropics/claude-code-action@v1` も同様に最新の安定 SHA を採用（既存テンプレが `v1` のままならば、claude-code-action のリリースタグ最新を `gh api` で確認して反映）。

> 着手時に `grep -rn "actions/checkout@" .github/workflows/*.yml` で本番 pinning を確認 → そのまま流用する。`anthropics/claude-code-action` は GitHub の Releases API を `gh` で確認する。

### 4.2 shell injection 修正

`auto-pr-description.yml.template` の `Generate description` ステップを以下のように書き換える:

```yaml
- name: Generate description
  env:
    BASE_REF: ${{ github.base_ref }}
    PR_NUM: ${{ github.event.pull_request.number }}
  run: |
    diff_summary=$(git diff "origin/${BASE_REF}...HEAD" --stat | tail -50)
    # ...
    gh pr edit "$PR_NUM" --body "$desc"
```

### 4.3 hello-world CSP

`examples/hello-world/src-tauri/tauri.conf.json` の `"csp": null` を以下に変更:

```jsonc
"csp": "default-src 'self'; img-src 'self' asset: https://asset.localhost; style-src 'self' 'unsafe-inline'; connect-src ipc: http://ipc.localhost"
```

`examples/hello-world/README.md` に "CSP" セクションを 1 段落追加し、prod アプリでは必ず CSP を設定する旨を強調する。他 examples の README には「This example intentionally leaves CSP unset to demonstrate the default behavior; production apps must follow `hello-world` and define an explicit CSP」のクロスリンクを追記しても良い（任意）。

### 4.4 doc-comment 補強

- `Core.resi` `convertFileSrc` doc に追記:
  > **Security**: `~protocol` is intended for the built-in Tauri protocols (`asset`, `stream`); avoid passing user-controlled values to prevent scheme confusion.
- `Core.resi` `RustError` バリアント doc に追記:
  > **Note**: the JSON payload mirrors the captured Rust-side error and may include internal details (paths, SQL fragments, etc.). Sanitize before surfacing in UI or remote telemetry.
- `Schema.res` 先頭または `toDecoder` 直前に内部コメント:
  > Decoders produced here propagate `S.Raised` as `Error(string)`. Schema authors must avoid throwing JS-native exceptions from custom transforms; doing so will bypass the Layer 2 `result` contract and surface as an unhandled rejection in `Channel.onMessage` / `Event.listen`.

## 5. Scope D 詳細設計

### 5.1 Window.setBackgroundColor

- `Window.resi:584`: `let setBackgroundColor: (t, Nullable.t<color>) => promise<unit>` に変更。
- `Window.res:237`: `@send external setBackgroundColor: (t, Nullable.t<color>) => promise<unit> = "setBackgroundColor"` に変更。
- examples / tests から `Window.setBackgroundColor(win, {...})` 呼び出しがあれば `Nullable.make({...})` で wrap。grep で網羅的に確認する。

### 5.2 Webview.onDragDropEvent

- `Webview.res:46-61` を以下のように変更:
  - 未知の `kind` 値のサイレント破棄を避けるため、`Console.warn` で 1 行記録するか、もしくは `Drop` の判定漏れを防ぐ目的で `_` ブランチのみ残すなら `Console.warn` を追加。
  - `Obj.magic(payload["position"])` のキャストはそのまま（型は opaque で API 上の代替なし）。
- `Webview.resi:141` doc comment に "Unknown payload `type` values are currently logged via `Console.warn` and otherwise ignored." を追記。

### 5.3 Schema パッケージ

- `Schema.resi:11-13` の `module Core/Event/S` 行を削除し、シグネチャを 4 関数のみに縮小。
- `Schema.resi:8,21,37,44,50,55` の See リンクを内部 RFC URL から Tauri 公式 URL に差し替え:
  - `toDecoder`: `Core.Command.invoke` の docs（`https://v2.tauri.app/develop/calling-rust/`）。
  - `fromSchemas`: 同上。
  - `channelFromSchema`: `Channel`（`https://v2.tauri.app/develop/calling-rust/#channels`）。
  - `eventFromSchema`: `Event`（`https://v2.tauri.app/develop/calling-frontend/#listening-to-events`）。
- `Schema.resi` `eventFromSchema` のラベルを `~payload` → `~decode` に変更（ただし型は `S.t<'payload>` のまま、Schema コンテキストに合った命名へ。**実体は `Event.make` の `~decode: JSON.t => result<_, string>` ではなく `S.t` だが、ドキュメント上は "schema" の意味を残しつつ `Event.make` 同等の役割であることを明示**するため、命名は `~schema` の方がより正確）。再検討した結果、命名は `~schema` を採用し doc comment に「`Event.make` の `~decode` 役」と明記する。
- `Schema.res` の対応する実装も同期。
- `examples/ipc-typed-with-schema/src/App.res` の呼び出し側を更新。
- `packages/schema/tests/schema_signature.res` の参照も更新。

### 5.4 Tray.close See リンク

- `Tray.resi:163`: `https://v2.tauri.app/reference/javascript/api/namespacecore/#close` → `https://v2.tauri.app/reference/javascript/api/namespacetray/#close`。

### 5.5 App.setTheme

- `App.resi:67` を `let setTheme: Nullable.t<theme> => promise<unit>` に変更。
- `App.res` の対応する `external` を `(Nullable.t<theme>) => promise<unit>` 形に変更。
- examples / tests / sphinx-docs / docs から `App.setTheme(~preferred=...)` 呼び出しを `App.setTheme(Nullable.make(...))` または `App.setTheme(Nullable.null)` に書き換える。

### 5.6 Window.monitorFromPoint

- `Window.resi:292`: `let monitorFromPoint: (~x: float, ~y: float) => promise<Nullable.t<monitor>>`。
- `Window.res:183`: `external monitorFromPoint: (~x: float, ~y: float) => promise<Nullable.t<monitor>> = "monitorFromPoint"`。
- 呼び出し側があれば修正（grep で確認）。

### 5.7 PluginFs encoding

- `packages/plugin-fs/src/PluginFs.resi:56-57` を、現状 `string` のまま残し doc comment に「現時点で `"utf-8"` のみ有効」を明記する **保守的アプローチ** を採用する（poly variant で v2 の追加文字列に追従するメンテコストを避ける）。

### 5.8 Menu 共通 6 メソッド注記

- `Menu.resi` の `MenuItem` / `CheckMenuItem` / `IconMenuItem` 各モジュール先頭の doc コメントへ:
  > The `id` / `text` / `setText` / `isEnabled` / `setEnabled` / `setAccelerator` group is shared verbatim with `MenuItem`, `CheckMenuItem`, and `IconMenuItem`; consult any one for parameter documentation.

## 6. リスク

| リスク | 影響 | 緩和 |
|---|---|---|
| 破壊変更の grep 漏れ | 別 example / sphinx-docs でビルド失敗 | 各破壊変更直後に `pnpm --recursive build` を実行 |
| Scope D の Schema 命名議論 | 利用者向け命名が `~schema` で確定して良いか | design.md でユーザー承認済みの `~payload → ~schema` を採用、再変更コストは pre-1.0 で吸収 |
| upstream `claude-code-action` の安定 SHA 不在 | Scope C の SHA pinning が困難 | 着手時に最新リリースタグ + SHA を `gh api` で確認、見つからない場合は `v1` のまま残し README で警告を強化 |

## 7. テスト方針

各スコープのコミット直前に:

1. `pnpm install` （初回のみ）
2. `pnpm --recursive run clean && pnpm --recursive build`
3. `pnpm --recursive test`
4. `pnpm run check`

すべて緑になるまで次のスコープには進まない。
