# プロダクト要求定義書 (Product Requirements Document)

| 項目 | 内容 |
|---|---|
| プロダクト | `@rescript-tauri/core`（および周辺パッケージ群） |
| バージョン | 0.1（初版） |
| 作成日 | 2026-05-08 |
| 関連 RFC | [RFC-0001 rescript-tauri Core API Design](./ideas/RFC-0001-core-api-design.md) |
| ステータス | Confirmed (all packages merged, awaiting first publish) |

---

## 1. プロダクト概要

### 1.1 名称
**rescript-tauri** — Tauri 2.x 公式 JS SDK (`@tauri-apps/api`) に対する、production-ready な ReScript バインディング群。

### 1.2 プロダクトコンセプト

- **Idiomatic ReScript**: variant / option / result / polymorphic variant を活用し、TypeScript で `unknown` や string-literal union に頼っていた箇所を型安全な ReScript 表現に翻訳する。
- **Faithful to Tauri**: JS API 表面と 1:1 に近い構造を保ち、Tauri 公式ドキュメントがそのまま読み替え可能であること。
- **Layered safety**: IPC 周りは「raw（薄い）」「typed Command（型付き）」「schema 統合（外部パッケージ）」の 3 層を提供し、ユーザーが安全性とエルゴノミクスのトレードオフを選べるようにする。
- **Maintainable monorepo**: `@tauri-apps/plugin-*` の構造をミラーするモノレポで、コア・プラグイン・例題を独立に進化させる。

### 1.3 プロダクトビジョン

ReScript で Tauri デスクトップアプリを書く際、JavaScript / TypeScript と同等以上のフロントエンド体験が得られる世界を作る。Rust バックエンド (`tauri::command`) とのやり取りを、ReScript 側でも variant / result / typed Command として自然に表現でき、`unknown` への手動キャストや `as any` を必要としない。Tauri が新しい API を出した際も、コア層の薄いバインディングが追従し、ユーザーは公式ドキュメントと同じメンタルモデルで開発を継続できる。

### 1.4 目的

- Tauri 2.x の公開 API すべてを ReScript から利用可能にする。
- 既存の ReScript 開発者（`rescript-react`, `@rescript/core`, `rescript-schema` ユーザー）にとって自然なインターフェイスを提供する。
- 過去の ReScript 向けバインディング試み（`tauri-rescript-template`、`rescript-tauri-bolierplate` ほか、コードジェネレータ系を含む）が放棄された原因（メンテナンス停止・Tauri 1.x 時代の遺物）を踏まえ、1〜3 名のメンテナで長期維持できる構造に再構築する。

> 初期リリースのスコープと境界（IPC / Event / Window 等を含む、テンプレートやプラグインスキャフォールドは別パッケージ）は §4 機能要件サマリーおよび §1.5 Non-goals を参照。

### 1.5 Non-goals（明示的に対象外とするもの）

- Rust 側コード生成（`specta` などの責務）。
- プロジェクトスキャフォールド（別途 `create-rescript-tauri` を予定）。
- UI コンポーネントの同梱。
- Tauri IPC プロトコルそのものへの改良提案。

---

## 2. ターゲットユーザー

### 2.1 プライマリーペルソナ: 「ReScript で本気でアプリを書きたい開発者」 — タカハシさん（32歳、フロントエンドエンジニア）

- **属性**: 4 年以上 ReScript / OCaml で実プロダクションコードを書いている。`rescript-react` でフロントエンドを構築する経験が豊富。`rescript-schema` のような decoder ライブラリを日常的に使う。
- **現在の課題**:
  - Tauri 2.x で個人プロダクトをデスクトップアプリ化したいが、ReScript バインディングが存在しないため `external` を毎回手書きしている。
  - IPC 引数・戻り値の整合性を Rust とフロントで二重メンテすることが負担。
  - 過去の community バインディングは Tauri 1.x や旧 `bs-platform` 時代のもので使えない。
