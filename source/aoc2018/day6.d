module aoc2018.day6;

import std.algorithm;
import std.math: abs;
import std.range;
import std.string;
import std.typecons;
import std.utf;

alias Point = Tuple!(int, int);

auto distance(Point p1, Point p2) {
  return abs(p1[0] - p2[0]) + abs(p1[1] - p2[1]);
}

auto parsePoints(string input) {
  return input.lineSplitter
    .map!(line => line.split(",").map!"a.strip.to!int".array)
    .map!"tuple(a[0], a[1])"
    .array;
}

auto puzzle1(Tuple!(int,int)[] points) {
  auto xMax = points.map!"a[0]".maxElement;
  auto yMax = points.map!"a[1]".maxElement;
  auto areas = new int[points.length];

  for(int x = 0; x <= xMax; x++) {
    for (int y = 0; y <= yMax; y++) {
      auto c = tuple(x,y);
      int idx = -1;
      int min = int.max;
      foreach(i, d; points.map!(p => distance(c, p)).enumerate) {
        if (d < min) {
          min = d;
          idx = cast(int)(i); 
        } else if (d == min) {
          idx = -1;
        }
      }

      if (idx >= 0) {
        if (x == 0 || x == xMax || y == 0 || y == yMax)
          areas[idx] = -1;
        else if (areas[idx] >= 0)
          areas[idx] += 1;
      }
    }
  }
  return areas.maxElement;
}

auto puzzle2(Tuple!(int,int)[] points) {
  auto xs = points.map!"a[0]".maxElement.iota;
  auto ys = points.map!"a[1]".maxElement.iota;

  return cartesianProduct(xs,ys)
    .map!(c => points.map!(p => distance(c,p)).sum)
    .filter!"a < 10000"
    .count;
}

void run() {
  import aoc2018.utils;

  auto input = readInput(__MODULE__).parsePoints;
  runPuzzle!(__MODULE__, puzzle1)(input);
  runPuzzle!(__MODULE__, puzzle2)(input);
}