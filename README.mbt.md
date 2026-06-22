# shiguri-01/todotxt

A small parser for the [todo.txt](https://github.com/todotxt/todo.txt).

## Installation

```sh
moon add shiguri-01/todotxt
```

## Usage

```moonbit nocheck
///|
let task = @tododottxt.parse_task(
  "(A) 2026-06-22 Write README +tododottxt @dev",
)
```

Empty input and multi-line input raise `ParseError`.

## License

[Apache-2.0](./LICENSE)
