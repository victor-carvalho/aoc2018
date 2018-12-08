module aoc2018.day2;

import std.algorithm;
import std.range;
import std.string: lineSplitter;
import std.typecons;
import std.utf: byChar;

import containers;

auto countOccurrences(string line) {
  auto count = HashMap!(char,int)();

	foreach (c; line.byChar) {
		auto x = count.getOrAdd(c, 0);
		count[c] = *x + 1;
	}

	bool has2 = 0;
	bool has3 = 0;
	foreach (v; count.byValue) {
		if (v == 2) {
			has2 = 1;
		} else if (v == 3) {
			has3 = 1;
		}
	}
	return tuple(has2, has3);
}

auto puzzle1(string input) {
  auto codes = input.lineSplitter.array;

  auto has2 = 0;
  auto has3 = 0;
  foreach(code; codes) {
    auto results = countOccurrences(code);
    has2 += results[0];
    has3 += results[1];
  }

  return has2 * has3;
}

auto puzzle2(string input) {
	auto codes = input.lineSplitter.array;

	for (int i = 0; i < codes.length; i++) {
		for (int j = 0; j < codes.length; j++) {
			auto code1 = codes[i];
			auto code2 = codes[j];
			int diffpos = -1;
			for (int k = 0; k < code1.length; k++) {
				if (code1[k] != code2[k]) {
					if (diffpos != -1) {
						diffpos = -1;
						break;
					}
					diffpos = k;
				}
			}
			if (diffpos != -1) {
				return code1[0..diffpos] ~ code1[diffpos+1..$];
			}
		}
	}
	return "";
}

void run() {
  import aoc2018.utils;
  runPuzzle!("day2", puzzle1);
  runPuzzle!("day2", puzzle2);
}
