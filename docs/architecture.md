# アーキテクチャ・技術仕様書 (Architecture)

| 項目 | 内容 |
|---|---|
| プロダクト | `@rescript-tauri/core` および周辺パッケージ群 |
| 対象 | Phase 1〜Phase 3 全体 |
| 作成日 | 2026-05-08 |
| 関連 | [PRD](./product-requirements.md), [Functional Design](./functional-design.md), [Repository Structure](./repository-structure.md), [RFC-0001](./ideas/RFC-0001-core-api-design.md) |

> 本書は「**なぜ**この構造を選んだか」「全体としての品質属性をどう実現するか」に焦点を当てる。モジュール別の API 仕様は `functional-design.md`、物理ファイル位置は `repository-structure.md` を参照。

---

## 1. アーキテクチャ概観

### 1.1 全体図

```
┌───────────────────────────────────────────────────────────────┐
│  ユーザーアプリ (ReScript)                                    │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  rescript-react UI / アプリロジック                  │    │
│  └──────────────────────────────────────────────────────┘    │
│                          │                                    │
│  ┌──────────────────────┴───────────────────────────────┐    │
│  │  @rescript-tauri/schema    (Phase 2, optional)       │    │
│  │  └─ Schema-driven Command 構築                       │    │
│  ├──────────────────────────────────────────────────────┤    │
│  │  @rescript-tauri/core      (Phase 1, 必須)          │    │
│  │  ├─ Core (Raw / Command / Channel)                   │    │
│  │  ├─ Event (listen / emit / Predefined)               │    │
│  │  ├─ Window / Webview / WebviewWindow                 │    │
│  │  ├─ Path / App / Dpi / Image                         │    │
│  │  ├─ Menu / Tray                                      │    │
│  │  └─ Mocks (テスト用)                                 │    │
│  ├──────────────────────────────────────────────────────┤    │
│  │  @rescript-tauri/plugin-*  (Phase 2+)                │    │
│  └──────────────────────────────────────────────────────┘    │
│                          │                                    │
│  ┌──────────────────────┴───────────────────────────────┐    │
│  │  @tauri-apps/api  (上流, peerDep ^2.0.0)             │    │
│  └──────────────────────────────────────────────────────┘    │
│                          │                                    │
│              ===== JS / Rust IPC bridge =====                 │
│                          │                                    │
│  ┌──────────────────────┴───────────────────────────────┐    │
│  │  Tauri Rust ランタイム (本プロダクトの責務外)        │    │
│  └──────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────┘
```

### 1.2 主要コンポーネントと依存方向

```
   schema  ──depends on──▶  core  ──peerDeps──▶  @tauri-apps/api
   plugin-* ─depends on──▶  core  ──peerDeps──▶  @tauri-apps/plugin-*
   examples ─depends on──▶  core / plugin-* / schema
   tests    ─depends on──▶  core (型レベル + ランタイム)
```

依存は **下向き一方通行**。`core` から `schema` / `plugin-*` への参照は禁止（循環防止）。

---

## 2. アーキテクチャを支配する設計原則

| # | 原則 | 帰結 |
|---|---|---|
| 1 | **Faithful to Tauri**: JS API 表面と 1:1 に近づける | 公式ドキュメントが読み替え可能。差分追従コストが最小。 |
| 2 | **Idiomatic ReScript**: variant / option / result / polymorphic variant を活用 | 型安全性で TypeScript を上回る箇所を作る。 |
| 3 | **Layered safety**: ユーザーが安全性とエルゴノミクスを選べる | Raw / Command / Schema の 3 層 (§3) |
| 4 | **Zero runtime overhead**: バインディング層は JS 呼び出しに対して追加コストを持たない | polymorphic variant 採用 / `%identity` キャスト / 余計な allocation 不可 |
| 5 | **Maintainable by 1〜3 people**: 長期メンテナビリティ最優先 | `.resi` 必須 / モノレポ独立 publish / nightly 上流追従 CI |
| 6 | **No code generation**: ハンドメイドの runtime バインディングに専念 | `tauri-bindgen` 等のジェネレータと連携しない（PRD §9） |
| 7 | **Core is dependency-free**: コアパッケージは decoder ライブラリに依存しない | スキーマ統合は別パッケージで提供 |

