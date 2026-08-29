# 調査レポート: RFC-0001 と現状 PRD / 設計書の乖離分析

| 項目 | 内容 |
|---|---|
| 作業 ID | 20260508-006 |
| タイトル | rfc-0001-drift-analysis |
| 種別 | 調査タスク（コード変更を伴わない、`steering-workflow.md` の「調査・リサーチタスク」に該当）|
| 起票日 | 2026-05-08 |
| 起票者 | ユーザー指示 |

## 1. 調査の動機とスコープ

### 1.1 動機

bootstrap (commit `7dbf6b1`) 以降、`docs/ideas/RFC-0001-core-api-design.md`（752 行、英語、Draft）は「PRD の一次入力」として配置された一方で、bootstrap 後に下記の正当な意思決定が積み上がった:

- **steering 002**: ReScript v12-only 化（v11 サポート切り捨て）
- **bootstrap 中の決定**: `tauri-bindgen` を採用しない方針（memory に保存）
- **steering 003**: CONTRIBUTING.md 整備
- **steering 004**: sphinx-docs 英日 2 箇国語化
- **steering 005**: CODE_OF_CONDUCT.md / SECURITY.md 整備

これらの決定が **RFC-0001 の元記述と乖離している箇所**が累積している可能性があり、PRD / functional-design / architecture / その他設計書側で**未吸収の乖離が残っていないか**を網羅的に確認するのが本調査の目的。

### 1.2 スコープ

- **対象**: RFC-0001 全章 (Summary / Goals / Non-goals / §1〜§15 / Appendix A) と現状 PRD (`docs/product-requirements.md`) の対応箇所を網羅比較
- **副次対象**: PRD で吸収しきれていない乖離があれば、`docs/functional-design.md` / `docs/architecture.md` / `docs/repository-structure.md` / `docs/glossary.md` の該当箇所も確認
- **対象外**: RFC-0001 自体の改訂判断（`docs/repository-structure.md` §4.1 で RFC は「入力として扱い、確定後は PRD / functional-design / architecture に反映して以後改編しない」と明示）

### 1.3 前提（プロジェクト規約）

`docs/repository-structure.md` §4.1:

> **入力として扱い、確定後は PRD / functional-design / architecture に反映**して以後改編しない。

→ **RFC-0001 は改編しない**。乖離があれば PRD 側で吸収するか、改訂不要とする判断のみ。

---

## 2. セクション別比較表

RFC-0001 の構造順に、現状 PRD/設計書との対応箇所と乖離有無を示す。

