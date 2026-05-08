# タスクリスト: CODE_OF_CONDUCT.md と SECURITY.md の整備

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` / `design.md` |
| 作成日 | 2026-05-08 |

## Phase 0: 事前承認

- [x] requirements.md レビュー・承認
- [x] design.md レビュー・承認（特に §1 の派生決定 4 つ、§2.2 の SECURITY.md fallback email）
- [x] tasklist.md レビュー・承認

## Phase 1: ステアリング配置

- [x] **commit 1**: ステアリング 3 ファイルを main に配置 → コミット `📝 Add steering for 20260508-005 (coc-and-security)`

## Phase 2: 実装（main 直接、worktree なし）

- [x] **commit 2**: `CODE_OF_CONDUCT.md` を新規作成（Contributor Covenant 2.1 採用、要点抜粋 + 公式 URL リンク方式 + enforcement contact: nagata.hbdc@gmail.com + CC BY 4.0 attribution。design.md §2.1 を実装中に方針変更）→ コミット `✨ Add CODE_OF_CONDUCT.md (Contributor Covenant 2.1, link-first style)`
- [x] **commit 3**: `SECURITY.md` を新規作成（Supported versions / Reporting / Response timeline / Disclosure policy / Out of scope。GHSA が primary、email fallback）→ コミット `✨ Add SECURITY.md with GHSA-first disclosure channel`
- [ ] **commit 4**: `CONTRIBUTING.md` §5（line 116）と §6（line 122）の TBD 記述を新規 2 ファイルへの参照に置換 → コミット `📝 Resolve CoC and SECURITY TBDs in CONTRIBUTING.md`

## Phase 3: 検証（コミット前）

design.md §5 に従い:

- [ ] `ls CODE_OF_CONDUCT.md SECURITY.md` で両ファイル存在を確認
- [ ] `CONTRIBUTING.md` から `CODE_OF_CONDUCT.md` / `SECURITY.md` への相対 link が解決可能（ファイル存在確認）
- [ ] `grep -n 'TBD\|will be added at the Phase 1 release' CONTRIBUTING.md` の出力が該当行ゼロ（sphinx-docs publication TBD は README にあり別件）
- [ ] `CODE_OF_CONDUCT.md` 末尾に Contributor Covenant 2.1 の attribution と CC BY 4.0 表示と原典 URL が含まれている
- [ ] `SECURITY.md` 内の GHSA URL が `https://github.com/Nagatatz/rescript-tauri/security/advisories/new` の形式

## Phase 4: マージ準備（worktree なしのためマージ手順なし、push のみ）

- [ ] **commit 5**: tasklist.md を全 `[x]` 化、本タスク自身を含めて完了マーク → コミット `📝 Mark steering 20260508-005 complete`
- [ ] `git push origin main` で全コミットを反映

## Phase 5: ユーザー手動作業（Claude 実行不可、メモ）

本ステアリング後に GitHub UI で必要な操作:

- [ ] GitHub リポジトリ Settings → Security → "Private vulnerability reporting" を有効化（GHSA の "Report a vulnerability" ボタンを Security タブに表示するため）
- [ ] visibility 切替（private → public、Phase 1 リリース時）に Community Standards スコアを Settings → Insights → Community で確認
