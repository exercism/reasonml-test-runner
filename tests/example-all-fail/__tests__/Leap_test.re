open Jest;
open Expect;
open Leap;

describe("Leap", () => {
  test("year not divisible by 4 in common year", () =>
    expect(isLeapYear(2015)) |> toBe(false)
  );
  test("year divisible by 4, not divisible by 100 in leap year", () =>
    expect(isLeapYear(1996)) |> toBe(true)
  );
})
