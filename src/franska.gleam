//// Starts the browser app with real browser access.

import franska/progress
import franska/ui/app
import franska/ui/browser
import gleam/list
import gleam/result
import lustre

pub fn main() -> Nil {
  browser.register_service_worker()
  // Unreadable or outdated progress starts over rather than breaking the app.
  let progress =
    progress.from_json(browser.load(app.storage_key))
    |> result.unwrap(progress.new())
  let env =
    app.Env(
      now: browser.now_seconds,
      today: browser.local_day,
      shuffle: list.shuffle,
      can_speak: browser.can_speak(),
    )
  let application = lustre.application(app.init, app.update, app.view)
  let assert Ok(_) = lustre.start(application, "#app", #(env, progress))
  Nil
}
