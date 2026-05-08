@val external document: 'a = "document"

let renderGreeting = async () => {
  let greeting: string =
    await RescriptTauriCore.Core.Raw.invoke("greet", ~args={"name": "ReScript"})
  let el = document["getElementById"]("greeting")
  el["textContent"] = greeting
}

let _ = renderGreeting()
