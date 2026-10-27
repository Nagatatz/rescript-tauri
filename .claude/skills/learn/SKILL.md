---
description: セッションで得た非自明な発見・回避策・プロジェクト固有のパターンを `.claude/rules/learnings.md` に記録する（`/learn`）。
allowed-tools: Read, Write, Edit, Glob
disable-model-invocation: true
---

# Learn

保存先は `.claude/rules/learnings.md`（CLAUDE.md には書かない）。

1. 会話から、次回も役立つ非自明な知見を選ぶ: デバッグ手法、ライブラリの回避策、プロジェクト固有のパターン、環境依存の注意点、計測したパフォーマンス差。一般的な言語知識・一時的な障害・既存ルールにある内容は除く。
2. learnings.md を読み（無ければ作る）、重複しないことを確認する。
3. 追記する:
   ```markdown
   # プロジェクト固有の知見（Learnings）

   - [YYYY-MM-DD] <簡潔な説明>: <詳細>
   ```
4. 追記内容をユーザーに見せて確認を得る。

新規作成したら、CLAUDE.md 末尾のコメントアウトされた `@.claude/rules/learnings.md` を有効化するよう提案する。
