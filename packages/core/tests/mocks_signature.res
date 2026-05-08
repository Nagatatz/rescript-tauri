// Type-level signature test for Mocks.

let _check_mock_ipc: ((string, JSON.t) => promise<JSON.t>) => unit = Mocks.mockIPC
let _check_mock_windows: (~current: string, ~additional: array<string>=?) => unit =
  Mocks.mockWindows
let _check_clear_mocks: unit => unit = Mocks.clearMocks
