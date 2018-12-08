module aoc2018.utils;

import std.file;
import std.path;
import std.stdio;
import std.traits;

template runPuzzle(string inputName, alias fun) {
  void runPuzzle() {
    enum string funName = __traits(identifier, fun);
    enum path = buildPath("input", inputName).withExtension("txt");
    writeln("Running ", inputName, " - ", funName, ": ", fun(readText(path)));
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