| RFC § | RFC の主張 | PRD/設計書での対応 | 乖離 | 判定 |
|---|---|---|---|---|
| Summary | 3 軸 (idiomatic / faithful / maintainable) | PRD §1.2 プロダクトコンセプトで同等 4 軸（+ Layered safety を独立列挙） | なし | ✅ 整合 |
| Goals | 5 項目 | PRD §1.4 で 3 項目に統合（内容は包含） | なし | ✅ 整合 |
| Non-goals | 4 項目 (Rust codegen / scaffolding / UI components / IPC protocol 改良) | PRD §1.5 で同 4 項目を完全踏襲 | なし | ✅ 整合 |
| §1.1 Monorepo structure | `examples/{hello-world, window-management, ipc-typed}` (3 例題) | `repository-structure.md` §3 で 4 例題（+ `streaming-ipc`）。functional-design でも 4 例題前提 | RFC は 3、PRD/設計書は 4 | ✅ 設計書側で拡張済み（RFC §3.4 Channel の worked example として `examples/streaming-ipc` が触れられているため、暗黙的に整合）|
| §1.2 Module naming | `namespace: true` で `RescriptTauriCore.Core` などに、`Tauri.res` で re-export | PRD §10 行 1 で `Tauri.res` re-export 範囲を「コア・Event・Window のみ」と暫定確定 | なし | ✅ PRD §10 で吸収 |
| §1.3 Module list (12 モジュール) | `core, event, window, webview, webviewWindow, path, app, dpi, menu, tray, image, mocks` | PRD §3 Story 3-3 / §10.4 Phase 1 ロードマップで同 12 モジュール | なし | ✅ 整合 |
| §2 IPC 3-layer design | Raw / Command / Schema | PRD §1.2 / §3 Epic 1 / §6 トレードオフ表で同設計 | なし | ✅ 整合 |
| §2.2 Raw bindings | `Raw.invoke(string, ~args, ~options)` | PRD Story 1-1 で同シグネチャ | なし | ✅ 整合 |
| §2.3 Layer 2 Command | `Command.make(~name, ~encodeArgs, ~decodeResult)`、`invoke / invokeExn`、`invokeError = DecodeError(string) \| RustError(JSON.t)` | PRD Story 1-2 で同シグネチャ | なし | ✅ 整合 |
| §2.4 Layer 3 Schema | 別パッケージ (`@rescript-tauri/schema`)、`Command.fromSchemas(~name, ~args, ~result)` | PRD §3 Story 1-3 + §4 で `@rescript-tauri/schema`（Phase 2 / Could）として位置付け | なし | ✅ 整合 |
| §3.1 Event design | `Event.t<'payload>`, `event<'payload>`, `unlisten = unit => unit`, `eventTarget` variant | PRD Story 2-1 で完全同シグネチャ | なし | ✅ 整合 |
| §3.2 Predefined events | 列挙: `closeRequested, focus, blur, scaleFactorChanged, resized, moved, fileDrop` | PRD Story 2-2 で同 7 種を Must としてリスト | なし | ✅ 整合 |
| §3.4 Channel | `Channel.t<'message>`, `Core.Channel` 配置候補も触れる（§11.5 でも open question） | PRD §10 行 2 で「`Core.Channel` サブモジュールとして実装」と確定 | なし | ✅ PRD §10 で吸収 |
| §4.1 Class API pattern | opaque type + `@send` + `@scope` / `@new` | PRD Story 3-1 + §6 トレードオフ表で同パターン | なし | ✅ 整合 |
| §4.2 Inheritance via `%identity` | `WebviewWindow.asWindow / asWebview` | PRD Story 3-2 で完全同シグネチャ | なし | ✅ 整合 |
| §4.3 Object lifetime | `close`/`destroy` ユーザー責務 | PRD Story 3-2 受け入れ条件で `.resi` doc コメント明示要件として記載 | なし | ✅ 整合 |
| §5 Polymorphic variants | `[#light \| #dark]`, `@as` | PRD Story 4-1 + §6 トレードオフ表で同設計 | なし | ✅ 整合 |
| §6 Promises / results / Exn | Layer 1 raw promise / Layer 2 result / `*Exn` 派生命名 | PRD Story 5-1 で同設計、命名規約も `@rescript/core` に準拠 | なし | ✅ 整合 |
| §7 JSON handling | `@rescript/core` の `JSON.t` のみ、独自 JSON 型なし、bundled decoder なし | PRD §6 トレードオフ表 / §5.1 互換性で同方針 | なし | ✅ 整合 |
| §8.1 peerDependencies | `@tauri-apps/api ^2.0.0`, **`rescript >=11.0.0`**, **`@rescript/core >=1.0.0`** | PRD §5.1 で **`rescript >=12.0.0`**, **`@rescript/core >=1.6.0`** | **乖離あり (No.1, No.2)** | ⚠️ 詳細は §3.1 |
| §8.2 互換マトリクス | 表に "ReScript >=11.0" | PRD §5.1 + README で >=12.0 | 同上の派生 | ⚠️ 同上 |
| §8.3 Plugin packages 独立 publish | 各プラグインは独立 semver、対応 `@tauri-apps/plugin-*` を peer dep | PRD Story 7-3 + repository-structure §2.2 で同方針 | なし | ✅ 整合 |
| §9 Documentation conventions | `.resi` 必須、doc comment フォーマット (要約 + Tauri 公式 URL + 例 + プラットフォーム注記)、README 階層 | PRD §5.5 + Story 7-2 + `.claude/rules/code-comments.md` で同方針 | なし | ✅ 整合 |
| §10.1 型レベルテスト | `packages/core/tests/*.res` のコンパイル成功を CI 必須 | PRD §5.4 + functional-design §6 で同方針 | なし | ✅ 整合 |
| §10.2 ランタイムテスト | vitest + happy-dom + `__TAURI_INTERNALS__` mock | PRD §5.4 + Story 6-1 で同方針 | なし | ✅ 整合 |
| §10.3 Examples as integration tests | 3 OS で CI ビルド | PRD §5.4 + functional-design §6 で同方針 | なし | ✅ 整合 |
| §11 Open questions (6 件) | re-export 範囲 / Channel 配置 / `invokeExn` 命名 / `Event.Predefined` 範囲 / Plugin 境界 / Belt shim | PRD §10 残課題表で 5 件吸収（行 1 / 2 / 3 / 4 / 6）、行 5 で `Mocks` 独立化を扱う（RFC §11.5 "Plugin package boundaries" のうち Mocks 部分） | なし | ✅ PRD §10 で吸収 |
| §12 Migration / adoption path | Direct port → Incremental hardening → Full type safety | PRD §2.2 リーペルソナ典型ワークフローで同階段（Raw → Command） | なし | ✅ 整合 |
| §13 Risks (5 件) | Tauri drift / bus factor / **ReScript v12 breaking** / **competing binding (merge if possible)** / **`tauri-bindgen` revives (complementary)** | PRD §9 リスク表で 5 件、ただし v12 / 競合 / `tauri-bindgen` の 3 件で表現が変化 | **乖離あり (No.3, No.4, No.5)** | ⚠️ 詳細は §3.2 / §3.3 / §3.4 |
| §14 Reference: comparison | 4 既存プロジェクト + 本 RFC | PRD §1.4 で「過去のバインディング群が放棄された原因」として概要のみ | なし | ✅ 比較表は RFC に残置、PRD には要約のみで足りる |
| §15 Decision checklist (9 件) | npm scope / repo / license / module naming / Command API / Event.t shape / poly variants / error type / CONTRIBUTING.md | bootstrap で 7 件達成、CONTRIBUTING は steering 003、残 1 件 (npm scope) は Phase 1 リリース直前 | **乖離あり (No.6: npm scope 未予約)** | ⚠️ 詳細は §3.5 |
| Appendix A | First call-site example | README quickstart / sphinx-docs/user/quickstart.md で部分カバー | なし | ✅ サンプルとしての役割を分担 |

