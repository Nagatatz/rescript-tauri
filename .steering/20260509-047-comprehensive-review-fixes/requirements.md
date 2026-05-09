# 包括レビュー修正 — 要件定義 (requirements.md)

| 項目 | 内容 |
|---|---|
| 開発タイトル | comprehensive-review-fixes |
| 起票日 | 2026-05-09 |
| ステータス | Approved（ユーザー承認済み 2026-05-09） |
| 関連 | 直前のセッションで実施した 3 観点レビュー（リファクタ / セキュリティ / ドキュメント） |

## 1. 目的

3 並列エージェント（code-reviewer / security-reviewer / general-purpose docs review）で抽出された改善余地を、**推奨優先順 (A→B→C→D)** に従って一括解消する。pre-1.0 のため後方互換シムは付けず、必要に応じて破壊的 API 変更も許容する（ユーザー指示）。

## 2. 背景

直前の包括レビューで以下が判明した:

- README / CONTRIBUTING / SECURITY / sphinx index / examples README が "Phase 1 design-only" の表現を残しており、Phase 1+2 merged の実態と乖離している。
- `docs/architecture.md` の peerDep 例示が `@rescript-tauri/core ^1.0.0` と実態 `^0.1.0` でズレ、`§2.13` への dangling reference 等 anchor 不整合がある。
- `docs/migration-to-plugins.md` / `docs/quality-measurement.md` は本リポと無関係なテンプレ残置。
- examples 一覧が 4 例だけ列挙された箇所（README / functional-design / sphinx）と 7 例フル列挙の箇所が混在。
- `.github/workflows/*.template` 2 件で SHA pinning 抜けと shell injection 余地、全 examples で `csp: null`。
- `Window.setBackgroundColor` のみ `Nullable.t<color>` 非対応で `Webview` / `WebviewWindow` と非対称、`Schema.resi` が内部 RFC URL を See リンクに使用、Tray.close の See リンク誤指定、Webview の `Obj.magic` + `| _ => ()` のサイレント破棄など、API 整合性とドキュメント正確性に複数の軽-中程度の問題。

セキュリティ観点では Critical / High なし、バインディング層に exploitable な脆弱性なし。本ステアリングは「リリース前に表面を磨いておく」位置づけ。

## 3. スコープ

本ステアリングは 4 スコープを同一 worktree で順次完了させる。各スコープは独立したコミット粒度で実装する。

### 3.1 Scope A: Status sweep（最優先）

実装の進捗ステートを反映したテキスト統一。

- [ ] `README.md:19-21` の "Phase 1 — design complete, implementation not yet started / no source code is published yet / PRs not accepted" を「Phase 1+2 merged on main, awaiting first npm publish」に書き換える。
- [ ] `README.md:223` の Contributing 段落を、デザインフェーズ前提の文言から PR 受け入れ前提に更新する。
- [ ] `CONTRIBUTING.md:7-15` で `private` 表記と「PRs not accepted」を削除し、PR 受け入れ可とする。
- [ ] `CONTRIBUTING.md:30-95` の "Future PR workflow (post-Phase 1)" を「PR workflow（現行運用）」として書き直す。
- [ ] `CONTRIBUTING.md:84-91` の CI ゲート列挙に Phase 2 関連 workflow を追加する（`tests-{schema,plugin-fs,plugin-dialog}-types/runtime`、`tests-coverage`、`lint-format`、`docs.yml` 等）。
- [ ] `SECURITY.md:5,32` の "Phase 1 design phase / no published release" 表現を実態に合わせる。
- [ ] `examples/hello-world/README.md` / `plugin-fs-demo/README.md` / `plugin-dialog-demo/README.md` / `ipc-typed-with-schema/README.md` の Status ブロックを「merged, CI matrix にて 3 OS ビルド済み」に揃える。
- [ ] `sphinx-docs/index.md` / `sphinx-docs/dev/contributing.md` 等にデザインフェーズ前提の表現があれば更新する（読み取り段階で発見次第）。

### 3.2 Scope B: docs/ 整合

正本ドキュメントの数値・参照・ステータス整合。

