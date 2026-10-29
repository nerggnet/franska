//// The course: lessons in the order a learner takes them, each with a
//// grammar note in Swedish and the exercises it practises. A lesson is
//// done when most of its exercises are known, and then the next one opens.
////
//// The lessons are in `franska/course/a1` and `franska/course/a2`. Lesson
//// ids are stored with the learner's progress (the furthest lesson
//// reached): never rename or reuse one. Every entry and number belongs to
//// exactly one lesson, so new content must be placed in a lesson too.

import franska/course/a1
import franska/course/a2
import franska/course/lesson.{type Lesson}
import franska/exercise.{type Drill, type Exercise}
import franska/progress.{type Progress, Progress}
import franska/srs
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result

/// Every lesson, easier levels first.
pub fn lessons() -> List(Lesson) {
  list.append(a1.lessons(), a2.lessons())
}

/// A lesson is done when this share (in per cent) of its exercises is known.
pub const done_share = 80

// PROGRESS --------------------------------------------------------------------

/// Every lesson with its exercises, in course order. Each exercise belongs
/// to the first lesson that has it. Build it once, like the catalog.
pub fn build(all: List(Exercise)) -> List(#(Lesson, List(Exercise))) {
  let lessons = lessons()
  let owners: Dict(String, List(#(Int, List(Drill)))) =
    lessons
    |> list.index_map(fn(lesson, index) {
      list.flat_map(lesson.parts, fn(part) {
        list.map(part.entries, fn(entry) { #(entry, #(index, part.drills)) })
      })
    })
    |> list.flatten
    |> list.fold(dict.new(), fn(acc, pair) {
      dict.upsert(acc, pair.0, fn(found) {
        list.append(option.unwrap(found, []), [pair.1])
      })
    })
  let by_lesson =
    list.fold(all, dict.new(), fn(acc, e) {
      let drill = exercise.drill(e.kind)
      let owner =
        dict.get(owners, e.entry_id)
        |> result.try(list.find(_, fn(owner) { list.contains(owner.1, drill) }))
      case owner {
        Ok(#(index, _)) ->
          dict.upsert(acc, index, fn(found) { [e, ..option.unwrap(found, [])] })
        Error(Nil) -> acc
      }
    })
  list.index_map(lessons, fn(lesson, index) {
    #(lesson, dict.get(by_lesson, index) |> result.unwrap([]) |> list.reverse)
  })
}

/// How many of the exercises the learner knows.
pub fn known(progress: Progress, exercises: List(Exercise)) -> Int {
  list.count(exercises, fn(e) {
    case dict.get(progress.cards, e.id) {
      Ok(card) -> srs.is_known(card)
      Error(Nil) -> False
    }
  })
}

pub fn is_done(progress: Progress, exercises: List(Exercise)) -> Bool {
  known(progress, exercises) * 100 >= done_share * list.length(exercises)
}

/// The index of the lesson the learner is at: the first lesson that is not
/// done, counting from the furthest one reached, so that the course never
/// goes back. It is the number of lessons once the course is done.
pub fn current(
  progress: Progress,
  course: List(#(Lesson, List(Exercise))),
) -> Int {
  let start = case progress.course {
    Some(id) ->
      list.index_map(course, fn(pair, index) { #(pair.0.id, index) })
      |> list.key_find(id)
      |> result.unwrap(0)
    None -> 0
  }
  let done =
    course
    |> list.drop(start)
    |> list.take_while(fn(pair) { is_done(progress, pair.1) })
    |> list.length
  start + done
}

/// Remembers the furthest lesson reached.
pub fn advance(
  progress: Progress,
  course: List(#(Lesson, List(Exercise))),
) -> Progress {
  let index = int.min(current(progress, course), list.length(course) - 1)
  case list.drop(course, index) {
    [#(lesson, _), ..] -> Progress(..progress, course: Some(lesson.id))
    [] -> progress
  }
}
