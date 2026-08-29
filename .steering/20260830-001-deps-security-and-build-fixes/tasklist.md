# Tasklist: 20260830-001 deps-security-and-build-fixes

## Phase 1: 計画
- [x] ステアリング番号採番 (20260830-001)
- [x] worktree 作成 (`worktree-deps-security-and-build-fixes`)
- [x] requirements.md / design.md / tasklist.md 作成

## Phase 2: 実装
- [x] T1. `pnpm-workspace.yaml` に `workspaceConcurrency: 1` を追加（コメント付き。`.npmrc` は pnpm 11 で無効だったため不採用）
- [x] T2. root / packages/* の `package.json` を R2 のバージョンに更新
- [x] T3. `pnpm install` + `pnpm update` で transitive (vite / postcss / nanoid / esbuild) を patched version 以上へ
- [x] T4. `cargo update -p serde_json -p tauri-plugin-dialog -p tauri-plugin-log`
- [x] T5. `uv lock --upgrade-package starlette/soupsieve/idna`
- [x] T6. `.steering/` 30 日超ディレクトリを `archive/` へ `git mv`（99 件）+ 参照 5 箇所を `archive/` パスへ更新（CONTRIBUTING.md / README.md / examples/plugin-shell-demo/README.md / sphinx-docs/user/configuration.md / sphinx-docs/tests/test_ogp.py）
- [x] T6b. `sphinx-docs/user/configuration.md` 変更に伴う `make update-po`（ja .po の msgid 同期・fuzzy 解消・msgstr の URL 更新）
- [x] T7. `docs/repository-structure.md` の `pnpm-workspace.yaml` 行に設定集約方針を追記
- [x] テスト: 設定 / lock / ディレクトリ移動のみのためユニットテスト新規作成は省略（design.md「テスト方針」参照）

## Phase 3: 検証・コミット
- [x] V1. `pnpm install --frozen-lockfile` pass
- [x] V2. `pnpm --recursive build` × 3 exit 0 / `ERROR:` なし（`.npmrc` 版では 1 回目に ERROR 24 行 → `pnpm-workspace.yaml` 版で 3 回連続 0 行）
- [x] V3. `pnpm --recursive test` 全 pass（10 パッケージ / 268 tests）
- [x] V4. `pnpm run check` pass
- [x] V5. `cargo check --locked` — ローカルに cargo 無し。CI `examples-build.yml` (3 OS) で検証し、green を確認してからマージする
- [x] V6. sphinx `uv sync --locked` + `make html` (build succeeded, 既存 warning 1 件は plugin-os.md の xref で無関係) + `make test` 26 passed + `make build-ja`
- [x] C1. コミット `🔧 Serialize workspace builds and bump dev dependencies`（T1〜T5, T7）
- [x] C2. コミット `📝 Archive steering docs older than 30 days`（T6）

## Phase 4: PR / マージ
- [x] push → `gh pr create` → CI green 確認 → self-merge (`--merge --delete-branch`)
- [x] CWD を main repo に戻し `git pull` → worktree / ブランチ削除 → クリーンアップ検証
- [x] Dependabot alerts が glib 1 件のみ、PR #40/#42/#46/#51/#53/#54/#55 が自動 close されたことを確認
