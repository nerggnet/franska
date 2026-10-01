//// Browser access: storage, speech, focus, the clock. Every external has a
//// Gleam fallback so the package also compiles for Erlang, where the
//// fallbacks act as a browser without storage or speech.

@external(javascript, "./browser.ffi.mjs", "focus")
pub fn focus(_id: String) -> Nil {
  Nil
}

@external(javascript, "./browser.ffi.mjs", "insert_at_cursor")
pub fn insert_at_cursor(_id: String, text: String) -> String {
  text
}

@external(javascript, "./browser.ffi.mjs", "can_speak")
pub fn can_speak() -> Bool {
  False
}

@external(javascript, "./browser.ffi.mjs", "speak")
pub fn speak(_text: String) -> Nil {
  Nil
}

@external(javascript, "./browser.ffi.mjs", "load")
pub fn load(_key: String) -> String {
  ""
}

@external(javascript, "./browser.ffi.mjs", "save")
pub fn save(_key: String, _value: String) -> Nil {
  Nil
}

@external(javascript, "./browser.ffi.mjs", "now_seconds")
pub fn now_seconds() -> Int {
  0
}

@external(javascript, "./browser.ffi.mjs", "local_day")
pub fn local_day() -> Int {
  0
}

@external(javascript, "./browser.ffi.mjs", "request_persistence")
pub fn request_persistence() -> Nil {
  Nil
}

@external(javascript, "./browser.ffi.mjs", "download")
pub fn download(_prefix: String, _text: String) -> Nil {
  Nil
}

@external(javascript, "./browser.ffi.mjs", "read_chosen_file")
pub fn read_chosen_file(_id: String, on_text: fn(String) -> Nil) -> Nil {
  on_text("")
}