---

## 3. IPC 3 層アーキテクチャ

本プロダクトのアーキテクチャ上もっとも重要な意思決定。

### 3.1 階層

```
┌────────────────────────────────────────────────────────┐
│  Layer 3: Schema-integrated  (@rescript-tauri/schema)  │
│   └─ Command.fromSchemas(~name, ~args, ~result)        │
│       ⇒ rescript-schema / rescript-struct と統合       │
├────────────────────────────────────────────────────────┤
│  Layer 2: Typed Command       (Core.Command)           │
│   └─ make / invoke / invokeExn                         │
│       ⇒ encodeArgs + decodeResult を 1 か所に宣言     │
├────────────────────────────────────────────────────────┤
│  Layer 1: Raw bindings        (Core.Raw)               │
│   └─ invoke / convertFileSrc                           │
│       ⇒ JS API と 1:1。型は呼び出し側責務             │
└────────────────────────────────────────────────────────┘
```

### 3.2 各層の役割と責務境界

| 層 | 責務 | エラー表現 | 提供パッケージ |
|---|---|---|---|
| Layer 1 | 上流 JS への薄いバインド。型変数のまま透過 | `promise<'a>`（reject 時 exn） | `@rescript-tauri/core` |
| Layer 2 | コマンド宣言・encode・decode の集約。型安全な IPC | `promise<result<'a, invokeError>>` + `*Exn` 版 | `@rescript-tauri/core` |
| Layer 3 | Schema からの自動 encoder/decoder 生成 | Layer 2 と同じ | `@rescript-tauri/schema` (別パッケージ) |

**境界条件:**
- Layer 2 → Layer 1 への依存は OK。逆は禁止。
- Layer 3 → Layer 2 のシグネチャに依存。逆は禁止。
- Layer 3 を `core` に組み込まない理由: decoder ライブラリ依存を core に持ち込まないため（原則 7）。

### 3.3 なぜ 3 層なのか（代替案の却下）

| 代替案 | 却下理由 |
|---|---|
| 単一 typed `invoke<'args, 'result>` | 型変数が制約なく自由 → 安全性ゼロ。decoder の置き場所がない。 |
| 強制 schema 統合のみ | 依存重い。schema を選ばないユーザーを排除する。 |
| Effect-based API | ReScript の effect が安定するまで保留（RFC §2.6 alt C）。 |

---

## 4. パッケージ構造とリリース戦略

### 4.1 モノレポ構成

```
packages/
├── core/        # 中核。これだけでアプリは書ける
├── schema/      # 任意。decoder ライブラリ統合
└── plugin-*/    # 各 Tauri plugin に対応
```

**設計判断:**
- 単一パッケージ（`core` に schema / plugin を全部入り）にしない理由: 依存ロックイン回避（plugin 未使用ユーザーが上流 plugin の脆弱性影響を受けない）。
- 各 plugin が独立 publish: 上流 `@tauri-apps/plugin-*` のリリース速度に追従できるよう、`core` と独立した semver で動かす。

### 4.2 バージョニング

| パッケージ | semver 起点 | peerDep |
|---|---|---|
| `@rescript-tauri/core` | Tauri 2.x ↔ ReScript 12+ で 1.x | `@tauri-apps/api ^2.0.0` |
| `@rescript-tauri/plugin-fs` | 上流 `@tauri-apps/plugin-fs` の minor に追従 | `@rescript-tauri/core ^1.0.0`, `@tauri-apps/plugin-fs ^2.0.0` |
| `@rescript-tauri/schema` | 独立 | `@rescript-tauri/core ^1.0.0`, `rescript-schema >=...` |

互換マトリクスは README に必須掲載（PRD Story 7-1）。

### 4.3 Tauri メジャーバンプ時の方針

Tauri 3.x が出た場合:
- `@rescript-tauri/core` も major bump。
- 旧 peer 範囲（`^2.0.0`）はメンテナンスブランチで minor 修正のみ受ける。
- 新規機能追加は新メジャーへ。

---

## 5. クロスカッティング・ポリシー

### 5.1 エラー伝播