- **期待する解決策**:
  - 公式 `@tauri-apps/api` に追従する正式な ReScript バインディング。
  - 型付き `Command` で Rust 側の関数 1 つにつき 1 か所の宣言にまとめたい。
  - 必要に応じて raw `invoke` に降りられる「逃げ道」が欲しい。
  - （Rust 側の型生成は本プロダクトの Non-goal。フロント側の `Command` 宣言の一元化までを本 PRD の責務とし、Rust ↔ フロント間の型の自動同期は `specta` 等と組み合わせる前提。詳細は §1.5。）
- **典型ワークフロー**:
  1. `rescript-react` でフロントを書きながら `Core.Command.make` で IPC コマンドを宣言。
  2. `Event.listen` で Tauri 側のイベント（`closeRequested` 等）を購読。
  3. `Window.getCurrent()` などのクラス API でウィンドウ操作。
  4. ユニットテストでは `Mocks` モジュールで `__TAURI_INTERNALS__` を差し替えて検証。

### 2.2 セカンダリーペルソナ: 「TypeScript からの移住者」 — リーさん（27歳、フロントエンド/TS 出身）

- **属性**: TypeScript で `@tauri-apps/api` を使った経験あり。ReScript は最近触り始めたばかり。
- **現在の課題**:
  - ReScript の型システム（variant, polymorphic variant）に慣れておらず、JS API のメンタルモデルから離れすぎると挫折する。
- **期待する解決策**:
  - 公式 JS API と命名・引数順がほぼ一致しており、TS のコード片を読み替えやすいバインディング。
  - `invoke` を直接呼べる Layer 1 が公開されていて、最初は薄く使い始められること。
  - 公式ドキュメント URL がコメントに付記されていて、つまずいたら原典に戻れること。
- **典型ワークフロー**:
  1. `Core.Raw.invoke("greet", ~args=...)` から始め、徐々に `Core.Command.make` に移行。
  2. polymorphic variant の `[#light | #dark]` を見て「ああ、`'light' | 'dark'` のことか」と理解する。

### 2.3 ターシャリーペルソナ: 「ライブラリメンテナ」 — ナガタさん（プロジェクトオーナー）

- **属性**: ReScript と Rust 両方のエコシステムに関わる OSS メンテナ。コントリビューター 1〜3 名規模を想定。
- **現在の課題**:
  - 過去のバインディング群がメンテナ不在で陳腐化していった原因（Tauri の API drift・ReScript v12 への uncurried-by-default 移行）に再び陥りたくない。
- **期待する解決策**:
  - `.resi` を必須にし、CI で「コンパイル可能な使用例」を継続的に検証する保守可能なリポジトリ構造。
  - 「メンテナ 1 名でも回る」明確な PR 受け入れ規約と CONTRIBUTING.md。
- **典型ワークフロー**:
  1. Tauri が minor バージョン上げた → `peerDependencies` 範囲確認 → 差分追従 PR を出す。
  2. ReScript 12.x 次期マイナー / 次期メジャー prerelease で CI を走らせ、互換性ブレを早期検知。

---

## 3. ユーザーストーリーと受け入れ条件

### Epic 1: IPC（コマンド呼び出し）

#### Story 1-1: 既存の `invoke` 呼び出しを最小コストで ReScript に移植する
**As a** TypeScript 出身の開発者
**I want** `@tauri-apps/api/core` の `invoke` と同じシグネチャで呼べる薄いバインディング
**So that** TS のコードを 1 行ずつ機械的に書き換えていける

**受け入れ条件:**
- `Core.Raw.invoke(name, ~args=?, ~options=?)` が `promise<'result>` を返す。
- `headers` を `options` で渡せる。
- 戻り値の型は呼び出し側が型注釈で指定する（型変数のまま）。
- 公式 JS API と同じ動作（reject 時は `exn` で `await` が throw する）になる。

#### Story 1-2: Rust 側コマンドごとに型付きハンドルを 1 つ宣言する
**As a** ReScript で本気で書きたい開発者
**I want** コマンド名・引数エンコーダ・結果デコーダを 1 か所にまとめた `Command.t<'args, 'result>`
**So that** 各呼び出し地点で型と decoder を書き直さずに済む

