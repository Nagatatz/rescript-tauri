# Design — funding フィールドを全パッケージに追加

## 1. 追加内容

各 `packages/*/package.json` の `homepage` 直後・`repository` 直前に `funding` フィールドを挿入する。

```json
{
  "name": "@rescript-tauri/<package>",
  "version": "0.1.0",
  "description": "...",
  "license": "MIT",
  "homepage": "https://github.com/Nagatatz/rescript-tauri",
  "funding": {
    "type": "github",
    "url": "https://github.com/sponsors/Nagatatz"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/Nagatatz/rescript-tauri.git",
    "directory": "packages/<dir>"
  },
  ...
}
```

## 2. フィールド配置の根拠

npm 公式 doc では `funding` の位置に強い指定は無いが、慣例的に `homepage` / `repository` / `bugs` などの metadata 近傍に置く。本リポジトリ既存の順序 (`name` → `version` → `description` → `license` → `homepage` → `repository`) に対し、`homepage` の隣に `funding` を入れるのが視覚的に自然。

## 3. オブジェクト形式 vs 文字列形式

npm は 3 形式を受け付ける:
1. 文字列: `"funding": "https://..."`
2. オブジェクト: `"funding": { "type": "...", "url": "..." }`
3. 配列: `"funding": [{...}, "https://..."]`

**選択: オブジェクト形式 (2)**

理由:
- `type` を明示することで `npm fund` の出力で「github」と分類される（文字列形式では `type` は推測される）
- 将来 funding 手段を増やす場合に配列に変換しやすい
- Biome の JSON format でも整形しやすい

## 4. Biome 整形への対応

`biome.json` で JSON format が有効。挿入時は他の object フィールドと同じインデント・引用符を使う。`pnpm run check:fix` で最終整形して差分を吸収する。

## 5. 変更対象ファイル一覧

| パッケージ | パス |
|---|---|
| core | `packages/core/package.json` |
| plugin-fs | `packages/plugin-fs/package.json` |
| plugin-dialog | `packages/plugin-dialog/package.json` |
| plugin-shell | `packages/plugin-shell/package.json` |
| plugin-notification | `packages/plugin-notification/package.json` |
| plugin-log | `packages/plugin-log/package.json` |
| plugin-os | `packages/plugin-os/package.json` |
| plugin-clipboard-manager | `packages/plugin-clipboard-manager/package.json` |
| plugin-http | `packages/plugin-http/package.json` |
| schema | `packages/schema/package.json` |

10 ファイル × 4 行追加（フィールド + 内部の type / url + 閉じ括弧）。

## 6. 検証戦略

1. **構文検証**: `node -e "JSON.parse(require('fs').readFileSync('packages/*/package.json'))"` 相当を各ファイルに対して実行（Read 後の目視確認で代替可）
2. **ビルド検証**: `pnpm --recursive build` で ReScript ビルドが通ることを確認
3. **format 検証**: `pnpm run check` で Biome violations が無いことを確認
4. **`npm pack` 検証は省略**: metadata のみの変更で配布物には影響しない

## 7. 検証省略項目と理由

- **vitest 実行**: `funding` フィールドはランタイム挙動に影響しないため省略
- **CI dry-run**: 全 workflow 設定の変更なし、yaml の paths にも影響しないため省略
- **CHANGELOG 更新**: 公開 API 変更ではないため省略（個別 package CHANGELOG・root CHANGELOG どちらも対象外）

## 8. ドキュメント更新

- `docs/repository-structure.md`: package.json のフィールド一覧は記載していないため更新不要
- `CLAUDE.md`: 規約変更ではないため更新不要
- `README.md`: ユーザー向け機能ではないため更新不要
- `sphinx-docs/`: 同上、更新不要

## 9. リスク

- **GitHub Sponsors 未有効化**: URL `https://github.com/sponsors/Nagatatz` が現時点で 404 を返す可能性。ただし `npm fund` は URL 到達性を検証せず単に表示するだけで、リダイレクト先の GitHub 側がフォールバックページを返す挙動。実害は出力上の見栄えのみ
- **将来の URL 変更**: 後で URL を変えても package.json の更新は通常の bump コミットで吸収できる