- [ ] `docs/architecture.md:6,143-145` — `Phase 1〜Phase 3 全体` を `Phase 0〜Phase 3 全体` に整合 (PRD §8 と整合)、peerDep 表の `@rescript-tauri/core ^1.0.0` を `^0.1.0` に修正、Phase 2 着手済みを反映。
- [ ] `docs/development-guidelines.md:175` および `sphinx-docs/user/configuration.md:16` の `functional-design.md §2.13` を `§2.8` に修正（または該当節の正しい anchor へ）。
- [ ] `docs/functional-design.md:12` の "(`docs/architecture.md`（後続作成予定）" を削除する。
- [ ] `docs/migration-to-plugins.md` / `docs/quality-measurement.md` を **削除する**（本リポジトリに無関係なテンプレ残置）。`docs/repository-structure.md:64-67` の参照行も削除する。
- [ ] `docs/product-requirements.md:9` のステータス `Draft` → `Confirmed (Phase 1+2 merged, awaiting publish)`、§4 Phase 2 行を Should/Could から実装済みへ移動、§10 残課題 #2/#3 を確定済みに更新、§8 マイルストーン表 Phase 1/2 を `merged` 表示に。
- [ ] `docs/functional-design.md:10` のステータス `Draft` を `Confirmed (Phase 1+2 merged)` に、§8 残課題 #2/#3 を確定済みに、§5.3 / §6 の examples リスト・lint 説明を 7 例 / Biome に修正。
- [ ] `docs/development-guidelines.md` の "Phase 1 で..." future tense 表現を現在形・実装済みに更新。
- [ ] `docs/glossary.md:17-22` の `@rescript-tauri/schema` を「Phase 2 で merged、初版 publish 待ち」相当に更新。
- [ ] `README.md:153` および `docs/functional-design.md:44-48,620` および `sphinx-docs/dev/project-structure.md` の examples 一覧を 7 例フル列挙に揃える。
- [ ] `AGENTS.md` を `CLAUDE.md` の正本ベースに最小同期する（Biome 行など欠落箇所の追加、または役割明示コメントの追記）。
- [ ] 各 `packages/*/CHANGELOG.md` のリポジトリレベル CI 重複バレットは保持（次の publish 前に整理する別ステアリング案件）。本スコープでは触らない。

### 3.3 Scope C: セキュリティ修正

ベストプラクティス強化（実 exploit なし）。

- [ ] `.github/workflows/claude-code-review.yml.template:30,35` — `actions/checkout@v4` と `anthropics/claude-code-action@v1` を本番 workflow と同じ SHA-pinned 形式（`@<sha> # <tag>`）に変更する。
- [ ] `.github/workflows/auto-pr-description.yml.template:28` — `actions/checkout@v4` を SHA-pinned に変更する。
- [ ] `.github/workflows/auto-pr-description.yml.template:42-48` — `${{ github.base_ref }}` / `${{ github.event.pull_request.number }}` を `env:` 経由に分離し、shell では `"$BASE_REF"` / `"$PR_NUM"` のように quote して受ける。
- [ ] `examples/hello-world/src-tauri/tauri.conf.json` に推奨 CSP（`default-src 'self'; img-src 'self' asset: https://asset.localhost; style-src 'self' 'unsafe-inline'`）を設定し、`examples/hello-world/README.md` で「prod アプリでは必ず CSP を設定する」旨をリーダブルにする（他例題は意図的に null のまま、その理由を README に追記してもよい）。
- [ ] `packages/core/src/Core.resi` の `convertFileSrc` doc に「`~protocol` をユーザー入力から組み立てない（asset / stream のみ想定）」旨を 1 文追加。
- [ ] `packages/core/src/Core.resi` の `RustError` バリアント doc に「payload は Rust 例外メッセージを `{name, message}` 化したもの。UI / 外部送信前にサニタイズする」旨を追記。
- [ ] `packages/schema/src/Schema.res` の decoder 経路に「JS native exception を投げない契約」を doc コメントで明示（`Schema.res` 内部 doc 1 行）。

### 3.4 Scope D: API 整合リファクタ

pre-1.0 を活かして破壊的修正を許容。