**受け入れ条件:**
- `Core.Command.make(~name, ~encodeArgs, ~decodeResult)` が `Command.t<'args, 'result>` を返す。
- `Command.invoke(cmd, args, ~options=?)` は `promise<result<'result, invokeError>>` を返す。
- `invokeError` は `DecodeError(string)` と `RustError(JSON.t)` の 2 ケース。
- `Command.invokeExn` 版（reject に変換）も提供される。
- `encodeArgs` は `'args => JSON.t`、`decodeResult` は `JSON.t => result<'result, string>`。

#### Story 1-3: スキーマ統合は外部パッケージに分離されている
**As a** ライブラリメンテナ
**I want** `@rescript-tauri/core` がいかなる decoder ライブラリにも依存しない
**So that** ユーザーが好きな decoder（`rescript-schema`、`rescript-struct`、自作）を選べる

**受け入れ条件:**
- `core` の `peerDependencies` には decoder ライブラリが含まれない。
- `Command.make` のシグネチャは、後続パッケージ（`@rescript-tauri/schema`）が薄いラッパ層を提供できる十分な汎用性を持つ。

### Epic 2: イベント / Channel

#### Story 2-1: タイプ付き Event ハンドルでイベントを購読する
**As a** ReScript 開発者
**I want** `Event.t<'payload>` 型のハンドルを `make(~name, ~decode)` で宣言し `listen` で購読する
**So that** イベント名・payload 型・decoder の整合をコンパイル時に保証できる

**受け入れ条件:**
- `Event.make(~name, ~decode)` で `Event.t<'payload>` を生成できる。
- `Event.listen`, `Event.once` は `promise<unlisten>` を返す。`unlisten` は `unit => unit`。
- `Event.emit`, `Event.emitTo(~target)` で送信できる。
- `eventTarget` variant は `Any | AnyLabel(string) | App | Window(string) | Webview(string) | WebviewWindow(string)`。

#### Story 2-2: Tauri ビルトインイベント名を定型値として使う
**As a** 開発者
**I want** `Event.TauriEvent.windowCloseRequested` 等の事前定義イベント名定数
**So that** イベント名文字列を間違えず、upstream `TauriEvent` enum の追加変更を型レベルで追跡できる

**受け入れ条件:**
- upstream `@tauri-apps/api/event` の `TauriEvent` enum 16 種すべてが `Event.TauriEvent` モジュールに `tauriEvent` 型の `let` 定数として公開される (`windowResized` / `windowMoved` / `windowCloseRequested` / `windowDestroyed` / `windowFocus` / `windowBlur` / `windowScaleFactorChanged` / `windowThemeChanged` / `windowCreated` / `windowSuspended` / `windowResumed` / `webviewCreated` / `dragEnter` / `dragOver` / `dragDrop` / `dragLeave`)。
- 値は polymorphic-variant 文字列 (`tauriEvent = [#"tauri://resize" | ...]`) なので、`switch` で網羅性チェックが効く。
- 利用形態は **typed handle ではなく文字列定数**: `Event.make(~name=(Event.TauriEvent.windowResized :> string), ~decode=...)` の形で `Event.t<'payload>` を構築する。payload 型 (`PhysicalSize.t` 等) は `Dpi` モジュールで定義され、各イベントごとに呼び出し側が `decode` を指定する。
- upstream で新しい `TauriEvent` 値が追加された場合は `Event.TauriEvent` に追加する（互換性維持）。

#### Story 2-3: Channel を使った Rust → フロントのストリーミング
**As a** 開発者
**I want** `Channel.t<'message>` を `Command.invoke` の引数として渡し、Rust からのメッセージを受け取る
**So that** 単発レスポンスでなくストリームでデータを受け取る用途を ReScript で書ける

**受け入れ条件:**
- `Core.Channel.make(~decode)` で `Channel.t<'message>` を作れる。
- `Channel.onMessage(channel, callback)` でハンドラを登録できる。
- `Channel.id(channel) => int` で内部 ID を取得できる（Rust 側との突合せに使用）。

### Epic 3: クラス系 API（Window / Webview / Menu / Tray など）

