module aoc2018.day1;

import std.algorithm;
import std.conv: to;
import std.range;
import std.string: lineSplitter;

import containers;

auto puzzle1(string input) {
	return input
		.lineSplitter
		.map!(line => line.to!int)
		.fold!((acc, x) => acc + x)(0);
}

auto puzzle2(string input) {
	auto freqs = input
		.lineSplitter
		.map!(line => line.to!int)
		.cycle
		.cumulativeFold!((acc, x) => acc + x)(0);

	auto seen = HashSet!int(1);

	seen.insert(0);

	foreach (freq; freqs) {
		if (seen.contains(freq)) {
			return freq;
		}  else {
			seen.insert(freq);
		}
	}
  return -1;
}

void run() {
  import aoc2018.utils;

  runPuzzle!("day1", puzzle1)();
  runPuzzle!("day1", puzzle2)();
}