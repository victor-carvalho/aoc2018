import aoc2018.utils;
import std.meta;
import std.stdio;

alias days = AliasSeq!("day1", "day2", "day3", "day4", "day5", "day6", "day7", "day8", "day9");

void main(string[] args) {
	if (args.length > 1) {
		label: switch(args[1]) {
			static foreach(day; days) {
				case day:
					runDay!day();
					break label;
			}
			default:
				writeln("Invalid day to run");
				break;
		}
	} else {
		writeln("No day selected, running all days");
		static foreach(day; days) {
			runDay!day();
		}
	}
}