#### Story 3-1: Window API を ReScript の opaque type として扱う
**As a** 開発者
**I want** `Window.t` 型と `@send` ベースのメソッド群
**So that** JS クラスベース API をクラスなしの ReScript で自然に呼べる

**受け入れ条件:**
- `Window.t` は opaque（実装隠蔽）。
- 静的: `Window.getCurrent()`, `Window.getAll()`, `Window.getByLabel(string) => promise<Nullable.t<Window.t>>`。
- インスタンスメソッドは `@send` で実装し、`win->Window.setTitle("...")` のように pipe-first で呼べる。
- 必須メソッド: `label`, `setTitle`, `title`, `close`, `destroy`, `show`, `hide`, `minimize`, `maximize`, `unmaximize`, `isMaximized`。
- 加えて、Tauri 2.x の `@tauri-apps/api/window` で公開されている `Window` クラスのインスタンスメソッド・スタティックメソッドを **すべて** 同名でバインドする（`peerDependencies` で固定する `@tauri-apps/api` のバージョン時点）。

#### Story 3-2: WebviewWindow と Window のクラス継承を扱う
**As a** 開発者
**I want** `WebviewWindow.t` を必要に応じて `Window.t` / `Webview.t` として扱える
**So that** JS の prototype chain 由来のメソッド共有を ReScript の型でも表現できる

**受け入れ条件:**
- `WebviewWindow.asWindow: t => Window.t = "%identity"` を提供。
- `WebviewWindow.asWebview: t => Webview.t = "%identity"` を提供。
- 共通メソッドの `@send` 重複定義は最小限に抑える。
- リソース解放（`close`/`destroy`）はユーザー責務であることを `.resi` ドキュメントコメントで明示。

#### Story 3-3: Menu / Tray / Image / Path / App / Dpi の各クラス／関数 API
**As a** 開発者
**I want** Tauri 公式の他モジュールも初期スコープに含めた状態でリリースされる
**So that** リリース時点で raw external を手書きする必要がない

**受け入れ条件:**
- 初版リリース時点で以下 12 モジュールが提供される: `Core`, `Event`, `Window`, `Webview`, `WebviewWindow`, `Path`, `App`, `Dpi`, `Menu`, `Tray`, `Image`, `Mocks`。
- 各モジュールは `.res` + `.resi` のペアで構成される。

### Epic 4: 文字列リテラル Union と Variant

#### Story 4-1: `'light' | 'dark'` 等を polymorphic variant で表現する
**As a** 開発者
**I want** `[#light | #dark]` のような polymorphic variant 型
**So that** ランタイムコスト 0 で型安全な「文字列リテラル風」値を渡せる

**受け入れ条件:**
- 全ての string-literal union は polymorphic variant にマップされる。
- ReScript spelling と JS spelling が異なる場合（`#notAllowed @as("notAllowed")` など）は `@as` で解決。
- 公開 `.resi` では closed bound（`[#light | #dark]`）として宣言される。

### Epic 5: 失敗ハンドリング

#### Story 5-1: result vs exn を意図して使い分けられる
**As a** 開発者
**I want** Layer 1 は `promise<'a>` を返し、Layer 2 は `promise<result<'a, _>>` を返す。さらに `*Exn` 版も用意される
**So that** プロジェクト内のスタイル（Result first / 例外 first）に合わせて選択できる

**受け入れ条件:**
- `Command.invoke` は `promise<result<'a, invokeError>>`。
- `Command.invokeExn` は `promise<'a>`（reject 時に exn）。
- 命名規約は `@rescript/core` に準拠（`*Exn` suffix）。
- エラー型はモジュールごとに分離（`invokeError`, `eventError` など、共通親型は持たない）。

### Epic 6: テストとモック

#### Story 6-1: `__TAURI_INTERNALS__` を差し替えて単体テストを書ける
**As a** 開発者
**I want** `Mocks` モジュールで Tauri ランタイムをスタブ化
**So that** vitest + happy-dom 環境で IPC を差し替えてユニットテストを書ける

