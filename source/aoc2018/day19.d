module aoc2018.day19;

import std.algorithm;
import std.conv;
import std.range;
import std.string;
import std.typecons;

alias Opcode = void function(ref uint[6], uint, uint, uint);

template opcode(string expr) {
  enum opcode = mixin("function(ref uint[6] r, uint a, uint b, uint c) { r[c] = cast(uint)(" ~ expr ~ "); }");
}

immutable static Opcode[16] opcodes = [
  opcode!q{ r[a] + r[b] }, 
  opcode!q{ r[a] + b }, 
  opcode!q{ r[a] * r[b] }, 
  opcode!q{ r[a] * b }, 
  opcode!q{ r[a] & r[b] }, 
  opcode!q{ r[a] & b }, 
  opcode!q{ r[a] | r[b] }, 
  opcode!q{ r[a] | b }, 
  opcode!q{ r[a] }, 
  opcode!q{ a }, 
  opcode!q{ a > r[b] }, 
  opcode!q{ r[a] > b }, 
  opcode!q{ r[a] > r[b] }, 
  opcode!q{ a == r[b] }, 
  opcode!q{ r[a] == b }, 
  opcode!q{ r[a] == r[b] }, 
];

ubyte opcodeIndex(string opcode) {
  final switch(opcode) {
    case "addr": return 0;
    case "addi": return 1;
    case "mulr": return 2;
    case "muli": return 3;
    case "banr": return 4;
    case "bani": return 5;
    case "borr": return 6;
    case "bori": return 7;
    case "setr": return 8;
    case "seti": return 9;
    case "gtir": return 10;
    case "gtri": return 11;
    case "gtrr": return 12;
    case "eqir": return 13;
    case "eqri": return 14;
    case "eqrr": return 15;
  }
}

struct Instruction {
  ubyte opcode;
  Tuple!(ubyte, ubyte, ubyte) args;
}

auto puzzle1(Instruction[] instructions, ubyte boundRegister) {
  uint[6] registers = [0,0,0,0,0,0];
  for(uint pc = 0; pc < instructions.length; pc++) {
    auto instruction = instructions[pc];
    registers[boundRegister] = pc;
    opcodes[instruction.opcode](registers, instruction.args[0], instruction.args[1], instruction.args[2]);
    pc = registers[boundRegister];
  }
  return registers[0];
}

/**
 * The second part has too many iterations to brute force.
 * After analyzing the instructions and the state of the registers after many iterations,
 * I noticed that it calculates the sum of the divisors of a certain number that it precalculates.
 * This code is to calculate the sum of divisors of a number.
 */
auto puzzle2(int n) {
  auto sum = 1;
  for (auto x = 2; x * x <= n; x++) {
    if (n % x == 0)
      sum += x + n / x;
  }
  return sum + n;
}

auto parseLine(string line) {
  auto ins = line.stripRight.split(' ');
  auto opcode = ins[0].opcodeIndex;
  return Instruction(opcode, tuple(ins[1].to!ubyte, ins[2].to!ubyte, ins[3].to!ubyte));
}

auto parseInput(string input) {
  auto lines = input.splitLines;
  auto declaration = lines.front.stripRight.split(' ');
  auto boundRegister = declaration[1].to!ubyte;
  auto instructions = lines.dropOne.map!parseLine.array;
  return tuple(instructions, boundRegister);
}

void run() {
  import aoc2018.utils;

  auto input = readInput(__MODULE__).parseInput;
  runPuzzle!(__MODULE__, puzzle1)(input.expand);
  runPuzzle!(__MODULE__, puzzle2)(10_551_376);
}
