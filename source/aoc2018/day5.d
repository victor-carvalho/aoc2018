module aoc2018.day5;

import std.algorithm;
import std.container.array;
import std.math: abs;
import std.range;
import std.string;
import std.utf;

auto reactsWith(char a, char b) {
  return abs(a - b) == 32;
}

auto fullyReact(Range)(Range input)
if (isInputRange!Range && (is(ElementType!Range == char) || is(ElementType!Range == immutable(char)))) {
  auto stack = Array!char(input.front);
  foreach(c; input.drop(1)) {
    if (!stack.empty && c.reactsWith(stack.back)) {
      stack.removeBack();
    } else {
      stack.insertBack(c);
    }
  }

  return stack.length;
}

auto puzzle1(string input) {
  return input.strip.byChar.fullyReact;
}

auto puzzle2(string input) {
  auto source = input.strip.byChar;
  return "abcdefghijlmnopqrstuvxz"
    .byChar
    .map!((u => source.filter!(c => c.toLower != u).fullyReact))
    .minElement;
}

void run() {
  import aoc2018.utils;

  runPuzzle!("day5", puzzle1)();
  runPuzzle!("day5", puzzle2)();
}