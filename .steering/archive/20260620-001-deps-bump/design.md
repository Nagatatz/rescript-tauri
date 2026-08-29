# design — 20260620-001 deps bump

## 変更方針

### 1. `@types/node` major bump (`^25` → `^26`)

`^25` は semver で 26.0.0 を満たさないため、レンジを明示更新する必要がある。
対象: root `package.json` + `packages/*/package.json` 全 10 ファイルの `devDependencies."@types/node"`。

`@types/node` は手書き `.mjs` ツール / vitest 設定の型補完用 dev dep であり、生成物 (`*.res.mjs`) や公開 API には影響しない。major bump のリスクは低い。

### 2. lockfile refresh

`pnpm install` を実行し、caret 範囲内で解決可能な最新を取り込む:
- `@biomejs/biome` 2.4.16 → 2.5.0 (minor)
- `vitest` / `@vitest/coverage-v8` 4.1.8 → 4.1.9 (patch)
- `happy-dom` 20.10.2 → 20.10.6 (patch)
- `@types/node` 25.9.2 → 26.x (レンジ更新後)

### 3. 検証

- `pnpm run check`（biome 2.5.0）: 新 lint 規則で警告が出ないこと
- `pnpm --recursive build`: ReScript ビルド成功
- `pnpm --recursive test`: 型レベル + vitest 全件 pass

biome 2.5.0 が新規 lint 違反を出した場合は、コードを規約準拠で修正する（差分が大きければ別途報告）。

## 影響範囲

dev / tooling のみ。ランタイム・公開 API への影響なし。
