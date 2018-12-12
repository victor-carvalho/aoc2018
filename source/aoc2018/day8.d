module aoc2018.day8;

import std.algorithm;
import std.conv: to;
import std.range;
import std.string;

import std.stdio;

struct Node {
  int numChildren;
  int numMetadata;
  Node[] children;
  int[] metadata;
}

auto readMetadata(Range)(ref Range input, int n)
if (isInputRange!Range && is(ElementType!Range == int)) {
  auto metadata = input.take(n).array;
  input.popFrontN(n);
  return metadata;
}

Node readNode(Range)(ref Range input)
if (isInputRange!Range && is(ElementType!Range == int)) {
  auto numChildren = input.front;
  input.popFront;
  auto numMetadata = input.front;
  input.popFront;

  auto children = numChildren > 0
    ? iota(numChildren).map!(_ => readNode(input)).array
    : new Node[0];

  auto metadata = input.readMetadata(numMetadata);

  return Node(numChildren, numMetadata, children, metadata);
}

Node readNode(Range)(Range input)
if (isInputRange!Range && is(ElementType!Range == int)) {
  return readNode(input);
}

int sumMetadata(Node node) {
  return node.metadata.sum + node.children[].map!(n => sumMetadata(n)).sum;
}

int value(Node node) {
  if (node.numChildren > 0) {
    return node.metadata.filter!(i => i <= node.numChildren).map!(i => node.children[i-1].value).sum;
  }
  return node.sumMetadata;
}

auto puzzle1(string input) {
  return input
    .splitter
    .map!"a.to!int"
    .readNode
    .sumMetadata;
}

auto puzzle2(string input) {
  return input
    .splitter
    .map!"a.to!int"
    .readNode
    .value;
}


void run() {
  import aoc2018.utils;

  runPuzzle!("day8", puzzle1)();
  runPuzzle!("day8", puzzle2)();
}