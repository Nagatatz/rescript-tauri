type mockIPCOptions = {shouldMockEvents?: bool}

@module("@tauri-apps/api/mocks")
external mockIPC: (
  (string, JSON.t) => promise<JSON.t>,
  ~options: mockIPCOptions=?,
) => unit = "mockIPC"

@module("@tauri-apps/api/mocks") @variadic
external _mockWindows: array<string> => unit = "mockWindows"

let mockWindows = (~current, ~additional=[]) => {
  let labels = [current]->Array.concat(additional)
  _mockWindows(labels)
}

@module("@tauri-apps/api/mocks")
external mockConvertFileSrc: (~osName: string) => unit = "mockConvertFileSrc"

@module("@tauri-apps/api/mocks")
external clearMocks: unit => unit = "clearMocks"
