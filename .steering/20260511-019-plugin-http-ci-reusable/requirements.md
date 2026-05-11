# Requirements: plugin-http CI を reusable workflow に揃える

| 項目 | 内容 |
|---|---|
| ステアリング ID | 20260511-019 |
| 作成日 | 2026-05-11 |
| 起点 | リファクタリング監査 候補 #2（CI workflow 整合性） |

## 背景

`.github/workflows/tests-plugin-*-{types,runtime}.yml` を 16 ファイル走査したところ、**plugin-http の 2 ファイルだけが reusable workflow `_test-package-{types,runtime}.yml` を呼ばずに steps をベタ書き** している。他 7 プラグイン（clipboard-manager / dialog / fs / log / notification / os / shell）はすべて `uses: ./.github/workflows/_test-package-*.yml` で reusable を呼んでいる。

事前監査では「16 ファイル → 1 matrix」という案が出たが、実態としては各プラグインの `paths:` フィルタが PR サイクル時間短縮に効いており、全 matrix 化は逆効果。本ステアリングでは plugin-http の不整合のみを解消する。

### 該当ファイル

- `.github/workflows/tests-plugin-http-types.yml` (53 行、inline)
- `.github/workflows/tests-plugin-http-runtime.yml` (33 行、inline)

### 比較（reusable 呼び出し版の例）

```yaml
# tests-plugin-log-runtime.yml (REUSABLE 版、26 行)
jobs:
  call:
    uses: ./.github/workflows/_test-package-runtime.yml
    with:
      package-name: "@rescript-tauri/plugin-log"
```

## ゴール

- `tests-plugin-http-types.yml` を `_test-package-types.yml` の呼び出しに書き換え
- `tests-plugin-http-runtime.yml` を `_test-package-runtime.yml` の呼び出しに書き換え
- 他 14 ファイルと同等の構造に揃える
- `paths:` フィルタは現状を維持（`packages/plugin-http/**` + `packages/core/**` + `pnpm-lock.yaml` + workflow 自身）

## スコープ

### 含むもの

- 上記 2 ファイルの書き換え
- 書き換え後の YAML 構文検証（ローカルで `actionlint` または `yq`）
- 他 14 plugin workflow との構造一致確認

### 含まないもの

- 全 16 ファイルを 1 matrix に統合（path filter 喪失のため見送り）
- 新規 plugin 追加テンプレ作成（規模が現状で十分小さく、別 steering で検討）
- `_test-package-*.yml` 本体の変更
- CI ロジックの変更（permissions / Node バージョン等）

## 受け入れ基準

- `tests-plugin-http-{types,runtime}.yml` が `uses: ./.github/workflows/_test-package-*.yml` を呼んでいる
- `package-name` と `package-path` (types のみ) input が正しく渡されている
- 行数が他 plugin workflow と同等程度（~25 行）に縮む
- YAML 構文エラーなし
- 既存の path filter 動作（plugin-http の src 変更時のみ起動）が維持される

## 非ゴール / 後続作業

- 16 → 1 matrix 化は path filter trade-off があるため pre-1.0 段階では見送り
- リファクタリング監査 #2 の元の提案（全 matrix 化）は本ステアリングで close とする