---

## 3. 乖離詳細

### 3.1 No.1 / No.2: ReScript および `@rescript/core` バージョン要件

| 項目 | RFC-0001 | 現状 PRD |
|---|---|---|
| RFC §8.1 / §8.2 | `rescript >=11.0.0`, `@rescript/core >=1.0.0`、互換マトリクス "ReScript >=11.0" | PRD §5.1 / Story 7-1: `rescript >=12.0.0` (uncurried-by-default), `@rescript/core >=1.6.0` |

**経緯**: steering 002 (`.steering/20260508-002-rescript-v12-only/`) で v12-only 化を確定。`@rescript/core 1.6.0+` の peerDep `rescript >=11.1.0` が ReScript 12.x もカバーする最低版であることを `npm view` で確認の上、`>=1.6.0` に切り上げ。

**判定**: ✅ **PRD / functional-design / architecture / CLAUDE.md / glossary / README / repository-structure / .github/workflows/README.md** すべてで吸収済み (steering 002 commit `06f7f48`〜`8e6d6ac`)。RFC §8.1 / §8.2 は「歴史的入力」として現状のまま残置。

**追加対応の要否**: なし。PRD §10 行 7 (「ReScript v11 サポート: 除外（v12+ のみ）、確定済み（2026-05-08）」) で意思決定の経緯も記録済み。

---

### 3.2 No.3: `tauri-bindgen` への姿勢

