# タスクリスト: `@rescript-tauri/plugin-os`

## Phase 1: scaffold
- [x] package.json / rescript.json / vitest.config.mjs / README / CHANGELOG
- [x] pnpm install
- [x] commit

## Phase 2: 実装
- [x] PluginOs.res / .resi（4 variants + 9 関数, type→osType_ リネーム）
- [x] build 通る
- [x] commit

## Phase 3: テスト
- [x] plugin_os_signature.res
- [x] runtime/plugin_os.test.mjs (sync 関数は globals stub、async 関数は mockIPC)
- [x] commit

## Phase 4: CI
- [x] tests-plugin-os-{types,runtime}.yml
- [x] tests-coverage.yml matrix
- [x] release.yml tag prefix
- [x] commit

## Phase 5: ドキュメント
- [x] root README + repository-structure.md
- [x] commit

## Phase 6: 検証 + マージ
- [x] monorepo build + test 全件 pass
- [x] tasklist [x]
- [x] main マージ + クリーンアップ
