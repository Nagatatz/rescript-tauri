# Design: examples-build CI に plugin-shell-demo を登録

| 項目 | 内容 |
|---|---|
| Steering 番号 | 20260511-010 |
| 関連 | `requirements.md`, `.github/workflows/examples-build.yml`, `examples/plugin-shell-demo/` |

---

## 1. 変更内容

`.github/workflows/examples-build.yml` の既存 build / cargo check 系列に以下を挿入:

```yaml
      - name: Build plugin-shell-demo frontend
        run: pnpm --filter plugin-shell-demo build
      - name: Cargo check on plugin-shell-demo Rust side
        working-directory: examples/plugin-shell-demo/src-tauri
        run: cargo check --release
```

### 挿入位置

```
... 既存 ...
      - name: Build plugin-fs-demo frontend
        ...
      - name: Cargo check on plugin-fs-demo Rust side
        ...
      ▼ ここに新規 2 step を挿入 ▼
      - name: Build plugin-shell-demo frontend
        ...
      - name: Cargo check on plugin-shell-demo Rust side
        ...
      ▲ ここまで ▲
      - name: Build ipc-typed-with-schema frontend
        ...
```

理由: 既存配列は (Phase 2 demo) → (Layer 3 demo) の論理順序になっており、plugin-shell-demo は Phase 2 系の plugin-* デモ末尾に置くのが自然。

## 2. 影響範囲

| ファイル | 変更内容 |
|---|---|
| `.github/workflows/examples-build.yml` | 4 行追加（2 step） |
| `.steering/20260511-010-.../*.md` | 新規 3 ファイル |

## 3. 検証

- YAML 構文: `python3 -c 'import yaml; yaml.safe_load(open(".github/workflows/examples-build.yml"))'` または `pnpm exec biome check` のうち動く方
- `cargo check --release` のローカル検証は `cargo` 不在のためスキップ。CI 起動を待つ。

## 4. ロールバック

merge commit を `git revert` で原状復帰可能。
