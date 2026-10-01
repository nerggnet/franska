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
