//// One practice round: a queue of exercises worked through in order. A
//// wrongly answered exercise comes back a few exercises later, so every
//// round ends with each exercise answered at least almost right.

import franska/answer.{type Grade, Almost, Correct, Wrong}
import franska/exercise.{type Exercise}
import gleam/list

pub type Session {
  Session(queue: List(Exercise), answers: List(#(Exercise, Grade)))
}

pub type Summary {
  Summary(correct: Int, almost: Int, wrong: Int)
}

/// How many exercises later a wrongly answered exercise comes back.
const retry_after = 3

pub fn new(exercises: List(Exercise)) -> Session {
  Session(queue: exercises, answers: [])
}

pub fn current(session: Session) -> Result(Exercise, Nil) {
  list.first(session.queue)
}

pub fn is_finished(session: Session) -> Bool {
  session.queue == []
}

/// Records the grade for the current exercise and moves on to the next.
pub fn record(session: Session, grade: Grade) -> Session {
  case session.queue {
    [] -> session
    [exercise, ..rest] -> {
      let queue = case grade {
        Wrong(..) -> {
          let #(before, after) = list.split(rest, retry_after)
          list.flatten([before, [exercise], after])
        }
        Correct | Almost(..) -> rest
      }
      Session(queue:, answers: [#(exercise, grade), ..session.answers])
    }
  }
}

/// True until the exercise has been answered once in this round. Only first
/// attempts count towards spaced repetition, since a retry comes right after
/// seeing the answer.
pub fn is_first_attempt(session: Session, exercise: Exercise) -> Bool {
  !list.any(session.answers, fn(answer) { { answer.0 }.id == exercise.id })
}

/// Counts every answer given, including retries.
pub fn summary(session: Session) -> Summary {
  list.fold(session.answers, Summary(0, 0, 0), fn(summary, answer) {
    case answer.1 {
      Correct -> Summary(..summary, correct: summary.correct + 1)
      Almost(..) -> Summary(..summary, almost: summary.almost + 1)
      Wrong(..) -> Summary(..summary, wrong: summary.wrong + 1)
    }
  })
}
