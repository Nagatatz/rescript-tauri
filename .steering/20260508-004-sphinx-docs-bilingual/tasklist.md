# タスクリスト: sphinx-docs 英日 2 箇国語化（フル）

| 項目 | 内容 |
|---|---|
| 関連 | `requirements.md` / `design.md` |
| 作成日 | 2026-05-08 |

## Phase 0: 事前承認

- [x] requirements.md レビュー・承認
- [x] design.md レビュー・承認（特に §1 の派生決定 4 つ）
- [x] tasklist.md レビュー・承認

## Phase 1: ステアリング配置

- [x] **commit 1**: ステアリング 3 ファイルを main に配置 → コミット `📝 Add steering for 20260508-004 (sphinx-docs-bilingual)`

## Phase 2: 実装（main 直接、worktree なし）

### 2.1 インフラ整備

- [x] **commit 2**: `sphinx-docs/conf.py` (5 placeholder + html_baseurl + ogp_site_name) と `sphinx-docs/pyproject.toml` (2 placeholder) を解消 → コミット `🔧 Resolve sphinx-docs placeholders in conf.py and pyproject.toml`
- [x] 検証: `grep -n '{{' conf.py pyproject.toml` 0 件（.md 内の 7 件は commit 3/4 で解消）

### 2.2 英語コンテンツ整備

- [x] **commit 3**: `sphinx-docs/index.md` および `user/{index,installation,quickstart,configuration,changelog}.md` の 6 ファイルを書き換え → コミット `📝 Rewrite sphinx-docs/index.md and user/* with rescript-tauri content`
- [x] 検証: `cd sphinx-docs && make install && make html` で `_build/html/index.html` および `_build/html/user/*.html` が生成（commit 4 後にまとめて実行）
- [ ] **commit 4**: `sphinx-docs/dev/{index,setup,building,architecture,project-structure,contributing}.md` の 6 ファイルを書き換え → コミット `📝 Rewrite sphinx-docs/dev/* with rescript-tauri content`
- [ ] 検証: `make html` で `_build/html/dev/*.html` が生成

### 2.3 日本語 .po 生成

- [ ] **commit 5**: `cd sphinx-docs && make update-po` で 12 `.po` を生成 → コミット `🌐 Generate Japanese .po files via make update-po`
- [ ] 検証: `ls sphinx-docs/locale/ja/LC_MESSAGES/` に 12 `.po` が存在（msgstr は空のまま）

### 2.4 日本語翻訳

- [ ] **commit 6**: `locale/ja/LC_MESSAGES/{index,user/*}.po` の msgid を翻訳 → コミット `🌐 Translate user/* .po files into Japanese`
- [ ] **commit 7**: `locale/ja/LC_MESSAGES/dev/*.po` の msgid を翻訳 → コミット `🌐 Translate dev/* .po files into Japanese`
- [ ] 検証: 各コミット後に `make build-ja` で `_build/html_ja/` が生成

## Phase 3: 統合検証

- [ ] **commit 8**: `cd sphinx-docs && make build-all` を実行し、結果を tasklist に記録 → コミット `✅ Verify make build-all produces en + ja sites`
- [ ] 検証項目:
  - `_build/site/en/index.html` が存在
  - `_build/site/ja/index.html` が存在
  - `_build/site/index.html` が `/en/` リダイレクト
  - `_build/site/pagefind/` が存在（Pagefind 検索インデックス）
- [ ] `make linkcheck` を実行し broken link がないこと（外部 URL 一時不達は許容）
- [ ] `make lint` が pass

## Phase 4: マージ準備（worktree なしのためマージ手順なし、push のみ）

- [ ] **commit 9**: tasklist.md を全 `[x]` 化、本タスク自身を含めて完了マーク → コミット `📝 Mark steering 20260508-004 complete`
- [ ] `git push origin main` で全コミットを反映
