/- Scope: Core.Command.invoke, after argument encoding succeeds.
   The Tauri backend either rejects or returns one reply. The decoder is total
   and returns an Except. Payload and errors are opaque. Native IPC transport,
   throwing encoders/decoders, scheduling and the actual JavaScript are not proved. -/

inductive Reply (Raw : Type) where
  | rejected (error : String)
  | received (payload : Raw)

inductive Outcome (Value : Type) where
  | backendError (error : String)
  | decodeError (error : String)
  | ok (value : Value)

def route {Raw Value : Type} (decode : Raw → Except String Value) :
    Reply Raw → Outcome Value
  | .rejected error => .backendError error
  | .received payload =>
    match decode payload with
    | .error error => .decodeError error
    | .ok value => .ok value

theorem backend_error_independent_of_decoder {Raw Value : Type}
    (first second : Raw → Except String Value) (error : String) :
    route first (.rejected error) = route second (.rejected error) := rfl

theorem decode_error_preserves_message {Raw Value : Type}
    (decode : Raw → Except String Value) (raw : Raw) (message : String)
    (failure : decode raw = .error message) :
    route decode (.received raw) = .decodeError message := by
  simp [route, failure]

theorem successful_result_iff_decoded {Raw Value : Type}
    (decode : Raw → Except String Value) (reply : Reply Raw) (value : Value) :
    route decode reply = .ok value ↔
      ∃ raw, reply = .received raw ∧ decode raw = .ok value := by
  cases reply with
  | rejected error => simp [route]
  | received raw =>
    cases h : decode raw with
    | error message => simp [route, h]
    | ok result =>
      simp [route, h]
