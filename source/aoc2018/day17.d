module aoc2018.day17;

import std.algorithm;
import std.conv;
import std.range;
import std.regex;
import std.stdio;
import std.string;
import std.typecons;

import containers;

enum Tile: ubyte {
  Sand,
  Clay,
  CalmWater,
  RunningWater
}

auto puzzle(Tile[][] tiles, int xMin, int xMax, int yMin, int yMax) {
  auto queue = CyclicBuffer!(Tuple!(int,int))();
  auto initialX = 499 - xMin + 2;
  queue.insertBack(tuple(initialX, 0));
  tiles[0][initialX] = Tile.RunningWater;
  while(!queue.empty) {
    auto point = queue.front;
    queue.removeFront;
    auto x = point[0];
    auto y = point[1];
    if (y == (tiles.length - 1))
      continue;
    final switch(tiles[y+1][x]) {
      case Tile.Sand:
        tiles[y+1][x] = Tile.RunningWater;
        queue.insertBack(tuple(x,y+1));
        break;
      case Tile.RunningWater:
        break;
      case Tile.Clay:
      case Tile.CalmWater:
        auto blockedLeft = false;
        auto blockedRight = false;
        auto left = x - 1;
        auto right = x + 1;
        for (;; left--) {
          auto tile = tiles[y][left];
          if (tile == Tile.Sand) {
            if (tiles[y+1][left] == Tile.Sand) {
              queue.insertBack(tuple(left, y));
              break;
            }
          } else if (tile == Tile.RunningWater && tiles[y+1][left] == Tile.Sand) {
            break;
          } else {
            blockedLeft = true;
            left++;
            break;
          }
        }
        for (;; right++) {
          auto tile = tiles[y][right];
          if (tile == Tile.Sand) {
            if (tiles[y+1][right] == Tile.Sand) {
              queue.insertBack(tuple(right, y));
              break;
            }
          } else if (tile == Tile.RunningWater && tiles[y+1][right] == Tile.Sand) {
            break;
          } else {
            blockedRight = true;
            right--;
            break;
          }
        }
        if (blockedLeft && blockedRight) {
          queue.insertBack(tuple(x, y - 1));
          tiles[y][left..right + 1] = Tile.CalmWater;
        } else {
          tiles[y][left..right + 1] = Tile.RunningWater;
        }
    }
  }
  auto waterCount = 0;
  auto calmWaterCount = 0;
  // auto buffer = new char[](tiles[0].length);
  foreach(n, row; tiles) {
    foreach(i; 0..row.length) {
      final switch(row[i]) {
        case Tile.Sand:
          // buffer[i] = '.';
          break;
        case Tile.Clay:
          // buffer[i] = '#';
          break;
        case Tile.RunningWater:
          // buffer[i] = '|';
          waterCount += 1;
          break;
        case Tile.CalmWater:
          // buffer[i] = '~';
          waterCount += 1;
          calmWaterCount += 1;
          break;
      }
    }
    // writeln(buffer);
    if (n == 0) {
      waterCount = 0;
      calmWaterCount = 0;
    }
  }
  return tuple(waterCount, calmWaterCount);
}

static reg = regex(r"(\w+)=(\d+),\s+(\w+)=(\d+)\.\.(\d+)");

auto parseInput(string input) {
  auto slices = input.lineSplitter
    .map!(line => line.matchFirst(reg).drop(1))
    .map!(match => tuple(match[0], match[1].to!int, match[3].to!int, match[4].to!int))
    .array;
  auto xMin = int.max, xMax = int.min, yMin = int.max, yMax = int.min;
  foreach(slice; slices) {
    if (slice[0] == "y") {
      xMin = min(slice[2], xMin);
      xMax = max(slice[3], xMax);
      yMin = min(slice[1], yMin);
      yMax = max(slice[1], yMax);
    } else {
      xMin = min(slice[1], xMin);
      xMax = max(slice[1], xMax);
      yMin = min(slice[2], yMin);
      yMax = max(slice[3], yMax);
    }
  }
  auto tiles = new Tile[][](yMax - yMin + 2, xMax - xMin + 5);
  foreach(slice; slices) {
    if (slice[0] == "y") {
      tiles[slice[1] - yMin + 1][(slice[2] - xMin + 2)..(slice[3] - xMin + 3)] = Tile.Clay;
    } else {
      foreach(y; (slice[2] - yMin + 1)..(slice[3] - yMin + 2)) {
        tiles[y][slice[1] - xMin + 2] = Tile.Clay;
      }
    }
  }
  return tuple(tiles, xMin, xMax, yMin, yMax);
}

void run() {
  import aoc2018.utils;

  auto input = readInput(__MODULE__).parseInput;
  runPuzzle!(__MODULE__, puzzle)(input.expand);
}