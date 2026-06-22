///|
test "parse active task" {
  let task = @tododottxt.parse_task(
    "(A) 2026-06-22 Write parser +todotxt @home due:2026-06-30",
  )
  assert_true(task.status == @tododottxt.Todo(priority=Some("A")))
  assert_true(
    task.prepended_date == Some(@tododottxt.Date(year=2026, month=6, day=22)),
  )
  assert_eq(task.description, "Write parser +todotxt @home due:2026-06-30")
  assert_true(task.projects == ["todotxt"])
  assert_true(task.contexts == ["home"])
  assert_true(task.metadata.get("due") == Some("2026-06-30"))
}

///|
test "parse completed task" {
  let task = @tododottxt.parse_task(
    "x 2026-06-22 2026-06-01 Ship first version +release",
  )
  assert_true(
    task.status ==
    @tododottxt.Done(
      completed_date=@tododottxt.Date(year=2026, month=6, day=22),
    ),
  )
  assert_true(
    task.prepended_date == Some(@tododottxt.Date(year=2026, month=6, day=1)),
  )
  assert_eq(task.description, "Ship first version +release")
  assert_true(task.projects == ["release"])
}

///|
test "parse completed task with completion date only" {
  let task = @tododottxt.parse_task("x 2026-06-22 task")
  assert_true(
    task.status ==
    @tododottxt.Done(
      completed_date=@tododottxt.Date(year=2026, month=6, day=22),
    ),
  )
  assert_true(task.prepended_date == None)
  assert_eq(task.description, "task")
}

///|
test "parse date rejects impossible days" {
  let invalid = @tododottxt.parse_task("2026-02-29 task")
  assert_true(invalid.prepended_date == None)
  assert_eq(invalid.description, "2026-02-29 task")
  let valid = @tododottxt.parse_task("2024-02-29 task")
  assert_true(
    valid.prepended_date == Some(@tododottxt.Date(year=2024, month=2, day=29)),
  )
  assert_eq(valid.description, "task")
}

///|
test "date constructor rejects impossible days" {
  let date = @tododottxt.Date(year=2024, month=2, day=29)
  assert_true(date == @tododottxt.Date(year=2024, month=2, day=29))
  try @tododottxt.Date(year=2026, month=2, day=29) catch {
    Failure(_) => ()
  } noraise {
    _ => fail("invalid date must fail")
  }
}

///|
test "parse date requires exact yyyy-mm-dd syntax" {
  let short_month = @tododottxt.parse_task("2026-6-22 task")
  assert_true(short_month.prepended_date == None)
  assert_eq(short_month.description, "2026-6-22 task")
  let incomplete = @tododottxt.parse_task("x 2026-6-22 task")
  assert_true(incomplete.status == @tododottxt.Todo(priority=None))
  assert_eq(incomplete.description, "x 2026-6-22 task")
}

///|
test "parse empty line error" {
  try @tododottxt.parse_task("") catch {
    error => assert_true(error is @tododottxt.EmptyLine)
  } noraise {
    _ => fail("empty line must fail")
  }
  try @tododottxt.parse_task("   ") catch {
    error => assert_true(error is @tododottxt.EmptyLine)
  } noraise {
    _ => fail("blank line must fail")
  }
}

///|
test "parse rejects multiple lines" {
  try @tododottxt.parse_task("first task\nsecond task") catch {
    error => assert_true(error is @tododottxt.MultipleLines)
  } noraise {
    _ => fail("multiple lines must fail")
  }
}

///|
test "parse rejects trailing line break" {
  try @tododottxt.parse_task("task\n") catch {
    error => assert_true(error is @tododottxt.MultipleLines)
  } noraise {
    _ => fail("line break must fail")
  }
}

///|
test "parse trims surrounding spaces" {
  let task = @tododottxt.parse_task("  (A) task  ")
  assert_true(task.status == @tododottxt.Todo(priority=Some("A")))
  assert_eq(task.description, "task")
}

///|
test "parse x followed by non-date as incomplete task" {
  let done = @tododottxt.parse_task("x done without a date")
  assert_true(done.status == @tododottxt.Todo(priority=None))
  assert_true(done.prepended_date == None)
  assert_eq(done.description, "x done without a date")
  let must = @tododottxt.parse_task("x must be a positive number")
  assert_true(must.status == @tododottxt.Todo(priority=None))
  assert_true(must.prepended_date == None)
  assert_eq(must.description, "x must be a positive number")
}

///|
test "parse priority requires exact uppercase single-letter syntax" {
  let lowercase = @tododottxt.parse_task("(a) task")
  assert_true(lowercase.status == @tododottxt.Todo(priority=None))
  assert_eq(lowercase.description, "(a) task")
  let too_long = @tododottxt.parse_task("(AA) task")
  assert_true(too_long.status == @tododottxt.Todo(priority=None))
  assert_eq(too_long.description, "(AA) task")
}

///|
test "parse project context and metadata tokens" {
  let task = @tododottxt.parse_task(
    "task +proj:alpha @ctx:home due.date:2026-06-30",
  )
  assert_true(task.projects == ["proj:alpha"])
  assert_true(task.contexts == ["ctx:home"])
  assert_true(task.metadata.get("due.date") == Some("2026-06-30"))
}

///|
test "parse metadata requires one colon and non-empty key value" {
  let task = @tododottxt.parse_task(
    "task due:2026-06-30 bad:value:extra :value key:",
  )
  assert_true(task.metadata.get("due") == Some("2026-06-30"))
  assert_true(task.metadata.get("bad") == None)
  assert_true(task.metadata.get("") == None)
  assert_true(task.metadata.get("key") == None)
}

///|
test "parse annotations reject embedded whitespace" {
  let task = @tododottxt.parse_task(
    "task @home\twork +proj\talpha due:tomorrow\tsoon",
  )
  assert_true(task.contexts == [])
  assert_true(task.projects == [])
  assert_true(task.metadata.get("due") == None)
}
