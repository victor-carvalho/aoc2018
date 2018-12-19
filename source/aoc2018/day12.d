module aoc2018.day12;

import std.algorithm;
import std.range;
import std.string;
import std.typecons;
import std.utf;

auto parseInput(string input) {
  auto lines = input.lineSplitter;
  auto initial = "...." ~ lines.front.find("#") ~ "....";
  char[char[]] transitions;
  foreach(line; lines.dropOne) {
    if (line.length > 0) {
      transitions[line[0..5]] = line[9];
    }
  }
  return tuple(initial.dup, transitions);
}

auto nextGeneration(char[] current, char[char[]] transitions) {
  auto next = new char[current.length + 1];
  next.fill('.');
  foreach(i; 2..current.length-2) {
    next[i] = transitions.get(current[i-2..i+3], '.');
  }
  return next;
}

auto score(char[] generation) {
  return generation.enumerate.filter!"a[1] == '#'".map!(a => a[0] - 4).sum;
}

auto puzzle1(char[] initial, char[char[]] transitions) {
  auto currentGeneration = initial;
  foreach(g; 0..20) {
    currentGeneration = currentGeneration.nextGeneration(transitions);
  }

  return currentGeneration.score;
}

auto puzzle2(char[] initial, char[char[]] transitions) {
  auto generations = 50_000_000_000;
  auto currentGeneration = initial;
  ulong repeatedDiff = 0;
  ulong lastDiff = 0;
  auto currentScore = currentGeneration.score;
  foreach(g; 0..generations) {
    auto nextGeneration = currentGeneration.nextGeneration(transitions);
    auto nextScore = nextGeneration.score;
    auto diff = nextScore - currentScore;
    repeatedDiff = diff == lastDiff ? repeatedDiff + 1 : 0;
    lastDiff = diff;
    if (repeatedDiff >= 10) {
      return nextScore + (generations - g - 1) * lastDiff;
    }
    currentGeneration = nextGeneration;
    currentScore = nextScore;
  }

  return currentGeneration.score;
}

void run() {
  import aoc2018.utils;

  auto state = readInput(__MODULE__).parseInput;
  runPuzzle!(__MODULE__, puzzle1)(state.expand);
  runPuzzle!(__MODULE__, puzzle2)(state.expand);
}