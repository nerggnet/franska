export function focus(id) {
  document.getElementById(id)?.focus();
}

/// Replaces the selection in the input with `text`, keeps the caret after
/// it, and returns the input's new value.
export function insert_at_cursor(id, text) {
  const input = document.getElementById(id);
  if (!input) return text;
  const start = input.selectionStart ?? input.value.length;
  const end = input.selectionEnd ?? input.value.length;
  input.value = input.value.slice(0, start) + text + input.value.slice(end);
  const caret = start + text.length;
  input.focus();
  input.setSelectionRange(caret, caret);
  return input.value;
}

export function can_speak() {
  return typeof window !== "undefined" && "speechSynthesis" in window;
}

export function speak(text) {
  if (!can_speak()) return;
  const synth = window.speechSynthesis;
  synth.cancel();
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = "fr-FR";
  const voices = synth.getVoices();
  const voice =
    voices.find((v) => v.lang === "fr-FR") ??
    voices.find((v) => v.lang.startsWith("fr"));
  if (voice) utterance.voice = voice;
  utterance.rate = 0.9;
  synth.speak(utterance);
}

/// Returns the stored string, or "" if there is none or storage is blocked.
export function load(key) {
  try {
    return window.localStorage.getItem(key) ?? "";
  } catch {
    return "";
  }
}

export function save(key, value) {
  try {
    window.localStorage.setItem(key, value);
  } catch {
    // Storage can be full or blocked (private mode); progress is then kept
    // for this visit only.
  }
}

export function now_seconds() {
  return Math.floor(Date.now() / 1000);
}

/// Days since 1970-01-01 in the browser's time zone.
export function local_day() {
  const now = new Date();
  return Math.floor((now.getTime() - now.getTimezoneOffset() * 60_000) / 86_400_000);
}

let persistence_requested = false;

/// Asks the browser not to evict this site's storage. Browsers remember the
/// answer, so this only needs to happen once per visit.
export function request_persistence() {
  if (persistence_requested) return;
  persistence_requested = true;
  navigator.storage?.persisted?.().then((persisted) => {
    if (!persisted) navigator.storage.persist?.();
  });
}

/// Offers `text` as a JSON file download named `<prefix>-<date>.json`.
export function download(prefix, text) {
  const date = new Date().toISOString().slice(0, 10);
  const url = URL.createObjectURL(new Blob([text], { type: "application/json" }));
  const link = document.createElement("a");
  link.href = url;
  link.download = `${prefix}-${date}.json`;
  document.body.append(link);
  link.click();
  link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

/// Reads the file chosen in the file input with the given id, then calls
/// `on_text` with its contents ("" if there is none or it cannot be read).
export function read_chosen_file(id, on_text) {
  const input = document.getElementById(id);
  const file = input?.files?.[0];
  if (!file) return on_text("");
  file.text().then(on_text, () => on_text(""));
  // Allow choosing the same file again later.
  input.value = "";
}
