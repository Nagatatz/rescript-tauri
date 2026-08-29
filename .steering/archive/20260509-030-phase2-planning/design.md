# Design: Phase 2 Planning

## 1. パッケージ構造（リポジトリ追加分）

```
packages/
├── core/                  # Phase 1 で完成、API 不変
├── schema/                # Phase 2 中核 (NEW)
│   ├── src/
│   │   └── Schema.res / .resi    # Command.fromSchemas / Channel.fromSchema / Event.fromSchema
│   ├── tests/
│   ├── rescript.json
│   └── package.json       # @rescript-tauri/schema
├── plugin-fs/             # NEW
│   ├── src/
│   │   └── PluginFs.res / .resi
│   ├── tests/
│   ├── rescript.json
│   └── package.json       # @rescript-tauri/plugin-fs
├── plugin-dialog/         # NEW
│   └── ...                # @rescript-tauri/plugin-dialog
├── plugin-opener/         # NEW (Should スコープ)
└── plugin-process/        # NEW (Should スコープ)

examples/
├── (Phase 1 既存 4 example)
├── ipc-typed-with-schema/   # NEW: schema 統合のデモ
├── plugin-fs-demo/          # NEW: plugin-fs デモ
└── plugin-dialog-demo/      # NEW: plugin-dialog デモ
```

`docs/repository-structure.md` を Phase 2 着手時に更新する。

## 2. `@rescript-tauri/schema` API 設計

### 2.1 想定 API

```rescript
// packages/schema/src/Schema.resi
module Command: {
  /** rescript-schema の `S.t<'value>` から Core.decoder を導出する */
  let toDecoder: S.t<'value> => Core.decoder<'value>

  /** rescript-schema 駆動でコマンドを宣言する */
  let fromSchemas: (
    ~name: string,
    ~args: S.t<'args>,
    ~result: S.t<'result>,
  ) => Core.Command.t<'args, 'result>
}