| 項目 | RFC-0001 | 現状 PRD |
|---|---|---|
| RFC §13 リスク行 5 | "Position `rescript-tauri` as the *runtime* layer; `tauri-bindgen` can target it as a *generator*. Complementary, not competing." | PRD §9 リスク行 4: "本プロダクトはハンドメイド runtime バインディングに専念し、コードジェネレータとは連携しない（採用しない方針）" |
| RFC §2.6 Alternative B | "Tools like `tauri-bindgen` or `specta` can generate `Command.t` declarations as their output target. This RFC does not preclude such tooling." | PRD §1.5 / Story 1-2 受け入れ条件: 設計が後続 schema パッケージを許容する旨は維持、`tauri-bindgen` への前向き言及は削除 |

**経緯**: bootstrap 中（前々セッション）にユーザー指示「tauri-bindgenは使わない方針でお願いします」。memory `project_no_tauri_bindgen.md` に保存:

> rescript-tauri 関連ドキュメントで tauri-bindgen を前向きに参照しない（2026-05-08 決定）

**判定**: ✅ **PRD / functional-design / architecture** すべてから前向き言及を削除済み（前々セッション）。`specta` は Rust 側型生成の参考として PRD §1.5 / Story 1-2 注記で残されている（こちらは「Rust 側 codegen は Non-goal」の説明文脈）。

**追加対応の要否**: なし。RFC §13 の "complementary" 表現は歴史的入力として残置、現行ドキュメント (PRD §9) で否定方針が明示されているため矛盾なし。

---

### 3.3 No.4: 競合バインディングへの対応スタンス

| 項目 | RFC-0001 | 現状 PRD |
|---|---|---|
| RFC §13 リスク行 4 | "Coordinate via ReScript Forum and Tauri Discord; **merge if possible**." | PRD §9 リスク行 4: "ReScript Forum / Tauri Discord で coordination" のみ。"merge if possible" を削除し、代わりに「コードジェネレータとは連携しない」旨を追記 |

**経緯**: No.3 と同根。`tauri-bindgen` を含むコードジェネレータとの merge / 連携を否定したため、competing binding 全般への "merge" スタンスも消失。

**判定**: ✅ PRD §9 で coordination 中心に再定義済み。RFC §13 の "merge if possible" 表現は歴史的入力として残置。

**追加対応の要否**: なし。

---

### 3.4 No.5: `tauri-bindgen` 復活シナリオへの対応

| 項目 | RFC-0001 | 現状 PRD |
|---|---|---|
| RFC §13 リスク行 5 | "**`tauri-bindgen` revives and overlaps**" を独立リスクとして列挙、対策は "complementary, not competing" | PRD §9 リスク行 4 に「`tauri-bindgen` 等の再活性化を含む」と統合し、対策は「採用しない方針」 |

**経緯**: 同上。

**判定**: ✅ PRD §9 で吸収（独立行ではなく行 4 に統合）。

**追加対応の要否**: なし。

---

### 3.5 No.6: npm scope 予約

| 項目 | RFC-0001 | 現状 |
|---|---|---|
| RFC §15 Decision checklist 行 1 | "[ ] npm scope `@rescript-tauri` is reserved." | **未対応**（GitHub repo 作成済み・MIT 採用済み・Phase 1 設計確定済みだが、npm scope 予約は未確認）|

**判定**: ⚠️ **RFC で「Phase 0 完了の必須条件」とされている項目が未対応**。

**重要度**: 中。Phase 1 リリース直前で対応すれば問題ないが、現時点で `@rescript-tauri` scope が他者に取得されるリスクを排除するためには早期予約が望ましい。

**追加対応の要否**: 別タスク化を推奨。`@rescript-tauri` の予約状況を `npm view @rescript-tauri/core` または npm registry で確認し、未取得であれば早期に **dummy package を publish して scope を予約** することを検討（OSS で広く採用される手法。例: `@rescript-tauri/core@0.0.0-reserved` を README にリンクなしで publish）。

---

