module aoc2018.day3;

import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.regex;
import std.string;
import std.typecons;

auto reg = regex(r"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)");

auto initGrid(int rows, int cols) {
  auto buff = new int[rows * cols];
  return buff.chunks(cols);
}

auto puzzle1(string input) {
  auto grid = initGrid(1000, 1000);

  auto assignments = input.lineSplitter
    .map!(line => line.matchFirst(reg).drop(2).map!(m => m.to!int).array)
    .map!(array => tuple(array[0], array[1], array[0] + array[2], array[1] + array[3]));

  foreach(rowStart, colStart, rows, cols; assignments) {
    for(int row = rowStart; row < rows; row++) {
      for(int col = colStart; col < cols; col++) {
        grid[row][col] += 1;
      }
    }
  }

  int cells = 0;
  for(int row = 0; row < 1000; row++) {
    for(int col = 0; col < 1000; col++) {
      if (grid[row][col] > 1) {
        cells += 1;
      }
    }
  }

  return cells;
}

auto overlaps (int[] x, int[] y) {
  return max(x[1], y[1]) < min(x[1] + x[3], y[1] + y[3]) && max(x[2], y[2]) < min(x[2] + x[4], y[2] + y[4]);
}

auto puzzle2(string input) {
  auto assignments = input.lineSplitter
    .map!(line => line.matchFirst(reg).drop(1).map!(m => m.to!int).array)
    .array;

  auto overlaped = assignments.map!(_ => false).array;

  for (int i = 0; i < assignments.length; i++) {
    auto x = assignments[i];
    for (int j = i + 1; j < assignments.length; j++) {
      auto y = assignments[j];
      if (x.overlaps(y)) {
        overlaped[i] = true;
        overlaped[j] = true;
      }
    }
    if (!overlaped[i]) return x[0];
  }

  return 0;
}

void run() {
  import aoc2018.utils;

  runPuzzle!("day3", puzzle1)();
  runPuzzle!("day3", puzzle2)();
}