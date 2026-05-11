# Requirements: packages/plugin-shell/CHANGELOG.md cleanup

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-012 |
| 作業タイトル | plugin-shell CHANGELOG cleanup |
| 作成日 | 2026-05-11 |
| 関連 steering | 051 (plugin-shell 本体), 20260511-001 (user guide), 20260511-008 (demo) |

---

## 1. 背景

`packages/plugin-shell/CHANGELOG.md` の **"Deferred to follow-up sub-steerings"** セクションに以下 2 項目が deferred 扱いで残っているが、両方とも既に完了済み:

- `examples/plugin-shell-demo/` — steering 20260511-008 で実装、merge 済み (`16c0b33`)
- `sphinx-docs/user/plugin-shell.md` — steering 20260511-001 で実装、merge 済み (`524fb38`)

リリース前の整合性確保のため、CHANGELOG を最新の事実に合わせて修正する。

## 2. 目的

`packages/plugin-shell/CHANGELOG.md` の `Unreleased` セクションを以下のように更新:
- `Added` に "Runnable example app" 言及を追加（plugin-fs CHANGELOG と同スタイル）
- `Deferred to follow-up sub-steerings` セクションは削除（残項目なし）

## 3. スコープ

### 3.1 含めるもの

- `packages/plugin-shell/CHANGELOG.md` の編集（`Added` への 1 項目追加 + `Deferred` セクション削除）

### 3.2 含めないもの

- 他 plugin の CHANGELOG.md の整合性チェック / 修正
- バージョン bump (`0.0.0` → `0.1.0`)
- リリースタグ打ち
- sphinx-docs 関連の追加変更

## 4. 受け入れ基準

- [ ] `packages/plugin-shell/CHANGELOG.md` の `Added` に `examples/plugin-shell-demo` への言及がある
- [ ] `Deferred to follow-up sub-steerings` セクションが消えている
- [ ] フォーマットが `packages/plugin-fs/CHANGELOG.md` の Added スタイルと整合
- [ ] tasklist 全タスク `[x]` で main マージ完了

## 5. リスク

- **並列衝突**: 並列セッションが plugin-shell CHANGELOG を編集する可能性は低い（CHANGELOG は package owner が普通触らない）
- **フォーマット**: Markdown のみのため CI lint への影響なし
