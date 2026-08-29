# requirements — 20260620-001 deps bump

## 背景

ライブラリ更新に伴う修正要否の調査（2026-06-20）で、バインディングのコード修正が必須となる更新は無いことを確認した。
`@tauri-apps/api` の patch 差分 (2.11.0 → 2.11.1) は `window.d.ts` の `Monitor` 型 doc comment のみで公開シンボル変化なし。

残るのは dev / tooling 依存のバージョンドリフトのみ:

| ライブラリ | lockfile | latest | 範囲 |
|---|---|---|---|
| `@types/node` | 25.9.2 | 26.0.0 | **major, `^25` 範囲外** |
| `@biomejs/biome` | 2.4.16 | 2.5.0 | minor, `^2.4.16` 範囲内（lockfile 未更新） |
| `vitest` / `@vitest/coverage-v8` | 4.1.8 | 4.1.9 | patch, 範囲内 |
| `happy-dom` | 20.10.2 | 20.10.6 | patch, 範囲内 |

## ゴール

- dev / tooling 依存を最新へ揃え、lockfile を refresh する
- `@types/node` の semver レンジを `^25` → `^26` に更新する（全 package.json + root）
- biome 2.5.0 へ上げた上で `pnpm run check` が clean であることを確認する

## 非ゴール

- バインディングコード (`.res` / `.resi`) の変更（不要と確認済み）
- 上流 `@tauri-apps/*` plugin のレンジ変更（既に最新解決済み）
- `Monitor` doc comment の cosmetic ミラー（別 PR 候補、本 PR では扱わない）
