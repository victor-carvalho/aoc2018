module aoc2018.day4;

import std.algorithm;
import std.conv: to;
import std.datetime;
import std.range;
import std.regex;
import std.string;

auto reg = regex(r"\[(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})\] (Guard #(\d+) begins shift|falls asleep|wakes up)");

enum EventKind { Shift, Sleeps, Awakes };

struct Event {
  Date date;
  TimeOfDay time;
  EventKind kind;
  int guard = 0;
}

auto createEvent(string[] e) {
  auto date = Date(e[0].to!int, e[1].to!int, e[2].to!int);
  auto time = TimeOfDay(e[3].to!int, e[4].to!int);
  final switch(e[5][0..5]) {
    case "Guard":
      return Event(date, time, EventKind.Shift, e[6].to!int);
    case "falls":
      return Event(date, time, EventKind.Sleeps);
    case "wakes":
      return Event(date, time, EventKind.Awakes);
  }
}

auto getEvents(string input) {
  return input.lineSplitter
    .map!(line => line.matchFirst(reg).drop(1).array)
    .map!createEvent
    .array
    .sort!"a.date == b.date ? a.time < b.time : a.date < b.date";
}

auto asleepHoursByGuards(Range)(Range events)
if(isInputRange!Range && is(ElementType!Range == Event)) {
  int[][int] asleepHours;
  while (!events.empty) {
    auto currentGuard = events.front.guard;
    events.popFront();

    int lastAsleepMinute = 0;
    foreach(e; events.until!(e => e.kind == EventKind.Shift)) {
      final switch(e.kind) {
        case EventKind.Shift:
          assert(false);
        case EventKind.Sleeps:
          lastAsleepMinute = e.time.minute;
          break;
        case EventKind.Awakes:
          asleepHours.require(currentGuard, new int[60])[lastAsleepMinute..e.time.minute] += 1;
          break;
      }
      events.popFront();
    }
  }

  return asleepHours;
}

auto puzzle1(int[][int] asleepHours) {
  auto guard = asleepHours.byPair.maxElement!"a.value.sum".key;
  return guard * asleepHours[guard][].maxIndex;
}

auto puzzle2(int[][int] asleepHours) {
  auto guard = asleepHours.byPair.maxElement!"a.value.maxElement".key;
  return guard * asleepHours[guard][].maxIndex;
}

void run() {
  import aoc2018.utils;

  auto input = readInput(__MODULE__).getEvents.asleepHoursByGuards;
  runPuzzle!(__MODULE__, puzzle1)(input);
  runPuzzle!(__MODULE__, puzzle2)(input);
}