## 4. 設計書側の追加要素（RFC を超える内容）

PRD は RFC のスーパーセットとして、bootstrap 中に以下の追加要素を含めた。これらは「乖離」ではなく「拡張」だが、調査の完全性のため記録する。

| 追加要素 | 配置 | 出典 |
|---|---|---|
| 3 ペルソナ詳細（タカハシ / リー / ナガタ） | PRD §2 | RFC は Goals / Migration で間接的に触れる程度 |
| KPI / 計測元（9 種、ターゲット 12 ヶ月後）| PRD §7 | RFC は KPI に触れず |
| ビルド時間閾値（クリーン 30s / インクリ 1s, 開発機 5s）| PRD §5.2 | RFC §10 は性能要件に触れず |
| 100% シンボルカバレッジ grep ジョブ | PRD §5.4 + functional-design §6 | RFC §10.1 は型レベルテストの存在を触れるが、100% カバレッジ要件は PRD で追加 |
| セキュリティ非機能要件 | PRD §5.7 | RFC §10 は testing のみ、security 言及なし |
| examples 4 種 (`hello-world`, `window-management`, `ipc-typed`, `streaming-ipc`) | repository-structure §3 | RFC §1.1 は 3 例題（streaming-ipc 追加） |
| visibility 切替条件 (private → public) | README §Visibility | RFC は repo visibility に触れず |

これらの拡張は PRD/設計書が SSoT として機能するよう RFC を補強したもので、RFC との矛盾は生まない。

---

## 5. 結論

### 5.1 主要結論

**RFC-0001 と現状 PRD/設計書の乖離は、すべて bootstrap 後の正当な意思決定の結果であり、PRD/設計書側で吸収済み**。RFC を「歴史的入力として改編しない」方針 (`docs/repository-structure.md` §4.1) と整合し、PRD 改訂を要する箇所は **なし**。

### 5.2 唯一の未対応項目

RFC §15 Decision checklist 行 1: **`@rescript-tauri` npm scope の予約**。Phase 1 リリース直前で対応すれば技術的問題はないが、scope を他者に取得されるリスクがあるため早期予約が望ましい。

### 5.3 RFC が果たしている役割

bootstrap 段階で RFC は以下の役割を果たしている:

- **設計判断の根拠保管庫**: PRD §6 トレードオフ表 / §10 残課題表に記録された判断の根拠を、RFC §2.6 / §3.3 / §4 / §11 に詳細形式で残している。
- **新規参加者の onboarding**: PRD のサマリ表現を RFC で深く理解できる構造。
- **将来の design audit**: 「なぜ A ではなく B を選んだか」の議論ログ。

これらは「歴史的入力」として残し続ける価値が高い。

### 5.4 推奨アクション

| 優先度 | アクション | 推奨タイミング |
|---|---|---|
| 中 | npm scope `@rescript-tauri` の状況確認 + 未取得なら予約 | 別タスク（軽量、`npm view` 確認 → 必要なら dummy publish）|
| 低 | RFC ヘッダー (Status: Draft / Author: TBD) の明示変更は不要 | 「歴史的入力、改編しない」方針通り、現状のまま |
| 低 | RFC §15 Decision checklist の現状ステータスを PRD §10 に新たな行として追記 | 現状のままでも整合性は崩れていないため、必須ではない |

---

## 6. 副次成果物

本調査では設計書間の整合性を網羅確認した結果、以下も確認できた:

- `docs/functional-design.md` の 12 モジュール一覧と RFC §1.3 が完全一致
- `docs/architecture.md` §3 設計原則と RFC §2.5 / §4 / §5 / §6 が一貫
- `docs/repository-structure.md` の 12 モジュール × `.res`/`.resi` ペアと RFC §1.3 / §9.1 が一致
- `docs/glossary.md` の用語定義と RFC で使用される技術語彙が整合
- `CLAUDE.md` の言語要件 (ReScript >=12.0.0) と PRD §5.1 が一致

これらの整合性は steering 002〜005 を通じて維持されてきた結果。
