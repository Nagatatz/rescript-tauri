# Design: Mocks packaging decision

## 1. 結論

**`Mocks` モジュールは `@rescript-tauri/core` への同梱を継続する。
独立パッケージ化 (`@rescript-tauri/mocks`) は採用しない。**

PRD §10 #5 の暫定方針を **そのまま確定** する形となる。

## 2. 現状把握 (2026-05-09 時点)

### 2.1 コード規模

```
$ wc -l packages/core/src/Mocks.res*
   13 packages/core/src/Mocks.res
   36 packages/core/src/Mocks.resi
```

3 関数のみ:

- `Mocks.mockIPC: ((string, JSON.t) => promise<JSON.t>) => unit`
- `Mocks.mockWindows: (~current: string, ~additional: array<string>=?) => unit`
- `Mocks.clearMocks: unit => unit`

実体は `@tauri-apps/api/mocks` への薄いラッパ
(`packages/core/src/Mocks.res` の各関数が 1〜2 行の external)。

### 2.2 利用状況

3 つの Phase 2 パッケージ **すべて** が core 同梱の Mocks を
runtime テストから import している:

```
packages/schema/tests/runtime/schema.test.mjs:6:
  import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"

packages/plugin-fs/tests/runtime/plugin_fs.test.mjs:5:
  import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"

packages/plugin-dialog/tests/runtime/plugin_dialog.test.mjs:1:
  import * as Mocks from "@rescript-tauri/core/src/Mocks.res.mjs"
```

core 自身の runtime テスト (`packages/core/tests/runtime/`) も
当然 Mocks を使う (Story 6-1 の要件)。

### 2.3 上流 (Tauri JS SDK) の構造

`@tauri-apps/api` は単一 npm package で、`mockIPC` /
`mockWindows` / `clearMocks` は `@tauri-apps/api/mocks`
サブパスエクスポートとして提供される — 独立 npm package では
ない。

## 3. 代替案比較

| 観点 | A. 独立化 (`@rescript-tauri/mocks`) | B. 現状維持 (core 同梱) ✅ |
|---|---|---|
| セマンティック分離 | ◎ "test-only" がパッケージ名で自明 | △ doc-comment と命名で明示 |
| Phase 2 パッケージへの影響 | × 全 3 パッケージに `@rescript-tauri/mocks` を peerDep 追加 / dependencies 追加が必要 | ◎ workspace dep で既に解決済 |
| 上流との対称性 | × `@tauri-apps/api/mocks` は同 npm package | ◎ 同じ構造 |
| リリース運用 | × 独立 README / CHANGELOG / CI workflows / `mocks-v*` タグ / publish が必要 | ◎ 既存 release.yml の `v*` タグに含まれる |
| バンドルサイズ (production 利用者) | △ tree-shake で除外 (現状と同等) | ◎ tree-shake で除外 |
| コード規模に対するオーバーヘッド | × 49 行のコードに対し新規パッケージ管理 | ◎ ゼロ |
| 移行コスト | × 既存 Phase 2 packages 3 件と examples / docs 全てに peerDep 追加 + `@rescript-tauri/mocks` を install するよう案内修正 | ◎ ゼロ |
| 将来の独立化容易性 | — | ◎ peer dep 追加で破壊的変更なく分離可能 |

**B が圧倒的に優位**。A の唯一の利点 (セマンティック分離) は
doc-comment + パッケージ運用ガイドで補完できる。

## 4. 決定の根拠

1. **コード規模が小さすぎる**: 49 行に対し独立パッケージの維持
   コスト (README / CHANGELOG / vitest / lint / CI / publish タグ /
   peer dep 管理) が完全に過剰。
2. **上流との対称性**: `@tauri-apps/api/mocks` 自体が単一 npm
   package のサブパスである。バインディング側もこれを踏襲する
   方が利用者にとって直感的。
3. **既存利用パターンとの整合**: schema / plugin-fs / plugin-dialog
   の 3 パッケージがすでに core 同梱前提で書かれている。独立化は
   全 3 パッケージへの破壊的変更を要する。
4. **production bundle への影響なし**: ESM tree-shake により Mocks
   を import しない production code には Mocks の実体が含まれない。
5. **将来オプションを保持**: 同梱継続を確定しても、後の Phase で
   独立化の十分な理由が出れば移行可能 (peer dep 追加は破壊的変更
   ではない)。

## 5. 再評価のトリガ (将来 Phase で考慮)

将来、以下のいずれかが発生した場合は再評価する:

- Mocks モジュールが現在の 49 行から **大幅に肥大化** する
  (例: 200 行超、Channel / Event の mock を含むスナップショット
  支援機能の追加など)
- Tauri 公式が `@tauri-apps/api/mocks` を独立パッケージに分離した
- production bundle で Mocks を含めたい依存関係的なユースケースが
  発生した (現時点では想定なし)
- core パッケージ自体の semver 安定性のために、test-only サーフェス
  を分離したい強い要望が出た (例: `^1.0.0` 後の breaking change を
  Mocks で抑制したい)

## 6. 影響対応

### 6.1 PRD §10 #5 行更新

```diff
-| 5 | `Mocks` の独立パッケージ化 | 当面 `@rescript-tauri/core` に同梱 | Phase 2 で再評価 |
+| 5 | `Mocks` の独立パッケージ化 | **`@rescript-tauri/core` 同梱を継続（確定）**（経緯: `.steering/20260509-045-mocks-packaging-decision/`） | **確定済み（2026-05-09）** |
```

### 6.2 functional-design.md §10 #5 行更新

PRD と同じ表記に揃える (functional-design は PRD のミラー)。

### 6.3 architecture.md §7.2 (任意)

```diff
 ### 7.2 Mocks 設計

 - `@tauri-apps/api/mocks` の薄いラッパ。
 - handler は `(string, JSON.t) => promise<JSON.t>` に統一（ReScript 流の関数型）。
 - production ビルドでも import 可能（明示的にテスト用と doc に記載）。
+- `@rescript-tauri/core` 同梱を継続する方針が確定済み (PRD §10 #5,
+  steering 045)。独立パッケージ化はしない。
```

### 6.4 `packages/core/src/Mocks.resi` (任意)

ファイル冒頭の doc-comment に方針を追記 — package consumer が
気付きやすい場所。

```diff
 /** Installs an IPC mock handler. ...
+
+    Packaging: this module is intentionally part of
+    `@rescript-tauri/core` and will not be split into a separate
+    `@rescript-tauri/mocks` package — see PRD §10 #5 (confirmed
+    2026-05-09 via steering 045).
```

## 7. 検証手順

1. PRD §10 #5 行が更新され、`grep -n "確定済み" docs/product-requirements.md`
   で 3 件 (#1, #5, #7) ヒットすることを確認
2. functional-design §10 の同行も同期
3. `pnpm --recursive build` / `pnpm --recursive test` で実コードに
   regression が無いこと

## 8. リスクと対応

| リスク | 対応 |
|---|---|
| 将来の方針変更が困難 | §5「再評価のトリガ」を明示しておくことで、後の Phase で再分離するハードルを低く保つ |
| ドキュメント間の不整合 | PRD と functional-design を同一コミットで更新 |
