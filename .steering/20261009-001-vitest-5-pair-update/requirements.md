# 要求: Vitest / @vitest/coverage-v8 のペア更新 (Issue #80)

## 背景
Dependabot が `vitest` と `@vitest/coverage-v8` を別々の PR で 4.1.11 → 5.x に更新しており
（#73/#74、その後継の #82/#83）、どちらを単独で入れても runner と provider の版が混在する。
混在状態では coverage-v8 が `TypeError: Expected string coverage payload, received object`
で計測に失敗し、coverage 0% → 既存閾値未達で `tests-coverage` の全 10 package が failure になる。

## 要求
- 全 10 package の `vitest` と `@vitest/coverage-v8` を **同一版 (5.0.3)** に揃える
- `pnpm-lock.yaml` を同じ commit で再生成し、4.x の残骸・混在警告がないこと
- 全 10 package の `test:coverage` が **既存閾値のまま** 成功すること

## 非要求 (Non-goals)
- Tauri JS/Rust、happy-dom、oxlint/oxfmt、GitHub Actions 等の独立更新
- coverage 閾値の引き下げ・対象除外
- CHANGELOG 追記（dev 依存の更新はリリース時にまとめて記載する運用のため）
