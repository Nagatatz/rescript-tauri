# 設計書: ドキュメントと実装の乖離修正

| 項目 | 内容 |
|---|---|
| ステアリング番号 | 20260509-056 |
| 関連 | requirements.md |

## 1. 編集対象ファイル一覧

| # | ファイル | 修正種別 | 対応する要件 |
|---|---|---|---|
| 1 | `README.md` | Edit (Quick Start サンプル + publish リスト) | H1, M4 |
| 2 | `docs/functional-design.md` | Edit (Event / Core セクション) | H2, M5, M6, L1 |
| 3 | `docs/product-requirements.md` | Edit (Predefined 関連 + 状態表) | H2, H3 |
| 4 | `docs/repository-structure.md` | Edit (§5, §8, §9) | M1, M2, M3 |
| 5 | `sphinx-docs/user/installation.md` | Edit (plugin-shell 言及追加) | M7 |

新規ファイル作成は行わない。`sphinx-docs/user/plugin-shell.md` は別 steering で正式な内容を作る前提で、`installation.md` に「Coming soon」を 1 行追加する最小対応とする。

## 2. 各修正の詳細設計

### 2.1 H1: `README.md` Event.listen サンプル修正

**Before** (L112):
```rescript
let unlisten = await fileChanged->Event.listen(evt => Console.log(evt.payload))
```

**After**:
```rescript
let unlisten = await fileChanged->Event.listen(result =>
  switch result {
  | Ok(evt) => Console.log(evt.payload)
  | Error(_) => () // ignore decode failures
  }
)
```

(`sphinx-docs/user/quickstart.md:60` と同形にする)

### 2.2 H2 + L1: `Event.Predefined` 参照を実装に追従

`docs/functional-design.md` 内 6 箇所:
- L26 (ツリー図): `# listen / once / emit / Predefined` → `# listen / once / emit / TauriEvent`
- L206-213 (Predefined モジュール仕様): 削除し、代わりに **`TauriEvent` モジュール**として現実装を記述（`Event.resi:43-65` を要約）
- L227 (機能リスト): `Predefined.*` → `TauriEvent.*`
- L435 (Menu Predefined — これは `Predefined(predefinedMenuItemId)` で別物。Menu 用なので **触らない**)
- L589 (テスト表): `Event.Predefined` `tests/event_predefined.res` → `Event.TauriEvent` `tests/event_signature.res` (実在確認)
- L670 (意思決定表): `Event.Predefined の網羅範囲` → `Event.TauriEvent の網羅範囲`、Phase 1 後継続を「現在 16 種を網羅、追加は upstream 追従」に書き換え

`docs/product-requirements.md` 内 4 箇所:
- L144-150 (User Story): `Event.Predefined.closeRequested` → `Event.TauriEvent.windowCloseRequested`、文字列定数として説明し、`Event.make(~name=Event.TauriEvent.windowCloseRequested, ~decode=...)` の形で使うことを明示
- L276 (state table): "Should / Phase 1" → "Done / Phase 1" にし、ラベルを `Event.TauriEvent.*` に統一（16 種すべて）
- L422 (decision table): "Phase 1 リリース後継続" → "Phase 1 完了。upstream `tauri-apps/api` の `TauriEvent` enum に追従して継続更新"

### 2.3 H3: PRD 内部矛盾の解消

H2 で同時に解消（L276 と L422 を同じ方針で書き換え）。

### 2.4 M1: `docs/repository-structure.md §8` workflows 列挙更新

実在 21 ファイルを反映:
```
├── workflows/
│   ├── build-core.yml
│   ├── tests-core-types.yml
│   ├── tests-core-runtime.yml
│   ├── tests-plugin-fs-types.yml
│   ├── tests-plugin-fs-runtime.yml
│   ├── tests-plugin-dialog-types.yml
│   ├── tests-plugin-dialog-runtime.yml
│   ├── tests-plugin-shell-types.yml
│   ├── tests-plugin-shell-runtime.yml
│   ├── tests-schema-types.yml
│   ├── tests-schema-runtime.yml
│   ├── tests-coverage.yml
│   ├── examples-build.yml
│   ├── lint-format.yml
│   ├── doc-link-lint.yml
│   ├── docs.yml
│   ├── compat-tauri-latest.yml
│   ├── compat-rescript-prerelease.yml
│   └── release.yml
```

`*.yml.template` (auto-pr-description / claude-code-review) はテンプレートなので注釈付きで残すか省略。**省略する** 方針（テンプレートはオプトイン機能で本リポジトリでは未使用）。

注釈: "tests-coverage.yml — 5 パッケージ matrix で vitest v8 カバレッジ計測" に修正（4 → 5）。

### 2.5 M2: `docs/repository-structure.md §9` ルートファイル列挙更新

`Section 9` の表に追記:

| ファイル | 役割 |
|---|---|
| `LICENSE` | MIT ライセンス全文 |
| `CONTRIBUTING.md` | コントリビュータ向けガイド |
| `CODE_OF_CONDUCT.md` | 行動規範 |
| `SECURITY.md` | セキュリティポリシー（脆弱性報告先） |
| `AGENTS.md` | エージェント定義集約（Claude Code 以外のエージェントも参照） |
| `Cargo.toml` | ルート Cargo workspace（examples の Rust 側を束ねる） |
| `pnpm-lock.yaml` | pnpm の lockfile（commit 対象） |

