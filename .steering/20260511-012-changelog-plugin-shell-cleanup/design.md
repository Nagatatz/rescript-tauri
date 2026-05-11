# Design: packages/plugin-shell/CHANGELOG.md cleanup

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-012 |
| 関連 | `requirements.md`, `packages/plugin-shell/CHANGELOG.md`, `packages/plugin-fs/CHANGELOG.md` |

---

## 1. 変更内容

### 1.1 `Added` への追加

`packages/plugin-fs/CHANGELOG.md` の同スタイルに揃え、`peerDependencies:` の直前に以下を挿入:

```markdown
- Runnable example
  [`examples/plugin-shell-demo`](https://github.com/Nagatatz/rescript-tauri/tree/main/examples/plugin-shell-demo)
  exercising the full surface (openPath / Command / Child /
  EventEmitter chains) from button-driven UI.
```

### 1.2 `Deferred to follow-up sub-steerings` セクション削除

以下の 5 行を完全削除:

```markdown
### Deferred to follow-up sub-steerings

- Runnable example app (`examples/plugin-shell-demo/`).
- sphinx-docs `user/plugin-shell.md` page.

```

### 1.3 sphinx-docs user guide の言及

plugin-fs CHANGELOG にも記載されていないため、本ステアリングでも追加しない（CHANGELOG は package 機能変更のみを記録する慣例に従う）。

## 2. 影響範囲

| ファイル | 変更内容 |
|---|---|
| `packages/plugin-shell/CHANGELOG.md` | `Added` に 4 行追加、`Deferred` セクション 5 行削除 |
| `.steering/20260511-012-.../*.md` | 新規 3 ファイル |

## 3. 検証

- `grep -A 3 'Deferred' packages/plugin-shell/CHANGELOG.md` が `Deferred to follow-up sub-steerings` を **見つけない** こと
- `grep 'examples/plugin-shell-demo' packages/plugin-shell/CHANGELOG.md` が hit すること

## 4. ロールバック

merge commit を `git revert` で原状復帰可能。
