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

template runPuzzle(string inputName, alias fun) {
  void runPuzzle() {
    enum string funName = __traits(identifier, fun);
    enum path = inputPath(inputName);
    printResult(inputName, funName, fun(readText(path)));
  }
}

template runPuzzle(string moduleName, alias fun, A) {
  void runPuzzle(A input) {
    enum string funName = __traits(identifier, fun);
    printResult(moduleName, funName, fun(input));
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