- [ ] `packages/core/src/Window.resi:584` および対応する `.res:237` を `(t, Nullable.t<color>) => promise<unit>` に変更し、`Webview` / `WebviewWindow` と整合させる。
- [ ] `packages/core/src/Webview.res:42-61` の `onDragDropEvent` 実装を、未知の `kind` 文字列をサイレント破棄せず Console warn でログするよう変更（あるいは ReScript 慣用に従い `unknown` を含む payload は no-op + コメント補強）。
- [ ] `packages/core/src/Webview.resi:141` `onDragDropEvent` の doc comment に「未知タイプは現状 silently ignored」旨を明示する。
- [ ] `packages/schema/src/Schema.resi` の `toDecoder` / `fromSchemas` / `channelFromSchema` / `eventFromSchema` の See リンクを内部 RFC URL から Tauri 公式 URL（`Core.Command` / `Core.Channel` / `Event.make` の対応ページ）へ差し替える。
- [ ] `packages/schema/src/Schema.resi:11-13` の `module Core/Event/S` 公開シグネチャを削除する（実装ファイル `.res:1-3` のスコープ短縮はそのまま）。**破壊変更**: ユーザーが `Schema.Core` 等を直接参照していたら影響を受けるが、想定使用パターンは `Schema.toDecoder` / `Schema.fromSchemas` / `Schema.channelFromSchema` / `Schema.eventFromSchema` 4 関数のみ。
- [ ] `packages/schema/src/Schema.resi` `eventFromSchema` の `~payload` ラベルを `~decode` に変更し、`Event.make` の `~decode` と命名を揃える。**破壊変更**: examples / docs の呼び出し側を併せて修正する。
- [ ] `packages/core/src/Tray.resi:163` `close` の See リンクを `namespacecore/#close` から `namespacetray/#close` に修正。
- [ ] `packages/core/src/App.resi:67` の `setTheme` シグネチャを `(Nullable.t<theme>) => promise<unit>` に変更し、`Window.setTheme` と非対称なラベル付き optional を解消する。**破壊変更**: examples / docs / tests を併せて修正。
- [ ] `packages/core/src/Window.resi:292` の `monitorFromPoint` を `(~x: float, ~y: float) => promise<Nullable.t<monitor>>` に変更し、引数の意味を明示。**破壊変更**: 呼び出し側があれば修正。
- [ ] `packages/plugin-fs/src/PluginFs.resi:56-57` `readFileOptions.encoding` を `[#"utf-8"]` 等の polymorphic variant に変更（または現状維持として doc に「現時点で `"utf-8"` のみ有効」を明記）。upstream `@tauri-apps/plugin-fs` v2.5.0 の docs を確認した上で対応を決める。
- [ ] `packages/core/src/Menu.resi:75-154` `MenuItem` / `CheckMenuItem` / `IconMenuItem` の共通 6 メソッドにつき、各モジュール先頭の doc コメントへ「以下 6 メソッドは 3 種共通インターフェース」と注記。

各破壊変更で影響を受けるファイル（type-level test、runtime test、examples、sphinx-docs、CHANGELOG）も併せて更新する。

## 4. Out of scope

- `packages/*/CHANGELOG.md` のリポジトリレベル CI 重複バレット整理（次の publish 前に別ステアリング）。
- 新規例題の追加・既存例題の機能拡張。
- 新規 plugin パッケージの追加（plugin-shell 等）。
- `Tray` / `Menu` / `Image` / `App` / `Path` の runtime テスト追加（別ステアリングで取り扱う）。
- examples 5/6/7 への CSP 追加（hello-world のみ実施し、残りは README で説明）。

## 5. 完了条件

- 4 スコープ全タスクの `[x]` 化。
- `pnpm install && pnpm --recursive build` がメインリポでも worktree でも成功する。
- `pnpm --recursive test` の全件パス（型レベル + runtime）。
- `pnpm run check` (Biome) の警告ゼロ。
- 各破壊変更が examples / sphinx-docs / docs / tests / CHANGELOG に正しく反映されている。
- マージ後、main で `git worktree list` / `git branch --list 'worktree-*'` / `.claude/worktrees/` がいずれも空。
