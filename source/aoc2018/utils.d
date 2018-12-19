module aoc2018.utils;

import std.file;
import std.algorithm;
import std.path;
import std.stdio;
import std.traits;

void printResult(A)(string inputName, string funName, A result) {
  writeln("Running ", inputName, " - ", funName, ": ", result);
}

auto inputPath(string inputName) {
  return buildPath("input", inputName).withExtension("txt");
}

auto readInput(string moduleName) {
  return readText(inputPath(moduleName.find(".")[1..$]));
}

template runPuzzle(string moduleName, alias fun) {
  enum string funName = __traits(identifier, fun);
  void runPuzzle(A...)(A input) {
    static if (A.length == 0) {
      enum path = inputPath(moduleName);
      printResult(moduleName, funName, fun(readText(path)));
    } else {
      printResult(moduleName, funName, fun(input));
    }
  }
}

template runDay(string name) {
  void runDay() {
    enum moduleName = "aoc2018." ~ name;
    mixin("import " ~ moduleName ~ ";");
    mixin("alias current = " ~ moduleName ~ ";");
    __traits(getMember, current, "run")();
  }
}