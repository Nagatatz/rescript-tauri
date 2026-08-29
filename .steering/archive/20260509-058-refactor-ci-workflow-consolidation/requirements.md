# Steering 058: CI ワークフローの集約 (reusable workflow への移行)

## 1. 背景

`.github/workflows/` 配下の plugin / schema 系テストワークフローが大量に重複している。

### 1.1 重複の規模

| ファイル群 | 件数 | 1 ファイル平均 | 合計行数 |
|---|---|---|---|
| `tests-<pkg>-runtime.yml` | 8 | 32 行 | 256 行 |
| `tests-<pkg>-types.yml` | 8 | 52 行 | 416 行 |
| **合計** | **16** | — | **672 行** |

対象パッケージ: `core`* / `plugin-fs` / `plugin-dialog` / `plugin-shell` / `plugin-notification` / `plugin-log` / `plugin-os` / `plugin-clipboard-manager` / `schema`

* `core` は `tests-core-runtime.yml` / `tests-core-types.yml` の 2 つを別途持ち、本リファクタリングの対象に含む。

### 1.2 重複内容

`diff` で確認した結果、各ファイル間の差分は以下のみ:
- `name:` ヘッダ (`tests-<pkg>-runtime` 等)
- `paths:` のパッケージディレクトリ (`packages/<pkg>/**` × 2 箇所)
- `paths:` の self 参照 (`.github/workflows/tests-<pkg>-runtime.yml`)
- `pnpm --filter @rescript-tauri/<pkg>` の name 部分
- types 側のみ: `packages/<pkg>/src/*.resi` と `packages/<pkg>/tests` のパッケージパス

それ以外の構造 (checkout / pnpm setup / node setup / install / public-symbol coverage 検証 Bash) は完全一致。

### 1.3 メンテナンス上のコスト

新しい plugin パッケージを追加するたびに、対応する 2 ファイル (~84 行) を copy-paste しているのが現状。実際 `plugin-clipboard-manager` (steering 057) / `plugin-log` (steering 055) / `plugin-os` (steering 056) はすべて同パターンで copy-paste されている。

## 2. 目的

GitHub Actions の `workflow_call` (再利用 workflow) を導入して上記の重複を解消し、新規 plugin 追加時の copy-paste 行数を 84 行 → ~20 行 (10 行 × 2 wrapper) まで削減する。

## 3. 要求事項

### 3.1 機能要求

| ID | 要求 |
|---|---|
| FR-1 | `.github/workflows/_test-package-runtime.yml` 再利用 workflow を新設する (`workflow_call` トリガー、`package-name` / `package-path` を input) |
| FR-2 | `.github/workflows/_test-package-types.yml` 再利用 workflow を新設する (同 input + public-symbol coverage 検証 Bash を内包) |
| FR-3 | 各 `tests-<pkg>-runtime.yml` を `uses: ./.github/workflows/_test-package-runtime.yml` 呼び出し形式の薄い wrapper (~10 行) に書き換える |
| FR-4 | 各 `tests-<pkg>-types.yml` を同様に薄い wrapper に書き換える |
| FR-5 | path filter は wrapper 側に残す (`workflow_call` は path filter を直接指定できないため) |

### 3.2 非機能要求

| ID | 要求 |
|---|---|
| NFR-1 | CI ジョブの動作が変更前後で等価であること (同じパッケージ変更時に同じジョブが実行される) |
| NFR-2 | 各 wrapper ファイルの行数が ~15 行以下に収まること |
| NFR-3 | `_test-package-runtime.yml` / `_test-package-types.yml` の合計行数が ~120 行以下に収まること (純減 > 400 行) |
| NFR-4 | 既存の action の SHA pin (`actions/checkout@de0fac2...` 等) を維持する |
| NFR-5 | YAML 構文エラーがないこと (ローカルで `yq` などで簡易検証する) |

### 3.3 互換性

CI ファイル名を維持するため、`name:` ヘッダおよびジョブ名はワークフロー単位でユニークなまま保つ。GitHub の Branch Protection rule で「require status check」を設定している場合、status check 名は `<workflow-name> / <job-name>` で識別される。再利用 workflow を呼ぶ場合 status name が `<caller-workflow> / <caller-job> / <called-workflow> / <called-job>` の形式になりうる点に注意 — 本実装では caller 側のジョブ名を識別子として残す方針を採る。

## 4. 受け入れ基準

- [ ] `_test-package-runtime.yml` / `_test-package-types.yml` の 2 ファイルが新設されている
- [ ] 既存の 16 ワークフローがすべて薄い wrapper に書き換わっている (個別ジョブ定義を含まない)
- [ ] `git diff --stat .github/workflows/` で純減が 400 行以上である
- [ ] YAML 構文チェック (`actionlint` / `yq` 等) が成功する
- [ ] `act` または local 検証で wrapper の `uses` 解決が成功することを確認する (push 前のローカル簡易検証)
- [ ] `docs/repository-structure.md` の `.github/workflows/` 説明が現状を反映している

## 5. スコープ外

- `build-core.yml` / `examples-build.yml` / `release.yml` / `docs.yml` / `compat-*.yml` / `lint-format.yml` / `doc-link-lint.yml` / `tests-coverage.yml` の構造変更 (これらは plugin 横断ではないため対象外)
- 新たな CI ジョブの追加
- pnpm / Node.js のバージョン更新
- action の SHA pin の更新

## 6. リスク

| リスク | 対処 |
|---|---|
| `workflow_call` の status check 名変更で Branch Protection が壊れる | wrapper 側でジョブ名を従来と同等にする / リネームの記録を PR 説明に明記 |
| path filter が caller 側にあって reusable 側に伝わらず、想定外のジョブが起動する | path filter は caller (wrapper) に置き、reusable は無条件に動作する設計とする |
| ローカル検証が unit-test レベルでしかできない | PR 上で実 CI ログを確認することを Phase 4 の受け入れ条件に含める |
