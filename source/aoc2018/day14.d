module aoc2018.day14;

import std.algorithm;
import std.container.array;
import std.conv;
import std.range;
import std.stdio;

auto charDigit(int digit) {
  return cast(char)(digit + '0');
}

auto puzzle1(uint threshold) {
  auto scores = Array!ubyte(cast(ubyte)(3), cast(ubyte)(7));
  ulong elf1 = 0;
  ulong elf2 = 1;
  scores.reserve(threshold+50);
  while(scores.length < threshold + 10) {
    auto combinedScore = cast(ubyte)(scores[elf1] + scores[elf2]);
    if (combinedScore >= 10) {
      scores.insertBack(cast(ubyte)(combinedScore / 10));
      scores.insertBack(cast(ubyte)(combinedScore % 10));
    } else {
      scores.insertBack(combinedScore);
    }
    elf1 = (scores[elf1] + 1 + elf1) % scores.length;
    elf2 = (scores[elf2] + 1 + elf2) % scores.length;
  }
  return scores[threshold..threshold+10].map!charDigit;
}

auto puzzle2(uint threshold) {
  auto digits = threshold.to!string.map!"(a - '0').to!ubyte".array;
  auto digitsLen = digits.length; 
  auto scores = Array!ubyte(cast(ubyte)(3), cast(ubyte)(7));
  ulong elf1 = 0;
  ulong elf2 = 1;
  scores.reserve(threshold);

  auto found = -1L;
  while(found < 0) {
    ubyte combinedScore = cast(ubyte)(scores[elf1] + scores[elf2]);
    if (combinedScore >= 10) {
      scores.insertBack(cast(ubyte)(combinedScore / 10));
      scores.insertBack(cast(ubyte)(combinedScore % 10));
      if (scores.length > digits.length)
        found = scores[$-(digitsLen + 1)..$].countUntil(digits);
    } else {
      scores.insertBack(combinedScore);
      if (scores.length >= digits.length && scores[$-digitsLen..$].equal(digits))
        found = 1L;
    }
    elf1 = (scores[elf1] + 1 + elf1) % scores.length;
    elf2 = (scores[elf2] + 1 + elf2) % scores.length;
  }
  return scores.length - digitsLen + found - 1;
}

void run() {
  import aoc2018.utils;

  runPuzzle!(__MODULE__, puzzle1)(824501u);
  runPuzzle!(__MODULE__, puzzle2)(824501u);
}
