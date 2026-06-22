///|
pub(all) enum Status {
  Todo(priority~ : String?)
  Done(completed_date~ : Date)
} derive(Eq, Debug)

///|
pub(all) struct Task {
  status : Status
  prepended_date : Date?
  description : String
  contexts : Array[String]
  projects : Array[String]
  metadata : Map[String, String]
} derive(Eq, Debug)

///|
pub(all) suberror ParseError {
  EmptyLine
  MultipleLines
} derive(Eq, Debug)

///|
pub fn parse_task(line : String) -> Task raise ParseError {
  let input = line.trim(chars=" ").to_owned()
  guard !input.is_empty() else { raise EmptyLine }
  guard !contains_line_break(input) else { raise MultipleLines }
  let words = split_words(input)
  let (status, index_after_status) = parse_status(words)
  let (prepended_date, index_after_date) = parse_prepended_date(
    words, index_after_status,
  )
  let description_words = words[index_after_date:]
  let (contexts, projects, metadata) = collect_annotations(description_words)
  {
    status,
    prepended_date,
    description: description_words.join(" "),
    contexts,
    projects,
    metadata,
  }
}

///|
fn parse_date(text : String) -> Date? {
  guard text =~ (
    re"^" +
    (re"[[:digit:]]{4}" as year_text) +
    re"-" +
    (re"[[:digit:]]{2}" as month_text) +
    re"-" +
    (re"[[:digit:]]{2}" as day_text) +
    re"$"
  ) else {
    None
  }
  try {
    let year : Int = @string.from_str(year_text)
    let month : Int = @string.from_str(month_text)
    let day : Int = @string.from_str(day_text)
    Date(year~, month~, day~) |> Some
  } catch {
    _ => None
  }
}

///|
fn parse_status(words : Array[String]) -> (Status, Int) {
  if words.length() >= 2 &&
    words[0] == "x" &&
    parse_date(words[1]) is Some(date) {
    (Done(completed_date=date), 2)
  } else {
    match parse_priority(words[0]) {
      Some(priority) => (Todo(priority=Some(priority)), 1)
      None => (Todo(priority=None), 0)
    }
  }
}

///|
fn parse_prepended_date(words : Array[String], index : Int) -> (Date?, Int) {
  if words.get(index) is Some(word) && parse_date(word) is Some(date) {
    (Some(date), index + 1)
  } else {
    (None, index)
  }
}

///|
fn collect_annotations(
  words : ArrayView[String],
) -> (Array[String], Array[String], Map[String, String]) {
  let contexts : Array[String] = []
  let projects : Array[String] = []
  let metadata : Map[String, String] = {}
  for word in words {
    if parse_context(word) is Some(context) {
      contexts.push(context)
    }
    if parse_project(word) is Some(project) {
      projects.push(project)
    }
    if parse_metadata(word) is Some((key, value)) {
      metadata[key] = value
    }
  }
  (contexts, projects, metadata)
}

///|
fn split_words(input : String) -> Array[String] {
  let words : Array[String] = []
  for word in input.split(" ") {
    if !word.is_empty() {
      words.push(word.to_owned())
    }
  }
  words
}

///|
fn parse_priority(word : String) -> String? {
  guard word =~ (re"^" + re"[(]" + (re"[A-Z]" as priority) + re"[)]" + re"$") else {
    None
  }
  Some(priority.to_string())
}

///|
fn parse_context(word : String) -> String? {
  guard word =~ (re"^" + re"@" + (re"[^[:space:]]+" as context) + re"$") else {
    None
  }
  Some(context.to_owned())
}

///|
fn parse_project(word : String) -> String? {
  guard word =~ (re"^" + re"[+]" + (re"[^[:space:]]+" as project) + re"$") else {
    None
  }
  Some(project.to_owned())
}

///|
fn parse_metadata(word : String) -> (String, String)? {
  guard word =~ (
    re"^" +
    (re"[^[:space:]:]+" as key) +
    re":" +
    (re"[^[:space:]:]+" as value) +
    re"$"
  ) else {
    None
  }
  Some((key.to_owned(), value.to_owned()))
}

///|
fn contains_line_break(text : String) -> Bool {
  text.contains_char('\r') || text.contains_char('\n')
}
