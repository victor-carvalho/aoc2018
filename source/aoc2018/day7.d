module aoc2018.day7;

import std.algorithm;
import std.container.dlist;
import std.container.binaryheap;
import std.math: abs;
import std.range;
import std.regex;
import std.string;

import containers;

auto reg = regex(r"Step (\w) must be finished before step (\w) can begin");

struct Graph {
  ubyte[][ubyte] nodes;
  int[ubyte] degree;
}

struct Task {
  ubyte node;
  int time;

  this(ubyte node, int currenTime) {
    this.node = node;
    this.time = currenTime + node - 4;
  }
}

auto getInstructions(string input) {
  return input.lineSplitter
    .map!(line => line.matchFirst(reg).drop(1).map!"cast(ubyte)(a[0])".array)
    .array;
}

auto buildGraph(Range)(Range instructions)
if (isInputRange!Range && is(ElementType!Range == ubyte[])){
  ubyte[][ubyte] nodes;
  int[ubyte] degree;
  foreach(inst; instructions) {
    nodes.require(inst[0], new ubyte[0]) ~= inst[1];
    degree.require(inst[1], 0) += 1;
  }

  foreach(node; nodes.byKey)
    nodes[node].sort;

  return Graph(nodes, degree);
}

auto puzzle1(ubyte[][] input) {
  auto graph = input.buildGraph;
  auto firstNodes = graph.nodes.byKey.filter!(node => graph.degree.require(node, 0) == 0).array.sort;
  auto queue = DList!ubyte(firstNodes);
  ubyte[] output; 
  while (!queue.empty) {
    auto node = queue.front;
    queue.removeFront;
    if (graph.degree[node] > 0)
      graph.degree[node] -= 1;
    if (graph.degree[node] == 0) {
      output ~= node;
      if (node in graph.nodes)
        queue.insertFront(graph.nodes[node]);
    }
  }

  return output.map!"cast(char)(a)";
}

auto puzzle2(ubyte[][] input) {
  auto graph = input.buildGraph;
  auto firstNodes = graph.nodes.byKey.filter!(node => graph.degree.require(node, 0) == 0).array.sort;
  auto queue = DList!ubyte(firstNodes);
  auto workQueue = heapify!"a.time > b.time"(new Task[0]); 
  auto time = 0;
  while (!queue.empty || !workQueue.empty) {
    while(workQueue.length < 5 && !queue.empty) {
      auto node = queue.front;
      queue.removeFront;
      workQueue.insert(Task(node, time));
    }


    auto task = workQueue.front;
    workQueue.removeFront;
    time = task.time;
    if (task.node in graph.nodes)
      queue.insertFront(graph.nodes[task.node].filter!(target => --graph.degree[target] == 0));
  }

  return time;
}


void run() {
  import aoc2018.utils;

  auto input = readInput(__MODULE__).getInstructions;
  runPuzzle!(__MODULE__, puzzle1)(input);
  runPuzzle!(__MODULE__, puzzle2)(input);
}