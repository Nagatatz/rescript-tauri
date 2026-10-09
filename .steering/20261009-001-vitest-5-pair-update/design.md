# 設計: Vitest / @vitest/coverage-v8 のペア更新

## 採用版
5.0.3（2026-10-09 時点の npm `latest`。後継 bot PR #82/#83 と同じ版）。
Issue 起票時の候補 5.0.1 からパッチ版のみ前進。

## 変更対象
- `packages/{core,schema,plugin-fs,plugin-dialog,plugin-shell,plugin-notification,plugin-log,plugin-os,plugin-clipboard-manager,plugin-http}/package.json`
  の `devDependencies` 2 行: `^4.1.11` → `^5.0.3`
- `pnpm-lock.yaml`: `pnpm install` (pnpm 11.0.9) で再生成

## 互換性確認
- vitest 5.0.3 の peer `vite: ^6.4.0 || ^7.0.0 || ^8.0.0` は `pnpm-workspace.yaml` の
  override `vite: ^7.3.6` を満たすため override 変更は不要
- `@vitest/coverage-v8` は peer で `vitest: 5.0.3` を厳密要求 → 2 依存を同時に動かす必要がある
- `tools/vitest.shared.mjs` / 各 `vitest.config.mjs` は 5.x で変更不要（全テスト・閾値 pass で確認）
