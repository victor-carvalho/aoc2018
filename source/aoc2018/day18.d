module aoc2018.day18;

import std.algorithm;
import std.conv;
import std.range;
import std.regex;
import std.string;
import std.typecons;

import containers;

alias Generation = Acre[][];

enum Acre: ubyte {
  Open,
  Wooded,
  Lumberyard
}

auto advanceGeneration(Generation gen, size_t x, size_t y) {
  int[3] neighborCount;
  auto current = gen[x][y];
  for(auto i = -1; i <= 1; i++) {
    for(auto j = -1; j <= 1; j++) {
      auto r = x + i;
      auto c = y + j;
      if ((i != 0 || j != 0) && r >= 0 && c >= 0 && r < gen.length && c < gen[r].length) {
        neighborCount[gen[r][c]] += 1;
      }
    }
  }

  final switch(current) {
    case Acre.Open:
      return neighborCount[Acre.Wooded] >= 3 ? Acre.Wooded : Acre.Open;
    case Acre.Wooded:
      return neighborCount[Acre.Lumberyard] >= 3 ? Acre.Lumberyard : Acre.Wooded;
    case Acre.Lumberyard:
      return neighborCount[Acre.Lumberyard] >= 1 && neighborCount[Acre.Wooded] >= 1 ? Acre.Lumberyard : Acre.Open;
  }
}

auto nextGeneration(Generation previous) {
  auto rows = previous.length;
  auto cols = previous[0].length;
  auto current = new Acre[][](rows, cols);
  foreach(i; 0..rows) {
    foreach(j; 0..cols) {
      current[i][j] = previous.advanceGeneration(i, j);
    }
  }
  return current;
}

auto calculateValue(Generation gen) {
  auto rows = gen.length;
  auto cols = gen[0].length;
  int[3] typeCount;
  foreach(r; 0..rows) {
    foreach(c; 0..cols) {
      typeCount[gen[r][c]] += 1;
    }
  }
  return typeCount[Acre.Wooded] * typeCount[Acre.Lumberyard];
}

auto puzzle1(Generation initial) {
  auto current = initial;
  foreach(t; 0..10) {
    current = nextGeneration(current);
  }
  return calculateValue(current);
}

auto puzzle2(Generation initial) {
  auto current = initial;
  auto cycleStart = 0;
  auto cycleLength = 0;
  auto generations = HashMap!(const Generation, int)();
  generations[current] = 0;
  foreach(t; 1..1_000_000_001) {
    current = nextGeneration(current);
    auto  ptr = current in generations;
    if (ptr !is null) {
      cycleStart = *ptr;
      cycleLength = t - cycleStart;
      break;
    } else {
      generations[current] = t;
    }
  }

  auto cyclePos = (1_000_000_000 - cycleStart) % cycleLength;
  if (cyclePos == 0)
    return calculateValue(current);
  
  foreach(t; 1..cyclePos+1) {
    current = nextGeneration(current);
  }

  return calculateValue(current);
}

auto charToAcre(char c) {
  switch(c) {
    case '.':
      return Acre.Open;
    case '|':
      return Acre.Wooded;
    case '#':
      return Acre.Lumberyard;
    default:
      assert(false);
  }
}

auto parseInput(string input) {
  auto lines = input.lineSplitter.map!(line => line.stripRight).array;
  auto rows = lines.length;
  auto cols = lines[0].length;
  auto grid = new Acre[][](rows, cols);
  foreach(i; 0..rows) {
    foreach(j; 0..cols) {
      grid[i][j] = charToAcre(lines[i][j]);
    }
  }
  return grid;
}

void run() {
  import aoc2018.utils;

  auto input = readInput(__MODULE__).parseInput;
  runPuzzle!(__MODULE__, puzzle1)(input);
  runPuzzle!(__MODULE__, puzzle2)(input);
}
