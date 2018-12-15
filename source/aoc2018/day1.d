module aoc2018.day1;

import std.algorithm;
import std.conv: to;
import std.range;
import std.string: lineSplitter;

import containers;

auto puzzle1(Range)(Range input)
if (isInputRange!Range && is(ElementType!Range == int)) {
	return input.fold!((acc, x) => acc + x)(0);
}

auto puzzle2(Range)(Range input)
if (isInputRange!Range && is(ElementType!Range == int)) {
	auto freqs = input.cycle.cumulativeFold!((acc, x) => acc + x)(0);

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

	auto input = readInput(__MODULE__).lineSplitter.map!(line => line.to!int);
  runPuzzle!(__MODULE__, puzzle1)(input);
  runPuzzle!(__MODULE__, puzzle2)(input);
}