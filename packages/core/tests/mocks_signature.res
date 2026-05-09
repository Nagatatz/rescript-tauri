// Type-level signature test for Mocks.

let _check_mock_ipc_options: Mocks.mockIPCOptions = {shouldMockEvents: ?None}
let _check_mock_ipc: (
  (string, JSON.t) => promise<JSON.t>,
  ~options: Mocks.mockIPCOptions=?,
) => unit = Mocks.mockIPC
let _check_mock_windows: (~current: string, ~additional: array<string>=?) => unit =
  Mocks.mockWindows
let _check_mock_convert_file_src: (~osName: string) => unit = Mocks.mockConvertFileSrc
let _check_clear_mocks: unit => unit = Mocks.clearMocks
