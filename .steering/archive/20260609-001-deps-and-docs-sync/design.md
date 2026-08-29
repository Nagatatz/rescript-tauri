# 設計: 依存パッケージ更新とドキュメント整合修正

| 項目 | 内容 |
|---|---|
| 機能名 | deps-and-docs-sync |
| 作成日 | 2026-06-09 |

## 1. 実装アプローチ

依存更新とドキュメント修正を **2 コミットに分離**する（git-conventions.md「1 コミット 1 論理変更」）。

1. `🔧 Update dev dependencies to latest patch/minor` — 依存更新 + lockfile
2. `📝 Sync sphinx-docs tree in repository-structure.md` — ドキュメント整合修正

### 依存更新の手順

ルートおよび各 workspace の `package.json` に同一 devDep が散在するため、`pnpm update --recursive` でまとめて引き上げる。対象を明示指定して意図しない major 巻き込みを防ぐ:

```bash
pnpm update --recursive \
  rescript@~12.3.0 @rescript/runtime@~12.3.0 \
  vitest@~4.1.8 @vitest/coverage-v8@~4.1.8 \
  happy-dom@~20.10.2 @tauri-apps/cli@~2.11.2 \
  @biomejs/biome@~2.4.16 @types/node@~25.9.2
```

- `~` レンジで minor/patch 上限を制御（既存の range 表記に合わせて後で確認・調整）。
- `package.json` の version range 表記は既存スタイルを踏襲する（`^` か固定か実物を確認）。

### ドキュメント修正の内容

`docs/repository-structure.md` §5（`sphinx-docs/user/` ツリー、373-376 行付近）に以下 6 行を追記:

```
│   ├── plugin-shell.md
│   ├── plugin-log.md
│   ├── plugin-notification.md
│   ├── plugin-os.md
│   ├── plugin-clipboard-manager.md
│   ├── plugin-http.md
```

挿入位置はアルファベット/カテゴリ順を考慮し、既存の plugin-fs.md / plugin-dialog.md の並びに合わせる。`schema.md` / `changelog.md` の位置関係も保つ。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| ルート `package.json` | dev 依存 version range 引き上げ | 修正 |
| `packages/*/package.json` | dev 依存 version range 引き上げ（該当分） | 修正 |
| `examples/*/package.json` | `@tauri-apps/cli` / `rescript` 等の引き上げ（該当分） | 修正 |
| `pnpm-lock.yaml` | install による再生成 | 修正 |
| `docs/repository-structure.md` | §5 ツリーに 6 plugin ページ追記 | 修正 |

## 3. データ構造の変更

なし（依存バージョンとドキュメントのみ）。

## 4. 影響範囲の分析

### 直接的な影響

- `rescript` 12.3.0: compiler minor bump。全 `.res` の再コンパイルが走る。型エラー / 非互換が出ないかを `pnpm --recursive build` で検証。
- `vitest` / `happy-dom`: runtime テストの実行環境。`pnpm --recursive test` で検証。
- `@biomejs/biome`: lint/format ルールの patch。`pnpm run check` で検証。

### 間接的な影響

- CI workflow（`tests-*`, `examples-build`, `lint-format`）は package.json/lockfile を参照するため、PR で CI が緑になることを最終確認とする。
- 公開パッケージの `peerDependencies` は不変のため、利用者側への影響なし。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| rescript minor bump を含めるか | 含める / patch のみ | 含める | ユーザー指示「依存更新も含めて両方」。pre-release で互換懸念小、build/test で検証可能 |
| 上流 `@tauri-apps/api` の追従 | 追従 / 据え置き | 据え置き | latest が 2.11.0 のまま。カバー記述変更不要 |
| コミット分割 | 1 / 2 コミット | 2 コミット | 依存更新とドキュメント修正は別論理。revert 容易性を確保 |
| version range 指定 | 明示パッケージ / 全更新 | 明示パッケージ | 意図しない major 巻き込みを防ぐ |
