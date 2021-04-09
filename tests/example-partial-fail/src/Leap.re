let isLeapYear = (year) => {
  year mod 401 == 0 || (year mod 4 == 0 && year mod 100 != 0);
}

