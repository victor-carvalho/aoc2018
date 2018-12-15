module aoc2018.day9;

import std.algorithm;
import std.conv: to;
import std.range;
import std.regex;
import std.string;

auto reg = regex(r"(\d+) players; last marble is worth (\d+) points");

private class Marble {
  Marble prev;
  Marble next;
  size_t value;

  this(size_t value) {
    this(value, this, this);
  }

  this(size_t value, Marble prev, Marble next) {
    this.value = value;
    this.prev = prev;
    this.next = next;
  }
}

class Circle {
  private Marble current;

  this() {
    this.current = new Marble(0);
  }

  void insert(size_t value) {
    auto prev = this.current.next;
    auto next = this.current.next.next;
    auto node = new Marble(value, prev, next);
    prev.next = node;
    next.prev = node;
    this.current = node;
  }

  size_t remove() {
    for (size_t i = 0; i < 7; i++)
      this.current = this.current.prev;
    auto node = this.current;
    node.next.prev = node.prev;
    node.prev.next = node.next;
    this.current = node.next;
    return node.value;
  }
}

auto maxScore(size_t numPlayers, size_t highestMarble) {
  auto players = new size_t[numPlayers];
  auto circle = new Circle();

  for(size_t i = 1; i <= highestMarble; i++) {
    if (i % 23 == 0) {
      players[i % numPlayers] += i + circle.remove();
    } else {
     circle.insert(i);
    }
  }

  return players.maxElement;
}

auto puzzle1(size_t[] input) {
  return maxScore(input[0], input[1]);
}

auto puzzle2(size_t[] input) {
  return maxScore(input[0], input[1] * 100);
}

void run() {
  import aoc2018.utils;

  auto input = readInput(__MODULE__).matchFirst(reg).drop(1).map!"a.to!size_t".array;
  runPuzzle!(__MODULE__, puzzle1)(input);
  runPuzzle!(__MODULE__, puzzle2)(input);
}