```
Rust 例外
   ↓ (上流が JS Promise reject)
Layer 1: promise rejection (await で exn)
   ↓ (Command.invoke が catch)
Layer 2: result<'a, invokeError>
         ├─ DecodeError(string)    : フロント側 decoder 失敗
         └─ RustError(JSON.t)      : Rust 側エラーをそのまま JSON で運ぶ
   ↓ (ユーザーが Result を unwrap、または invokeExn で raise)
ユーザーコード
```

**設計判断:**
- 共通親 `tauriError` union を作らない: 各 call site で関係ないバリアントが型に乗ってしまうのを避けるため。
- `*Exn` 版を併設: 例外スタイルを好むコードベースとも親和性を保つ。
- `RustError` は decode せず `JSON.t` のまま: Rust 側エラー型は自由（Tauri は何でも返せる）なので、ユーザー側で必要に応じて decode する。`RustError(JSON.t)` の実体は捕捉した JS exception を `{name, message}` の JSON object に正規化したもの（非 `Error` 例外の場合のみ "(non-Error exception)" 文字列にフォールバック）。

### 5.1.1 デコード失敗ポリシー（統一）

`@rescript-tauri/core` は **すべての decode 失敗を `result<_, string>` で呼び出し側に surface する**。サイレントドロップは行わない。

| API | デコード失敗時の挙動 |
|---|---|
| `Core.Command.invoke` | 戻り値 `result<_, invokeError>` の `Error(DecodeError(msg))` |
| `Core.Channel.onMessage` | callback に `Error(decoderMessage)` を渡す |
| `Event.listen` / `Event.once` | callback に `Error(decoderMessage)` を渡す |

共通の decoder 型エイリアスを `Core.decoder<'value> = JSON.t => result<'value, string>` として `.resi` で公開し、Command/Channel/Event すべてが同じ型を target にする。Phase 2 の `@rescript-tauri/schema` パッケージはこの `Core.decoder<_>` 型を返す `Command.fromSchemas` ヘルパを提供する。

呼び出し側で silent-drop を選びたい場合は明示的にパターンマッチで `Error` ブランチを破棄する:

```rescript
event->Event.listen(result =>
  switch result {
  | Ok(evt) => Console.log(evt.payload)
  | Error(_) => () // 意図的に無視
  }
)
```

### 5.2 リソース解放

native ハンドル（`Window`, `WebviewWindow`, `Menu`, `TrayIcon`）は **明示解放** が必須。

| 採用案 | 却下案 |
|---|---|
| ユーザーが `close` / `destroy` を明示呼び出し。`.resi` で警告 | Finalizer / WeakRef による自動解放（プラットフォーム差異と信頼性問題） |

### 5.3 JSON 取り扱い

- `JSON.t` (`@rescript/core`) を **唯一** の中間表現とする。
- decoder combinator を core から提供しない。
- 標準の `JSON.Decode.*` を使うか、`@rescript-tauri/schema` 経由で `rescript-schema` と組み合わせる。

### 5.4 String-literal Union

- すべて polymorphic variant + `@as` で表現（ランタイムコスト 0）。
- 公開 `.resi` では closed bound（`[#light | #dark]`）で宣言、Tauri の追加に追従する場合は minor bump。

### 5.5 クラス継承

- `WebviewWindow` のような JS 上の継承関係は `%identity` キャストで表現。
- メソッドコピーは最小限（discoverability 用に頻用メソッドのみ再宣言）。

---

## 6. ビルド・配布アーキテクチャ

### 6.1 ビルドシステム

| 層 | ツール | 用途 |
|---|---|---|
| パッケージ管理 | `pnpm` (workspaces) | モノレポ依存解決 |
| ReScript コンパイラ | `rescript build` | `.res` → `.res.mjs` |
| バンドラー | なし（ESM 出力直接配布） | npm 配布物は ES module |
| テスト | `vitest` + `happy-dom` | ランタイム検証 |
| CI | GitHub Actions | PR / nightly / release |

### 6.2 出力形式

`rescript.json`:
```json
{
  "name": "@rescript-tauri/core",
  "namespace": true,
  "package-specs": [{"module": "esmodule", "in-source": true}],
  "suffix": ".res.mjs"
}
```

- ES module のみ（CJS は配布しない）。
- `namespace: true` で `RescriptTauriCore.Core` のように consumer がアクセス。
- `in-source: true` で `.res.mjs` を `.res` の隣に出力。