ルートレイアウトの ASCII ツリー (Section 1) にも反映する。

### 2.6 M3: `docs/repository-structure.md §5` sphinx-docs 列挙更新

```
sphinx-docs/
├── user/
│   ├── index.md
│   ├── installation.md
│   ├── quickstart.md
│   ├── configuration.md
│   ├── plugin-fs.md
│   ├── plugin-dialog.md
│   ├── schema.md
│   └── changelog.md
├── dev/
│   ├── index.md
│   ├── setup.md
│   ├── building.md
│   ├── architecture.md
│   ├── project-structure.md
│   └── contributing.md
├── locale/ja/                           # 日本語翻訳 (.po)
├── conf.py
└── Makefile
```

### 2.7 M4: README publish 待ちリストに plugin-shell を追加

L19 (現状):
> The `@rescript-tauri/core`, `@rescript-tauri/plugin-fs`, `@rescript-tauri/plugin-dialog`, and `@rescript-tauri/schema` packages are awaiting their first npm publish

→ `plugin-shell` (および 054 でマージされた `plugin-notification`) を含めて再列挙。`plugin-notification` も新規追加済みなので合わせて反映する。

### 2.8 M5: `docs/functional-design.md §2.1 (Core)` の網羅性向上

`Core.resi` の公開メンバ:
- `Raw` (invoke / convertFileSrc) — 既記載
- `invokeError` — 既記載
- `Command` — 既記載
- **未記載**: `isTauri`, `Resource`, `PluginListener`, `addPluginListener`, `permissionState`, `checkPermissions`, `requestPermissions`, `LowLevel`, `Channel`, `decoder` 型エイリアス, `Internal` モジュール (private 扱い、注釈)

§2.1 を以下のサブセクションに整理:
- §2.1.1 Raw (invoke / convertFileSrc) — 既存
- §2.1.2 Command (Layer 2) — 既存
- §2.1.3 Channel (streaming) — 既存
- §2.1.4 **Plugin & Resource** (`Resource` / `PluginListener` / `addPluginListener`) — 新設
- §2.1.5 **Permissions** (`permissionState` / `checkPermissions` / `requestPermissions`) — 新設
- §2.1.6 **Environment & Low-level** (`isTauri` / `LowLevel`) — 新設
- §2.1.7 Internal — 軽く言及

### 2.9 M6: PhysicalSize / PhysicalPosition の出所明示

§2.2 (Event) で `PhysicalSize.t` / `PhysicalPosition.t` を初出する箇所に脚注:
> `PhysicalSize` / `PhysicalPosition` は `Dpi` モジュール（`packages/core/src/Dpi.resi`）で定義される

§2.5 (Path / App / Dpi / Image) の Dpi セクションに型のリストを追加（L1 対応も兼ねる）。

### 2.10 M7: sphinx-docs に plugin-shell 言及追加

`sphinx-docs/user/installation.md` に最小限の追記:
- インストール表（plugin-fs / plugin-dialog / schema が並んでいる箇所）に `@rescript-tauri/plugin-shell` を追加
- 「専用ガイド (`plugin-shell.md`) は後続 sub-steering で追加予定。現状は `packages/plugin-shell/README.md` を参照」と注記

`sphinx-docs/dev/project-structure.md` も plugin-shell が抜けていれば追記。

## 3. 実装順序と粒度

各タスクを単独でコミット可能な単位に分割し、checkpoint を残す。失敗しても直前 commit に戻れる。

| Phase | 内容 | コミット粒度 |
|---|---|---|
| P1 (HIGH) | H1 README サンプル修正 | 1 commit |
| P1 (HIGH) | H2+H3 Event.Predefined → TauriEvent (functional-design + PRD) | 1 commit |
| P2 (MEDIUM) | M1+M2+M3 repository-structure.md 全 3 セクション更新 | 1 commit |
| P2 (MEDIUM) | M4 README publish 待ちリスト | 1 commit |
| P2 (MEDIUM) | M5+M6+L1 functional-design Core / Dpi セクション | 1 commit |
| P2 (MEDIUM) | M7 sphinx-docs plugin-shell 言及追加 | 1 commit |
| P3 | tasklist.md 完了マーク + マージ | 1 commit |

## 4. 検証戦略

各コミット後に最低限:
- `pnpm --recursive build`（doc 編集のみだが、`docs/` 内コードブロック側のミスを早期検出）
- `pnpm run check`（Biome、`.md` は対象外だが念のため全体）

最終マージ直前:
- `git diff main..HEAD --stat` で変更ファイル一覧確認
- `repository-structure.md` の workflows 列挙が `ls .github/workflows/*.yml | wc -l` と一致するかカウント

## 5. ロールバック方針

各コミットが独立しているため、問題が発生したコミットのみ `git revert` で対応可能。`docs/` のみの変更で実装には影響しないので、ビルド失敗のリスクは低い。

## 6. 並列セッションとの調整

- `worktree-plugin-log` (別作業) とのファイル衝突予測:
  - `docs/repository-structure.md` で plugin-log が新規パッケージとして追記される可能性 → マージ時に conflict 発生したら rebase で解消
  - `README.md` の Packages 表に plugin-log が追加される可能性 → 同上
- 衝突しないよう、本 steering ではどちらも plugin-shell 関連と既存 5 パッケージのみ扱う方針を堅持
