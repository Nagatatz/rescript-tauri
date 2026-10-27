# 並列実装（複数機能を同時に）

バッチブランチを中間ブランチ（PR の base）にし、全機能を統合してから PR で main へ入れる。独立したパッケージを N 個並列で作るときは `parallel-implementation-swarm` skill も参照。

```text
main
 └── batch/<バッチ名>        ← 計画・統合用、PR の base
      ├── worktree-<機能名1>
      └── worktree-<機能名2>
```

1. `main` から `batch/<バッチ名>` を作り push する。
2. バッチブランチ上でステアリングを作成・承認する。
3. 各ウィンドウで `claude --worktree <機能名>`（base は batch ブランチ）を実行し、実装する。共有ドキュメントはこの段階では更新しない。
4. 各機能ブランチを PR 経由でバッチブランチにマージ（または local merge して push）し、毎回ビルドを確認する。
5. 共有ドキュメントをまとめて更新する。
6. バッチブランチを `main` への PR にして self-merge し、削除する。worktree の削除は `worktree-safety` skill の順序に従う。
