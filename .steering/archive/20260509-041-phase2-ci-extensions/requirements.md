# Requirements: Phase 2 CI extensions

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260509-041 |
| 親プラン | `.steering/20260509-030-phase2-planning/` §D / §E / §F の "CI 拡張" / "release.yml 拡張" / §I "examples-build CI" |
| 関連パッケージ | `@rescript-tauri/schema`, `@rescript-tauri/plugin-fs`, `@rescript-tauri/plugin-dialog` |
| 作成日 | 2026-05-09 |

---

## 1. 背景

A 軸 (steering 036/037/039) で 3 つの Phase 2 examples が main に
マージされた。Phase 2 planning §D / §E / §F の残タスクは:

- 各パッケージ向けの type-level / runtime テスト CI 追加
- `examples-build.yml` の matrix に新規 example を組み込む
- `release.yml` を `schema-v*` / `plugin-fs-v*` / `plugin-dialog-v*`
  タグに対応させ、対応するパッケージを publish する

これらをまとめて B 軸として実装する。

## 2. 目的

- core パッケージの CI と同じ品質ゲート（型レベル signature テスト
  + runtime vitest）を Phase 2 の 3 パッケージに適用する。
- 新規追加 example 3 件 (`plugin-dialog-demo` / `plugin-fs-demo` /
  `ipc-typed-with-schema`) を 3-OS マトリクスでビルド検証する。
- 各パッケージのリリースタグから自動 publish できる release ワーク
  フローを整える。

## 3. スコープ

### Must

#### CI ジョブ追加（6 ファイル）

- `.github/workflows/tests-schema-types.yml`
- `.github/workflows/tests-schema-runtime.yml`
- `.github/workflows/tests-plugin-fs-types.yml`
- `.github/workflows/tests-plugin-fs-runtime.yml`
- `.github/workflows/tests-plugin-dialog-types.yml`
- `.github/workflows/tests-plugin-dialog-runtime.yml`

各ファイルは `tests-core-types.yml` / `tests-core-runtime.yml` を
ベースに、フィルタパスとパッケージフィルタ名を差し替える。

#### `examples-build.yml` 拡張

3 example の "build frontend" + "cargo check" ステップを matrix
ジョブ末尾に追加。

#### `release.yml` 拡張

タグ命名規約:
- `v*` → `@rescript-tauri/core` （既存）
- `schema-v*` → `@rescript-tauri/schema`
- `plugin-fs-v*` → `@rescript-tauri/plugin-fs`
- `plugin-dialog-v*` → `@rescript-tauri/plugin-dialog`

タグ名から publish 対象を判定するステップを追加し、対応する
`packages/<name>/` で `npm publish --provenance --access public` を
実行する。dry_run / NPM_TOKEN 未設定時の skip ロジックは継承。

### Should（余裕があれば）

- schema 用の type-level coverage チェックを doc-comment 内
  `let example` を除外するよう調整する（schema.resi の例文に `let greet`
  が含まれており、現状の単純 grep だと `PUBLIC_COUNT > CHECK_COUNT`
  になり falsely fail する）
- plugin-fs / plugin-dialog の type-level coverage チェックは
  そのまま流用 (`CHECK >= PUBLIC` で OK な状態)
- `compat-rescript-schema-prerelease.yml` の追加 (任意 — Phase 2
  planning §D 末尾の任意項目)

### 非対象（Out of scope）

- `compat-tauri-latest.yml` の 3 パッケージ対応（既存 compat ジョブは
  core 中心に nightly で回っており、別途 follow-up）
- リリース実行そのもの（タグ push は別途、本 steering ではドライ
  ビルドが通る形にするまで）
- README / sphinx-docs への CI バッジ追加

## 4. 受け入れ条件

1. 6 ファイルの新規 CI ワークフローが追加される。
2. `examples-build.yml` の matrix 内で 3 新規 example の frontend
   build + Rust cargo check が走るよう拡張される。
3. `release.yml` がタグ prefix を解釈し、対応するパッケージを publish
   する分岐を持つ。
4. すべての YAML が `actionlint` 相当の妥当性を保つ（手元で
   `python3 -c "import yaml; yaml.safe_load(open(p))"` でパース成功）。
5. `pnpm --recursive build` / `pnpm --recursive test` が引き続き全件
   パスする（CI 設定のみの変更で実行コードに影響しないため）。
6. `tasklist.md` の全タスクが `[x]` の状態で main にマージされる。

## 5. 依存・前提

- 既存 `.github/workflows/tests-core-*.yml` がパターンの正本。
- 直近 main にマージ済み: examples 3 件 (036/037/039), Biome
  (038), test-coverage CI (040)。

## 6. リスク

- **schema の type-coverage 不整合**: schema.resi の doc comment に
  `let greet = ...` が含まれるため、core と同じ単純 grep を使うと
  PUBLIC=5, CHECK=4 で fail する。awk で doc-comment 中の行を除外
  する処理を入れる。
- **release.yml の分岐ロジック誤り**: タグ prefix 判定を誤ると
  別パッケージを publish するリスク。タグ prefix の正規表現を
  bash の case 文で厳密に判定し、未マッチ時は exit 1 する。
- **Tauri Rust ビルドの長時間化**: examples-build matrix に 3 件
  追加で 3-OS × 8 example = 24 cargo check が走る。並列化で抑え、
  必要に応じて compat-tauri-latest 用に nightly に移すことは
  Should スコープで判断。

## 7. 影響範囲

- 追加: `.github/workflows/tests-schema-types.yml`,
  `tests-schema-runtime.yml`, `tests-plugin-fs-types.yml`,
  `tests-plugin-fs-runtime.yml`, `tests-plugin-dialog-types.yml`,
  `tests-plugin-dialog-runtime.yml`
- 更新: `.github/workflows/examples-build.yml`,
  `.github/workflows/release.yml`
- 既存パッケージ・examples・テストには影響なし