**受け入れ条件:**
- `Mocks.mockIPC(handler)`（command 名と JSON 引数を受け取り `promise<JSON.t>` を返す）を提供する。
- `Mocks.mockWindows(~current, ~all=?)` を提供する。
- `Mocks.clearMocks()` を提供する。
- `examples/hello-world` の vitest 単体テストが、`Mocks.mockIPC` で IPC を差し替えた状態で `Core.Command.invoke` の round-trip をパスする（CI で実行）。
- 同テスト内で `clearMocks` 呼び出し後、後続テストでハンドラがリセットされていることを assertion で検証する。

### Epic 7: バージョニング・ドキュメント・配布

#### Story 7-1: `peerDependencies` でバージョン整合を表明
**As a** ライブラリ利用者
**I want** `@rescript-tauri/core` の互換性表が一目で分かる
**So that** Tauri 2.x のどの minor まで安全かを判断できる

**受け入れ条件:**
- `peerDependencies`: `@tauri-apps/api ^2.0.0`, `rescript >=12.0.0`, `@rescript/core >=1.6.0`。
- README に互換マトリクス表を掲載。
- semver は Tauri と独立。

#### Story 7-2: `.resi` がドキュメントの正本
**As a** ユーザー
**I want** すべての公開 API に doc comment と Tauri 公式ドキュメントへのリンクが付いている
**So that** エディタの hover で情報を完結できる

**受け入れ条件:**
- 全 `.res` に対して `.resi` が存在する。
- 各公開バインディングに以下を含む doc comment が付く: 概要 1 行 / Tauri 公式ドキュメント URL / 最小例 / プラットフォーム差分（あれば）。

#### Story 7-3: モノレポで core とプラグインを分離
**As a** メンテナ
**I want** `packages/core`, `packages/plugin-fs`, `packages/plugin-dialog`, ... をそれぞれ独立に publish できる
**So that** プラグインバージョンを Tauri 上流の `@tauri-apps/plugin-*` に追従させやすい

**受け入れ条件:**
- npm scope は `@rescript-tauri`。
- 各プラグインは独立 publish 可能。
- `peerDependencies` で対応する `@tauri-apps/plugin-*` を宣言。

---

## 4. 機能要件サマリー

| 区分 | 機能 | 優先度 | ステータス |
|---|---|---|---|
| IPC | `Core.Raw.invoke` / `convertFileSrc` | Must | merged |
| IPC | `Core.Command.make` / `invoke` / `invokeExn` | Must | merged |
| IPC | `Core.Channel` | Must | merged |
| Event | `Event.make` / `listen` / `once` / `emit` / `emitTo` | Must | merged |
| Event | `Event.TauriEvent.*`（upstream `TauriEvent` enum 16 種を `tauriEvent` 文字列定数として公開） | Must | merged |
| Window | `Window` クラスバインディング | Must | merged |
| Webview | `Webview` / `WebviewWindow` クラスバインディング | Must | merged |
| Util | `Path`, `App`, `Dpi`, `Image` | Must | merged |
| UI | `Menu`, `Tray` | Must | merged |
| Test | `Mocks` モジュール | Must | merged |
| Schema | `@rescript-tauri/schema`（外部パッケージ） | Must | merged |
| Plugin | `plugin-fs` / `plugin-dialog` / `plugin-shell` / `plugin-notification` / `plugin-log` / `plugin-os` / `plugin-clipboard-manager` / `plugin-http` | Must | merged |

---

## 5. 非機能要件

### 5.1 互換性

- **Tauri**: `@tauri-apps/api ^2.0.0` を初期サポート。1.x は対象外。
- **ReScript**: `>=12.0.0`（uncurried-by-default, namespace, JSX v4 想定）。次期マイナー / 次期メジャー prerelease を CI で並走確認。
- **`@rescript/core`**: `>=1.6.0`（`JSON.t`, `Dict.t`, `Nullable.t` を前提。1.6.0+ の peerDep `rescript >=11.1.0` が ReScript 12.x もカバーする最低版）。Belt のみのユーザー向けシムは当面提供しない（§10 で確定予定）。
- **OS**: Linux / macOS / Windows いずれでも examples がビルドできる。

### 5.2 パフォーマンス