### 6.3 CI ジョブ網

詳細は `functional-design.md` §6。要旨:

```
PR トリガ:
  ├─ lint               (フォーマット差分)
  ├─ build-core         (ビルド時間閾値も検証)
  ├─ tests-core-types   (型レベル + 100% カバレッジ grep)
  ├─ tests-core-runtime (vitest)
  ├─ examples-build     (3 OS マトリクス)
  └─ doc-link-lint      (Tauri 公式 URL 必須チェック)

Nightly:
  ├─ compat-tauri-latest        (上流追従)
  └─ compat-rescript-prerelease (12.x 次期マイナー / 次期メジャー先行検知)

Tag push:
  └─ release            (npm publish)
```

---

## 7. テストアーキテクチャ

### 7.1 3 段構え

| 段 | 目的 | 失敗時の意味 |
|---|---|---|
| 型レベル (`packages/core/tests/*.res`) | 公開 API シンボル 100% を参照 | 後方互換性ブレ |
| ランタイム (`packages/core/tests/runtime/`) | encode/decode round-trip, listen/emit, Mocks | 振る舞いの回帰 |
| 統合 (`examples/*` ビルド) | 3 OS でフルビルド | ユーザー体験回帰、リリース不可 |

### 7.2 Mocks 設計

- `@tauri-apps/api/mocks` の薄いラッパ。
- handler は `(string, JSON.t) => promise<JSON.t>` に統一（ReScript 流の関数型）。
- production ビルドでも import 可能（明示的にテスト用と doc に記載）。

---

## 8. アーキテクチャ品質属性の達成手段

| 品質属性 | 主要メカニズム |
|---|---|
| **保守性** | `.resi` 必須 / 型レベル後方互換テスト / 100% シンボル参照カバレッジ |
| **拡張性** | モノレポ独立 publish / `Command.make` の汎用シグネチャで Layer 3 を後付け可能 |
| **互換性** | nightly compat ジョブ / `peerDependencies` 範囲管理 / 互換マトリクス README |
| **性能** | polymorphic variant / `%identity` / `result` ラッピング以外の allocation 禁止 / ビルド時間 CI gate |
| **信頼性** | 3 OS examples ビルド / vitest による Mocks round-trip / リリースゲートでの強制 |
| **セキュリティ** | バインディングは信頼境界を導入しない（IPC 値検証は decoder / Rust 側責務）/ `dependencies` ゼロ（peerDeps のみ）で supply chain 面積を縮小 |

---

## 9. 既知のアーキテクチャリスクと対応

| リスク | 兆候 | 対応 |
|---|---|---|
| Tauri 2.x の API drift | minor バージョン頻発 | upstream changelog 監視（CI weekly） / `peerDependencies` 範囲を狭く |
| ReScript 12.x 後続マイナー / 次期メジャーの破壊的変更 | API 互換崩れ | nightly prerelease 検証で先行検知（`compat-rescript-prerelease.yml`） |
| メンテナ単独点 (bus factor 1) | 長期 issue 滞留 | CONTRIBUTING.md / governance 文書 / co-maintainer 募集 |
| 競合バインディング・コードジェネレータ | 他リポジトリでの実装活動 | ReScript Forum / Tauri Discord で coordination。本プロダクトは hand-written runtime に専念し、コードジェネレータは採用しない（PRD §9） |

---

## 10. 拡張余地（Phase 2 以降）

| 拡張 | 想定パッケージ | 影響範囲 |
|---|---|---|
| Schema 統合 | `@rescript-tauri/schema` | core 不変 |
| 各 Tauri plugin バインディング | `@rescript-tauri/plugin-fs`, `plugin-dialog`, ... | 各々独立 |
| 次期 ReScript メジャー対応（v13 想定） | `core` を major bump | 全モジュール |
| Belt-only ユーザー向け shim | （現状予定なし、PRD §10 残課題 #6） | 別パッケージ想定 |

これら拡張は **core の API 表面を変えずに追加できる** ことを設計時の制約としている。

---

## 11. 参照

- [PRD](./product-requirements.md)
- [Functional Design](./functional-design.md)
- [Repository Structure](./repository-structure.md)
- [Glossary](./glossary.md)
- [RFC-0001](./ideas/RFC-0001-core-api-design.md)
