///|
pub struct Date {
  year : Int
  month : Int
  day : Int
} derive(Eq, Debug)

///|
pub fn Date::Date(year~ : Int, month~ : Int, day~ : Int) -> Date raise Failure {
  guard day >= 1 && day <= days_in_month(year, month) else {
    raise Failure("invalid date")
  }
  { year, month, day }
}

///|
fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 if is_leap_year(year) => 29
    2 => 28
    _ => 0
  }
}

///|
fn is_leap_year(year : Int) -> Bool {
  year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
}