- バインディング層が JS API 呼び出しに対して **追加のランタイムオーバーヘッドを発生させない**。
  - polymorphic variant は string にコンパイルされる（コスト 0）。
  - `%identity` キャストは JS 上 no-op。
  - `Command.invoke` の余計な allocation は 1 関数呼び出し程度の `result<>` ラッピングのみ許容。
- ビルド時間（クリーンビルド、`packages/core` 単体）:
  - 開発者マシン (Apple M1, 16GB RAM 以上): **5 秒以内**。
  - CI (`ubuntu-latest`, 4 vCPU): **30 秒以内**。
- ビルド時間（インクリメンタル、1 ファイル変更時）: **1 秒以内**。
- 計測コマンド: `time pnpm --filter @rescript-tauri/core build`。CI では計測値をジョブログに出力する。

### 5.3 メンテナビリティ

- `.resi` を必須化することで public API 表面を狭く管理する。
- `tests/` 配下に「コンパイルできれば pass」の使用例ファイルを置き、API 後方互換性を CI で検出する。
- `examples/*` のビルドを CI のリリースゲートとする。
- 1〜3 名のメンテナ規模で 3 年以上維持できる構造を目標とする。

### 5.4 信頼性 / 品質

- ユニットテスト: `vitest + happy-dom`、`window.__TAURI_INTERNALS__` をモックして以下を検証
  - `invoke` が期待通りの JS-level 呼び出しを発火する。
  - `Event.listen` が登録／解除されている。
  - `encodeArgs` / `decodeResult` の round-trip 一貫性。
- 統合テスト: `examples/hello-world` 他を Linux / macOS / Windows で CI ビルド。失敗時はリリース不可。
- 型レベルテスト:
  - `packages/core/tests/*.res` のコンパイル成功を CI 必須条件にする。
  - `.resi` で公開された全シンボル（`let` / `module` / `type`）の **100%** を `tests/` 配下から少なくとも 1 度参照する。
  - CI に grep ベースのカバレッジチェックジョブを追加し、未参照シンボルを検出した場合 fail する。
- 行 / 分岐 / 関数カバレッジ（しきい値ゲート確定）:
  - 全公開パッケージ（`core` / `plugin-fs` / `plugin-dialog` / `schema`）の vitest ランタイムテストに対して `@vitest/coverage-v8` で計測し、CI ジョブ `tests-coverage` で Job summary と artifact（LCOV / HTML、30 日保持）として可視化する。
  - 上記「`.resi` 公開シンボル参照カバレッジ」とは別概念。
  - 各 `vitest.config.mjs` の `coverage.thresholds` で **floor を確定済み**（steering 051 で導入、C/D/E 残カバレッジ補強で更新）:
    - `core`: statements 96 / branches 80 / functions 96 / lines 96
    - `plugin-fs`: 100 / 45 / 100 / 100
    - `plugin-dialog`: 100 / 55 / 100 / 100
    - `schema`: 88 / 45 / 95 / 88
  - floor を下回ると `test:coverage` が exit 非 0 を返し、CI ジョブ `tests-coverage` が fail する。floor を引き上げるときはこの表と `vitest.config.mjs` を同時更新する。

### 5.5 ドキュメント

- 全 `.res` に対し `.resi` 必須。
- 各公開エクスポートに doc comment（要約・Tauri 公式 URL・例・プラットフォーム注記）。
- README 階層: ルート / `packages/core/README.md` / 各 `examples/*/README.md`。
- 互換マトリクスは README に必須掲載。

### 5.6 ライセンス・配布

- **MIT License** を採用（RFC-0001 推奨）。
- npm scope `@rescript-tauri` を予約済みにする（リリース前提条件）。
- 各パッケージは独立 semver。

### 5.7 セキュリティ

- バインディング層自体は信頼境界を導入しない（IPC 引数値の検証は decoder 層／Rust 側責務）。
- `Mocks` モジュールは production ビルドで利用可能だが、ドキュメントでテスト用途であることを明示。

---

## 6. 設計上の重要トレードオフと採用方針

