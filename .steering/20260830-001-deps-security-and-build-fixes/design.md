# Design: 依存更新・セキュリティアラート解消・並列ビルド競合修正

## D1. `pnpm-workspace.yaml` による直列ビルド

```yaml
# pnpm --recursive build を直列化する。
# 複数 workspace の `rescript build` が同時に依存パッケージ (@rescript/core, @rescript-tauri/core)
# の lib/ 配下 compiler-info を書き換えると
# "Failed to atomically replace compiler-info ... No such file or directory" で散発失敗するため。
workspaceConcurrency: 1
```

- pnpm 11 は `.npmrc` / `package.json` の `pnpm` フィールドを pnpm 設定として読まない（実測: `.npmrc` 版では `pnpm config get workspace-concurrency` が `undefined`）。既存の `allowBuilds` と同じく `pnpm-workspace.yaml` に置く。

- `pnpm --recursive test` も直列化されるが、vitest 自体がプロセス内で並列化するため実行時間への影響は軽微。
- CI は `--filter` 単体実行のため挙動不変。

## D2. 依存更新

| 対象 | 手段 |
|---|---|
| root `package.json` (oxfmt / oxlint / @types/node) | `sed` で range 書き換え → `pnpm install` |
| `packages/*/package.json` (vitest / coverage-v8 / happy-dom / @types/node) | `sed` で 10 ファイル一括書き換え |
| npm transitive (vite / postcss / nanoid / esbuild) | `pnpm update --recursive vite postcss nanoid esbuild` で lock 内の transitive を最新 satisfying version に上げる。上がらない場合は `pnpm.overrides` ではなく `pnpm update --latest` を対象限定で使う |
| cargo | `cargo update -p serde_json -p tauri-plugin-dialog -p tauri-plugin-log`（`--locked` 検証は `cargo check --locked`） |
| pip | `cd sphinx-docs && uv lock --upgrade-package starlette --upgrade-package soupsieve --upgrade-package idna` |

Dependabot は main 上で該当バージョンが満たされると PR を自動 close する。手動 close は行わない。

### D2.1 実装時に判明した事項

- `pnpm update --recursive <name>` は直接依存にしか作用せず、vitest の peer である `vite` は lockfile の既存解決 (7.3.3) が温存される。`pnpm dedupe` / `--fix-lockfile` でも再解決されない。
- pnpm 11 では `package.json` の `pnpm.overrides` は無視される（`pnpm install` が "Already up to date" で lock に `overrides:` が書かれない）。`pnpm-workspace.yaml` の `overrides` に置くと lock に記録される。
- override 追加後も既存 lock の vite 7.3.3 が残るため、`pnpm-lock.yaml` と `node_modules` を削除して `pnpm install` で再生成した。再生成 lock は `pnpm update -r` 後の lock と同内容 + vite 7.3.6 / esbuild 0.28.2 で、`pnpm peers check` は "No peer dependency issues found"。
- cargo はローカル toolchain が無いため、Dependabot PR #46 / #42 の `Cargo.lock` 差分を `git apply` で取り込み、`cargo check --locked` は CI `examples-build.yml` に委ねる。

## D3. `.steering/` アーカイブ

`steering-workflow.md` の判定コマンドで最終コミット日 < 2026-07-31 のものを抽出し `git mv`。`docs/` 側からの `.steering/...` 参照は grep して、存在すれば `archive/` パスに更新する。

## D4. 検証

1. `pnpm install --frozen-lockfile` は lock 更新後に通ること（CI と同条件）
2. `for i in 1 2 3; do pnpm --recursive build; done` が exit 0 / `ERROR:` なし
3. `pnpm --recursive test` / `pnpm run check`
4. `cargo check --locked --workspace`（ローカルに Rust toolchain がある場合。無い場合は CI `examples-build.yml` に委ねる）
5. `cd sphinx-docs && uv sync --locked && uv run sphinx-build -b html . _build/html -W`（uv がある場合）

## テスト方針

設定 / lockfile / ディレクトリ移動のみでソースコード変更を伴わないため、新規ユニットテストは作成しない（`testing.md` 例外）。既存テスト全件 pass と上記 D4 の検証をもって回帰確認とする。
