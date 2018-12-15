module aoc2018.day10;

import arsd.png;

import std.algorithm;
import std.conv: to;
import std.math: abs;
import std.range;
import std.regex;
import std.string;
import std.typecons;

auto reg = regex(r"position=<([\s-]\d+), ([\s-]\d+)> velocity=<([\s-]\d+), ([\s-]\d+)>");

void generateImage(Tuple!(int,int)[] points) {
  auto xMin = points.minElement!"a[0]"[0];
  auto xMax = points.maxElement!"a[0]"[0];
  auto yMin = points.minElement!"a[1]"[1];
  auto yMax = points.maxElement!"a[1]"[1];
  int width = abs(xMax-xMin) + 1;
  int height = abs(yMax-yMin) + 1;
  
  auto image = new TrueColorImage(width, height);
  auto colorData = image.imageData.colors;
  foreach(p; points) {
    colorData[(p[0]-xMin) + (p[1]-yMin) * width] = Color.red();
  }
  writePng("test.png", image);
}

auto nextGen(Tuple!(int,int)[] points, Tuple!(int,int)[] velocities) {
  auto newgen = new Tuple!(int,int)[points.length];
  for(int i = 0; i < points.length; i++) {
    auto v = velocities[i];
    auto p = points[i];
    newgen[i] = tuple(p[0] + v[0], p[1] + v[1]);
  }
  return newgen;
}

auto puzzle(string input) {
  auto velocities = new Tuple!(int,int)[0];
  auto currentGen = new Tuple!(int,int)[0];
  foreach(p; input.lineSplitter.map!(l => l.matchFirst(reg).drop(1).map!(m => m.stripLeft.to!int).array)) {
    currentGen ~= tuple(p[0], p[1]);
    velocities ~= tuple(p[2], p[3]);
  }

  auto t = 0;
  size_t minArea = size_t.max;
  auto minGen = currentGen;
  
  // Arbitrary threshold
  foreach(g; 1..20_000) {
    auto xMin = int.max;
    auto xMax = int.min;
    auto yMin = int.max;
    auto yMax = int.min;
    auto nextGen = new Tuple!(int,int)[currentGen.length];
    foreach(i; 0..currentGen.length) {
      auto x = currentGen[i][0] + velocities[i][0];
      auto y = currentGen[i][1] + velocities[i][1];
      nextGen[i] = tuple(x,y);
      xMin = min(x, xMin);
      xMax = max(x, xMax);
      yMin = min(x, yMin);
      yMax = max(x, yMax);
    }
    auto area = cast(size_t)(xMax - xMin) * cast(size_t)(yMax - yMin);
    currentGen = nextGen;
    if (area < minArea) {
      t = g;
      minArea = area;
      minGen = currentGen;
    }
  }

  generateImage(minGen);
  return t;
}


void run() {
  import aoc2018.utils;

  runPuzzle!("day10", puzzle)();
}