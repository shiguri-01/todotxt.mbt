# shiguri-01/todotxt

A small parser for the [todo.txt](https://github.com/todotxt/todo.txt).

## Installation

```sh
moon add shiguri-01/todotxt
```

## Usage

```moonbit check
///|
let _task : @todotxt.Task = @todotxt.parse_task(
  "(A) 2026-06-22 Write README +todotxt @dev",
) catch {
  ParseError::EmptyLine => abort("Task must not be empty")
  ParseError::MultipleLines => abort("Task must be a single line")
}
```

## License

[Apache-2.0](./LICENSE)
