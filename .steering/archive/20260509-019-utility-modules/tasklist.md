# Tasklist: ユーティリティモジュール群

- [x] `.steering/20260509-019-utility-modules/` ディレクトリ作成
- [x] requirements.md / design.md / tasklist.md 作成
- [x] worktree `worktree-phase1-utility-modules` 作成
- [x] `Dpi.res` / `Dpi.resi` 作成（LogicalSize / PhysicalSize / LogicalPosition / PhysicalPosition / Size / Position）
- [x] `Path.res` / `Path.resi` 作成（BaseDirectory + 31 関数）
- [x] `Image.res` / `Image.resi` 作成（opaque type + new_ / fromBytes / fromPath / rgba / size）
- [x] `App.res` / `App.resi` 作成（Image.t 参照あり）
- [x] `tests/dpi_signature.res` 作成
- [x] `tests/path_signature.res` 作成
- [x] `tests/app_signature.res` 作成
- [x] `tests/image_signature.res` 作成
- [x] `pnpm --filter @rescript-tauri/core build` 緑
- [x] `pnpm --filter @rescript-tauri/core test` 緑
- [x] 公開シンボルカバレッジ緑 (138/138)
- [x] コミット (`✨ Add Dpi / Path / App / Image utility modules`)
- [x] tasklist.md の全タスク `[x]` 化と最終コミット
- [x] main へマージ
- [x] worktree とブランチを削除