| 論点 | 採用 | 却下案 |
|---|---|---|
| IPC API の階層化 | 3 層（Raw / Command / Schema） | 単一 typed `invoke<'a, 'b>`（型変数自由 → 安全性ゼロ）／ 強制 schema 統合（依存重い） |
| String-literal union | polymorphic variant | 通常 variant（boilerplate 多い）／文字列定数（型安全性弱） |
| クラス継承表現 | opaque type + `%identity` キャスト | 関数子・first-class module（過剰）／メソッド全コピー（保守困難） |
| エラー設計 | モジュールごと分離型 + `*Exn` 版併設 | 共通 `tauriError` 巨大 union（call site の型が広がりすぎる） |
| JSON 抽象 | `@rescript/core` の `JSON.t` のみ | 自前 JSON 型を導入（学習コスト・依存重複） |
| `unlisten` の表現 | `unit => unit`（JS 表現と一致） | `Subscription` オブジェクト／finalizer による自動解放 |
| Decoder ライブラリ | コアは非依存。別パッケージで統合 | コア同梱（依存ロックイン）／なし（現実的でない） |

---

## 7. 成功指標（KPI / KGI）

| 区分 | 指標 | ターゲット (12 ヶ月後) | 計測元 |
|---|---|---|---|
| 採用 | 月次 npm download 数（`@rescript-tauri/core`） | ≥ 500 / 月 | `npm-stat.com` または `npm Insights` ダッシュボード（月次集計） |
| 採用 | GitHub star 数 | ≥ 200 | GitHub Insights → Community Standards |
| メンテ | Tauri minor リリースから差分追従 PR まで | 中央値 14 日以内 | `gh pr list --search "in:title tauri-bump"` の作成日と上流タグ日付の差分（手動集計） |
| メンテ | `.resi` カバレッジ（公開 API 数 / `.res` モジュール） | 100%（厳守） | CI ジョブ `tests-core-types` のカバレッジ計測ステップ |
| 品質 | CI 緑率（main ブランチ最新 30 コミット） | ≥ 95% | `gh run list --branch main --limit 30` の status 集計 |
| 品質 | examples ビルド失敗が release を blocked にした件数 | 0 件 | リリース判定ジョブ `examples-build` の履歴 |
| エコシステム | プラグインパッケージ数（`@rescript-tauri/plugin-*`） | ≥ 3 | `npm search @rescript-tauri/plugin-` |
| ドキュメント | Tauri 公式 URL リンク漏れ件数 | 0 件 | CI の doc lint（`grep -L 'v2.tauri.app'` を全 `.resi` の公開シンボルに対して実行） |
| コミュニティ | 外部コントリビュータ数 | ≥ 3 | GitHub Insights → Contributors |

副次指標（モニタリングのみ、目標値なし）:

- ReScript Forum / Tauri Discord での言及数。
- `examples/` で「ReScript で書く Tauri アプリ」のチュートリアル記事化数。

---

## 8. リリース計画（マイルストーン）

| マイルストーン | スコープ | 状態 / リリースゲート |
|---|---|---|
| **RFC 確定** | RFC-0001 の Decision checklist 完了 | **完了** — npm scope 予約 / repo URL / license / API 主要署名確定 |
| **初版リリース** | コアバインディング (`Core` / `Event` / `Window` / `Webview` / `WebviewWindow` / `Path` / `App` / `Dpi` / `Menu` / `Tray` / `Image` / `Mocks`) + プラグイン展開 (`@rescript-tauri/schema`, `plugin-fs`, `plugin-dialog`, `plugin-shell`, `plugin-notification`, `plugin-log`, `plugin-os`, `plugin-clipboard-manager`, `plugin-http`) + 対応 examples / sphinx-docs | **merged** — 全パッケージ `.resi` 完備、互換マトリクス公開、CI 全プラットフォーム緑、各パッケージ独立 publish 準備完了、初版 npm publish (`*-v0.1.0`) 待ち |
| **長期運用 / 次期 ReScript メジャー対応**（v13 想定） | コントリビュータ拡充、次期メジャー prerelease 追従、`0.1.x → 1.0.0` 昇格 | 次期メジャー prerelease で CI 緑、governance 文書整備 |

---

## 9. 想定リスクと対策

