# タスクリスト: CONTRIBUTING.md と docs/development-guidelines.md の整備

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` / `design.md` |
| 作成日 | 2026-05-08 |

## Phase 0: 事前承認

- [x] requirements.md レビュー・承認
- [x] design.md レビュー・承認（特に §1 の派生決定 3 つ）
- [x] tasklist.md レビュー・承認

## Phase 1: ステアリング配置

- [x] **commit 1**: `.steering/20260508-003-contributing-and-dev-guidelines/` 3 ファイルを main に配置 → コミット `📝 Add steering for 20260508-003 (contributing-and-dev-guidelines)`

## Phase 2: 実装（main 直接、worktree なし）

- [x] **commit 2**: `docs/development-guidelines.md` を新規作成（design.md §2.2 の章立てに従う、日本語、既存 `docs/*` ヘッダーパターン準拠）→ コミット `✨ Add docs/development-guidelines.md (Japanese, internal-facing)`
- [x] **commit 3**: `CONTRIBUTING.md` を新規作成（design.md §2.1 の章立てに従う、英語、Phase 1 前の立ち位置を明示）→ コミット `✨ Add CONTRIBUTING.md (English, future-PR-aware)`
- [x] **commit 4**: `README.md` を軽微修正（design.md §2.3 の 3 箇所: §Development setup 末尾、§Contributing、§Visibility チェックリスト）→ コミット `📝 Resolve broken link and update visibility checklist in README`

## Phase 3: 検証（コミット前）

design.md §5 に従い:

- [ ] README → `docs/development-guidelines.md` リンクが有効（ファイル存在確認）
- [ ] README → `CONTRIBUTING.md` リンクが有効
- [ ] CONTRIBUTING.md / development-guidelines.md → `.claude/rules/*` への参照リンクが解決可能（参照先ファイルすべて実在）
- [ ] `docs/development-guidelines.md` のヘッダーが既存 `docs/*` パターンと整合（メタテーブル + 序文ブロック）
- [ ] markdown lint 確認（IDE 診断で新規 warning なし、既存の rescript.json missing 等は Phase 1 で解消予定）

## Phase 4: マージ準備（worktree なしのためマージ手順なし、push のみ）

- [ ] **commit 5**: tasklist.md を全 `[x]` 化、本タスク自身の Phase 4 を含めて完了マーク → コミット `📝 Mark steering 20260508-003 tasks complete`
- [ ] `git push origin main` で 5 コミットを反映
