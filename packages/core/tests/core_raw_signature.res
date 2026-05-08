// Type-level signature test for Core.Raw.
//
// Compile success = pass. The test references every public symbol of
// `Core.Raw` with an explicit type annotation so that any backwards-
// incompatible change to the .resi (rename, signature change, removal)
// breaks the build.
//
// See PRD §5.4 (型レベルテスト 100% カバレッジ) and
// functional-design §6 / §7.

let _check_invoke_signature: (
  string,
  ~args: 'args=?,
  ~options: Core.Raw.invokeOptions=?,
) => promise<'result> = Core.Raw.invoke

let _check_invoke_options_type: Core.Raw.invokeOptions = {
  headers: ?None,
}
