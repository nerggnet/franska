import franska/answer
import franska/content
import franska/course
import franska/course/lesson
import franska/exercise
import franska/lexicon
import franska/progress.{type Progress, Progress}
import franska/srs.{CardState}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/order
import gleam/set
import gleam/string

pub fn lesson_ids_are_unique_slugs_test() {
  let ids = list.map(course.lessons(), fn(lesson) { lesson.id })
  assert list.length(ids) == list.length(list.unique(ids))
  let allowed = string.to_graphemes("abcdefghijklmnopqrstuvwxyz0123456789-")
  assert list.filter(ids, fn(id) {
      !list.all(string.to_graphemes(id), list.contains(allowed, _))
    })
    == []
}

/// Every entry of every part has at least one exercise in the part's
/// drills, so that a misspelt id or a drill that does not fit shows up.
pub fn every_part_selects_exercises_of_each_entry_test() {
  let all = content.all_exercises()
  let bad =
    list.flat_map(course.lessons(), fn(lesson) {
      list.flat_map(lesson.parts, fn(part) {
        list.filter(part.entries, fn(entry) {
          !list.any(all, fn(e) {
            e.entry_id == entry
            && list.contains(part.drills, exercise.drill(e.kind))
          })
        })
        |> list.map(fn(entry) { lesson.id <> ": " <> entry })
      })
    })
  assert bad == []
}

pub fn no_exercise_is_in_two_lessons_test() {
  let all = content.all_exercises()
  let ids =
    list.flat_map(course.lessons(), fn(lesson) {
      list.flat_map(lesson.parts, fn(part) {
        list.filter(all, fn(e) {
          list.contains(part.entries, e.entry_id)
          && list.contains(part.drills, exercise.drill(e.kind))
        })
      })
    })
    |> list.map(fn(e) { e.id })
  let twice =
    list.group(ids, fn(id) { id })
    |> dict.filter(fn(_, found) { list.length(found) > 1 })
    |> dict.keys
  assert twice == []
}

/// The course covers all content: place new entries in a lesson.
pub fn every_entry_and_number_is_in_the_course_test() {
  let in_course =
    course.lessons()
    |> list.flat_map(fn(lesson) { lesson.parts })
    |> list.flat_map(fn(part) { part.entries })
    |> set.from_list
  let missing =
    content.all_exercises()
    |> list.map(fn(e) { e.entry_id })
    |> list.unique
    |> list.filter(fn(id) { !set.contains(in_course, id) })
  assert missing == []
}

pub fn lessons_are_a_reasonable_size_test() {
  let sizes =
    course.build(content.all_exercises())
    |> list.map(fn(pair) { list.length(pair.1) })
  assert list.all(sizes, fn(size) { size >= 40 && size <= 160 })
}

/// A lesson only practises its own level and easier ones, and the lessons
/// of a level come after those of easier levels.
pub fn lessons_are_in_level_order_test() {
  let levels = list.map(course.lessons(), fn(lesson) { lesson.level })
  assert list.sort(levels, lexicon.compare_levels) == levels
  let all = content.all_exercises()
  let too_hard =
    course.build(all)
    |> list.flat_map(fn(pair) {
      list.filter(pair.1, fn(e) {
        lexicon.compare_levels(e.level, { pair.0 }.level) == order.Gt
      })
      |> list.map(fn(e) { { pair.0 }.id <> ": " <> e.id })
    })
  assert too_hard == []
}

pub fn every_lesson_has_a_note_test() {
  assert list.all(course.lessons(), fn(lesson) {
    lesson.note != [] && lesson.title != "" && lesson.topic != ""
  })
}

// Position in the course ------------------------------------------------------

fn small_course() {
  let exercise = fn(id) {
    exercise.Exercise(
      id:,
      entry_id: id,
      kind: exercise.Translate(exercise.ToFrench),
      prompt: id,
      accepted: [id],
      answer_language: answer.French,
      french: id,
      level: lexicon.A1,
    )
  }
  list.map(["first", "second", "third"], fn(id) {
    let lesson =
      lesson.Lesson(
        id:,
        level: lexicon.A1,
        title: id,
        topic: "",
        note: [],
        parts: [],
      )
    let exercises =
      list.map([1, 2, 3, 4, 5], fn(n) { exercise(id <> int.to_string(n)) })
    #(lesson, exercises)
  })
}

/// Progress with `count` exercises of each named lesson in `box`.
fn knowing(progress: Progress, lesson: String, count: Int, box: Int) {
  let cards =
    int.range(from: 1, to: count + 1, with: progress.cards, run: fn(cards, n) {
      dict.insert(
        cards,
        lesson <> int.to_string(n),
        CardState(box:, due: 0, reviews: 1, lapses: 0),
      )
    })
  Progress(..progress, cards:)
}

pub fn a_new_learner_starts_at_the_first_lesson_test() {
  assert course.current(progress.new(), small_course()) == 0
}

pub fn a_lesson_is_done_when_most_of_it_is_known_test() {
  let course = small_course()
  assert course.current(knowing(progress.new(), "first", 3, 1), course) == 0
  assert course.current(knowing(progress.new(), "first", 4, 1), course) == 1
  let both = progress.new() |> knowing("first", 4, 2) |> knowing("second", 5, 3)
  assert course.current(both, course) == 2
}

pub fn the_course_ends_after_the_last_lesson_test() {
  let course = small_course()
  let all =
    progress.new()
    |> knowing("first", 5, 2)
    |> knowing("second", 5, 2)
    |> knowing("third", 5, 2)
  assert course.current(all, course) == 3
  assert course.advance(all, course).course == Some("third")
}

pub fn the_course_does_not_go_back_test() {
  let course = small_course()
  let reached = course.advance(knowing(progress.new(), "first", 5, 2), course)
  assert reached.course == Some("second")
  // Forgetting the first lesson does not lock the second again.
  let forgotten = Progress(..reached, cards: dict.new())
  assert course.current(forgotten, course) == 1
}

pub fn an_unknown_lesson_id_starts_from_the_beginning_test() {
  let progress = Progress(..progress.new(), course: Some("removed"))
  assert course.current(progress, small_course()) == 0
}