| リスク | 兆候 | 対策 |
|---|---|---|
| Tauri 2.x の API drift | minor バージョン頻発 | upstream changelog 監視ジョブ（CI weekly）、`peerDependencies` 範囲を狭く |
| メンテナ単独点（bus factor 1） | 長期 issue 滞留 | 早期に co-maintainer 募集、CONTRIBUTING.md 整備、PR レビュー基準明文化 |
| ReScript 12.x 後続マイナー / 次期メジャーの破壊的変更 | API 互換崩れ | nightly prerelease 検証で先行検知（`compat-rescript-prerelease.yml`） |
| 競合バインディング／コードジェネレータが現れる（`tauri-bindgen` 等の再活性化を含む） | 他リポジトリでの実装活動・upstream 復活 | ReScript Forum / Tauri Discord で coordination。本プロダクトはハンドメイド runtime バインディングに専念し、コードジェネレータとは連携しない（採用しない方針） |
| decoder ライブラリ依存問題（コア肥大化） | issue で「`X` を同梱して」の声 | コア非依存ポリシーを README で明文化、`@rescript-tauri/schema` で受ける |

---

## 10. 残課題（RFC からの未解決事項）

| # | 論点 | 暫定方針 | 確定タイミング |
|---|---|---|---|
| 1 | `Tauri.res` の re-export 範囲 | **Core / Event / Window / Webview / WebviewWindow（確定）**（経緯: `.steering/archive/20260509-023-tauri-reexport/`） | **確定済み（2026-05-09）** |
| 2 | `Channel` を `Core` に同梱 vs 独立モジュール化 | **`Core.Channel` サブモジュールとして実装（確定）** | **確定済み（コア設計レビュー時点）** |
| 3 | `invokeExn` 命名（`invokeOrThrow` / `invokeUnsafe` 等） | **`invokeExn` 採用（確定）**（`@rescript/core` 慣習） | **確定済み** |
| 4 | `Event.TauriEvent` の網羅範囲 | **upstream `TauriEvent` enum 16 種を完全カバー（確定）**。typed handle ではなく `tauriEvent` 文字列定数として公開し、payload 型は `Event.make` 呼び出し側で指定する設計に確定 | **確定済み（2026-05-09、`packages/core/src/Event.resi`）** |
| 5 | `Mocks` の独立パッケージ化 | **`@rescript-tauri/core` 同梱を継続（確定）**（経緯: `.steering/archive/20260509-045-mocks-packaging-decision/`） | **確定済み（2026-05-09）** |
| 6 | Belt-only ユーザー向け shim 提供可否 | 当面提供しない（`@rescript/core` を peerDep 必須にする） | 初版リリース直前 |
| 7 | ReScript v11 サポート | **除外（v12+ のみ）**（経緯: `.steering/archive/20260508-002-rescript-v12-only/`） | **確定済み（2026-05-08）** |

---

## 11. 用語

| 用語 | 説明 |
|---|---|
| **IPC** | Inter-Process Communication。Tauri ではフロント (JS) ↔ バックエンド (Rust) のメッセージング基盤。 |
| **invoke** | フロントから Rust コマンドを呼ぶ Tauri の標準 API。 |
| **Channel** | Tauri 2.0+ の一方向ストリーミング機構。Rust → フロントへ任意タイミングで送信。 |
| **Event** | Tauri の pub/sub。Window/App スコープでブロードキャスト可能。 |
| **opaque type** | ReScript で実装を隠蔽した型。本プロダクトでは JS クラス値を表現するのに用いる。 |
| **polymorphic variant** | ReScript の `[#name]` 構文で表される open variant。文字列にコンパイルされる。 |
| **Layer 1/2/3** | 本 PRD における IPC API の階層名。Raw / typed Command / schema-integrated に対応。 |

---

## 12. 参照

- [RFC-0001 rescript-tauri Core API Design](./ideas/RFC-0001-core-api-design.md)（本 PRD の一次入力）
- Tauri 公式ドキュメント: <https://v2.tauri.app/>
- ReScript: <https://rescript-lang.org/>
- `@rescript/core`: <https://github.com/rescript-lang/rescript-core>
