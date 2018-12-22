module aoc2018.day16;

import std.algorithm;
import std.conv;
import std.range;
import std.regex;
import std.string;

import containers;

alias Instruction = void function(ushort[], ushort, ushort, ushort);

template instruction(string expr) {
  enum instruction = mixin("function(ushort[] r, ushort a, ushort b, ushort c) { r[c] = cast(ushort)(" ~ expr ~ "); }");
}

Instruction[16] instructions = [
  instruction!q{ r[a] + r[b] }, 
  instruction!q{ r[a] + b }, 
  instruction!q{ r[a] * r[b] }, 
  instruction!q{ r[a] * b }, 
  instruction!q{ r[a] & r[b] }, 
  instruction!q{ r[a] & b }, 
  instruction!q{ r[a] | r[b] }, 
  instruction!q{ r[a] | b }, 
  instruction!q{ r[a] }, 
  instruction!q{ a }, 
  instruction!q{ a > r[b] }, 
  instruction!q{ r[a] > b }, 
  instruction!q{ r[a] > r[b] }, 
  instruction!q{ a == r[b] }, 
  instruction!q{ r[a] == b }, 
  instruction!q{ r[a] == r[b] }, 
];

struct Event {
  ushort[] before;
  ushort[] opcode;
  ushort[] after;

  auto matchesInstruction(Instruction inst) {
    auto input = before.dup;
    inst(input, opcode[1], opcode[2], opcode[3]);
    return input.equal(after);
  }
}

auto evtreg = regex(r"\w+:\s+\[(\d+), (\d+), (\d+), (\d+)\]");

auto parseChunk(string[] chunk) {
  auto before = chunk[0].matchFirst(evtreg).drop(1).map!(m => m.to!ushort).array;
  auto opcode = chunk[1].split.map!(m => m.to!ushort).array;
  auto after = chunk[2].matchFirst(evtreg).drop(1).map!(m => m.to!ushort).array;
  assert(!before.empty);
  assert(!opcode.empty);
  assert(!after.empty);
  return Event(before, opcode, after);
}

auto parseInput(string input) {
  return input.lineSplitter
    .filter!(line => !line.empty)
    .chunks(3)
    .map!(chunk => parseChunk(chunk.array))
    .array;
}

auto parseSamples(string input) {
  return input.lineSplitter
    .map!(line => line.split.map!(m => m.to!ushort).array)
    .array;
}

auto puzzle1(Event[] evts) {
  return evts
    .map!(e => instructions[].filter!(i => e.matchesInstruction(i)).count)
    .filter!(c => c >= 3)
    .count;
}

auto puzzle2(Event[] evts, ushort[][] samples) {
  ulong[16] opcodes;
  HashSet!ushort[16] instructionMapping;
  foreach(evt; evts) {
    foreach(idx, inst; instructions) {
      if (evt.matchesInstruction(inst)) {
        instructionMapping[idx].insert(evt.opcode[0]);
      }
    }
  }

  auto instructionsToMap = CyclicBuffer!ulong();
  instructionsToMap.reserve(16);
  foreach(key; 0..16) {
    instructionsToMap.insertBack(key);
  }

  while (!instructionsToMap.empty) {
    auto key = instructionsToMap.front;
    instructionsToMap.removeFront;
    
    if (instructionMapping[key].length == 1) {
      auto op = instructionMapping[key][].front;
      opcodes[op] = key;
      foreach(k; instructionsToMap) {
        instructionMapping[k].remove(op);
      }
    } else {
      instructionsToMap.insertBack(key);
    }
  }

  ushort[4] registers;
  foreach (sample; samples) {
    instructions[opcodes[sample[0]]](registers, sample[1], sample[2], sample[3]);
  }

  return registers[0];
}

void run() {
  import aoc2018.utils;

  auto input = readInput(__MODULE__).parseInput;
  auto samples = readInput("aoc2018.day16sample").parseSamples;
  runPuzzle!(__MODULE__, puzzle1)(input);
  runPuzzle!(__MODULE__, puzzle2)(input, samples);
}
