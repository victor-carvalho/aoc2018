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

auto puzzle1(Range)(Range input)
if (isInputRange!Range && is(ElementType!Range == int[])) {
  auto grid = initGrid(1000, 1000);
  auto assignments = input.map!(array => tuple(array[1], array[2], array[1] + array[3], array[2] + array[4]));

  foreach(rowStart, colStart, rows, cols; assignments) {
    foreach(row; rowStart..rows) {
      foreach(col; colStart..cols) {
        grid[row][col] += 1;
      }
    }
  }

  int cells = 0;
  foreach(row; 0..1000) {
    foreach(col; 0..1000) {
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

auto puzzle2(Range)(Range input)
if (isInputRange!Range && is(ElementType!Range == int[])) {
  auto assignments = input.array;

  auto overlaped = assignments.map!(_ => false).array;

  foreach(i; 0..assignments.length) {
    auto x = assignments[i];
    foreach(j; (i+1)..assignments.length) {
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

  auto input = readInput(__MODULE__)
    .lineSplitter
    .map!(line => line.matchFirst(reg).drop(1).map!(m => m.to!int).array);
  runPuzzle!(__MODULE__, puzzle1)(input);
  runPuzzle!(__MODULE__, puzzle2)(input);
}