module Channel: {
  let fromSchema: (~message: S.t<'message>) => Core.Channel.t<'message>
}

module Event: {
  let fromSchema: (~name: string, ~payload: S.t<'payload>) => Core.Event.t<'payload>
}
```

### 2.2 実装方針

- `S.t<'value>` (`rescript-schema`) を `Core.decoder<'value> = JSON.t => result<'value, string>` に変換するヘルパを 1 か所にまとめる
- `peerDependencies`: `@rescript-tauri/core ^1.0.0`, `rescript-schema >=...`（バージョン範囲は実装着手時に確定）
- core への依存は API 表面のみ（`Core.Command.make` / `Core.Channel.make` / `Core.Event.make` の **既存シグネチャ** を呼ぶだけ）

### 2.3 RFC-0002

`docs/ideas/RFC-0002-schema-integration.md` を Phase 2 着手前に新規作成し、以下を確定させる:

- `rescript-schema` と `rescript-struct` のどちらを正本とするか（peerDep）
- 両方サポートする場合の API 分離（別 module / 別 sub-package）
- `S.t` から `Core.decoder` への変換時のエラーメッセージ表現
- `S.parseAnyOrThrow` 等の例外スタイルとの統合方法

## 3. プラグインバインディング設計

### 3.1 共通テンプレート

各プラグインは Phase 1 core と同じ規約で作る:

```
packages/plugin-<name>/
├── src/
│   └── Plugin<PascalName>.res / .resi   # 1 モジュール 1 ファイル、PascalCase
├── tests/
│   ├── plugin_<name>_signature.res      # 型レベル網羅
│   └── runtime/                         # vitest（Mocks 経由）
├── rescript.json
├── package.json
└── README.md
```

### 3.2 `peerDependencies` パターン

```json
{
  "peerDependencies": {
    "@rescript-tauri/core": "^1.0.0",
    "@tauri-apps/plugin-<name>": "^2.0.0",
    "rescript": ">=12.0.0",
    "@rescript/core": ">=1.6.0"
  }
}
```

`@tauri-apps/plugin-*` は **upstream の minor を狭く追従**（`^2.0.0`）。
`@rescript-tauri/core` への依存は `peerDependencies` で `^1.0.0` を指定（独立 semver、core の minor で plugin が壊れにくい）。

### 3.3 plugin-fs / plugin-dialog の API 範囲

**`plugin-fs`:**
- `readTextFile` / `writeTextFile` / `readFile` / `writeFile` / `exists` / `remove` / `rename` / `mkdir` / `readDir` / `stat` / `lstat` / `truncate` / `copyFile` 等 upstream 全公開関数
- 関連型: `BaseDirectory`（`@rescript-tauri/core` の `Path.BaseDirectory` を再利用するか、独立 enum を持つかは plugin-fs 着手時に決定）
- watch 系（`watch`, `watchImmediate`）は callback 設計が複雑なため別 sub-module で扱う

**`plugin-dialog`:**
- `open_` / `save` / `message` / `ask` / `confirm`
- options 型は polymorphic variant + record で型安全に
- multiple-selection / directory-selection の戻り値型は variant で表現

### 3.4 互換マトリクス公開

各 plugin の README に以下マトリクスを必須掲載:

| `@rescript-tauri/plugin-fs` | `@tauri-apps/plugin-fs` | `@rescript-tauri/core` |
|---|---|---|
| `^0.1.0` | `^2.5.0` | `^1.0.0` |

## 4. CI 戦略

### 4.1 既存 9 workflow の影響

- `build-core.yml`: 影響なし（core 不変）
- `tests-core-types.yml`: 影響なし
- `tests-core-runtime.yml`: 影響なし
- `examples-build.yml`: 新規 example （schema / plugin-fs / plugin-dialog デモ）を追加
- `compat-tauri-latest.yml` / `compat-rescript-prerelease.yml`: 各 plugin パッケージにも同種ジョブを追加するか、本ファイル内 matrix に追加するかは plugin 着手時に決定
- `release.yml`: tag のフォーマットを `v0.1.0` (core) と `schema-v0.1.0` / `plugin-fs-v0.1.0` 等に分け、各タグでパッケージ別 publish を起動できるようにする

### 4.2 新規 workflow

- `tests-schema-types.yml` / `tests-schema-runtime.yml`: schema 専用
- `tests-plugin-<name>.yml`: 各 plugin 専用、または共通 matrix で
- `compat-rescript-schema-prerelease.yml`: rescript-schema の prerelease 追従

実装着手時に「ジョブ細分化 vs matrix 統合」を決める。

## 5. リリース戦略

### 5.1 タグ命名規約

```
v0.1.0                  # @rescript-tauri/core
schema-v0.1.0           # @rescript-tauri/schema
plugin-fs-v0.1.0        # @rescript-tauri/plugin-fs
plugin-dialog-v0.1.0    # @rescript-tauri/plugin-dialog
```

`release.yml` の publish ステップを `${tag}` のプレフィックスで分岐する。

### 5.2 リリース順

1. RFC-0002 merge
2. `@rescript-tauri/schema` v0.1.0 publish
3. `@rescript-tauri/plugin-fs` v0.1.0 publish
4. `@rescript-tauri/plugin-dialog` v0.1.0 publish
5. (Should スコープ着手判断)
6. `@rescript-tauri/plugin-opener` / `plugin-process` 順次

各 publish 後に `examples/<name>-demo` を CI に追加する。

## 6. ステアリング分割（Phase 2 開始後）

本 steering 030 は「Phase 2 の planning 集約」のみ。実装着手時には以下のサブ steering を逐次作成する:

| 想定 steering | 内容 |
|---|---|
| `2026MMDD-NNN-rfc-0002-schema-integration` | RFC-0002 ドラフト + 確定 |
| `2026MMDD-NNN-schema-package-bootstrap` | `packages/schema/` 雛形作成 + bootstrap CI |
| `2026MMDD-NNN-schema-from-schemas` | `Command.fromSchemas` 実装 |
| `2026MMDD-NNN-plugin-fs-bootstrap` | `packages/plugin-fs/` 雛形 |
| `2026MMDD-NNN-plugin-fs-impl` | バインディング本体 |
| `2026MMDD-NNN-plugin-dialog-bootstrap` | 雛形 |
| `2026MMDD-NNN-plugin-dialog-impl` | バインディング本体 |
| `2026MMDD-NNN-mocks-extension` | Mocks 拡張（mockEvents / mockChannel / mockConvertFileSrc） |
| `2026MMDD-NNN-test-mocks-migration` | 残 4 テストの Mocks 化 |
| `2026MMDD-NNN-prd-open-questions-resolve` | PRD §10 #5 確定 + Window/setSize 厳格化 |
| `2026MMDD-NNN-phase2-release-cut` | Phase 2 全パッケージリリース |

詳細スコープは各 steering 着手時に最新の状況に合わせて確定する。

## 7. リスクと対策

| リスク | 兆候 | 対策 |
|---|---|---|
| `rescript-schema` の API drift | major / minor の頻繁な変更 | peerDep を狭く（`^x.y`）、prerelease CI で先行検知 |
| upstream `@tauri-apps/plugin-*` の break | minor で API 変更 | 既存 `compat-tauri-latest.yml` の対象に plugin パッケージも含める |
| schema 統合採用率が低い（ユーザーが手書きを継続） | publish 後の DL 数が伸びない | core 単独利用を Phase 1 同様サポート継続。schema は opt-in のまま |
| plugin の数が増えてメンテ負荷が爆発 | issue 滞留 / 互換マトリクス更新漏れ | Should スコープ以降は dependabot / renovate 自動化、優先順を四半期見直し |
| Window/setSize 厳格化のユーザー影響 | フィードバックで「破壊変更が困る」 | pre-`v1.0.0` のうちに完了、`v1.0.0` 以降は破壊変更しない約束 |

## 8. Phase 3 への布石（参考）

Phase 3 は本 planning のスコープ外だが、Phase 2 で意識すべき将来要素:

- 次期 ReScript メジャー（v13 想定）対応
- core を `v2.0.0` に bump する判断基準（実利用数 / 互換ブレ）
- governance 文書整備（CONTRIBUTING.md 詳細化、co-maintainer 募集）
- `quality-measurement.md` で計測した Phase 1 / Phase 2 の指標反映

これらは Phase 2 リリース後に別 steering で改めて planning する。
