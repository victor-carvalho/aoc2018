module aoc2018.day15;

import std.algorithm;
import std.container.array;
import std.range;
import std.string;
import std.traits;
import std.typecons;
import std.utf;

import containers;
import optional;

alias Position = Tuple!(ulong, ulong);

enum Direction {
  Up = 0,
  Left = 1,
  Right = 2,
  Down = 3
}

auto directions = [EnumMembers!Direction];
auto dirtuple = [[-1, 0], [0, -1], [0, 1], [1, 0]];

enum UnitType {
  Goblin = 0,
  Elf = 1
}

struct Unit {
  uint hp;
  uint attackPower;
  UnitType type;

  bool isEnemyOf(Unit other) {
    return type != other.type;
  }
}

auto withDirection(Position position, Direction dir) {
  auto vec = dirtuple[dir];
  return tuple(position[0] + vec[0], position[1] + vec[1]);
}

auto getIndex(A)(A[][] matrix, Position pos) {
  pragma(inline, true) return matrix[pos[0]][pos[1]];
}

void setIndex(A)(A[][] matrix, Position pos, A value) {
  pragma(inline, true) matrix[pos[0]][pos[1]] = value;
}

struct BattleState {
  @disable this();

  static BattleState fromInput(string[] input, uint elvenPower) {
    auto rows = input.length;
    auto cols = input[0].length;

    auto state = BattleState(rows, cols);
    foreach (r, line; input.enumerate) {
      foreach (c, cell; line.byChar.enumerate) {
        switch (cell) {
        case 'G':
          state.field[r][c] = true;
          state.unitTypes[UnitType.Goblin] += 1;
          state.units.insert(tuple(r, c), Unit(200, 3, UnitType.Goblin));
          break;
        case 'E':
          state.field[r][c] = true;
          state.unitTypes[UnitType.Elf] += 1;
          state.units.insert(tuple(r, c), Unit(200, elvenPower, UnitType.Elf));
          break;
        case '#':
          state.field[r][c] = true;
          break;
        default:
          state.field[r][c] = false;
          break;
        }
      }
    }
    return state;
  }

  @property bool isOver() {
    return elves == 0 || goblins == 0;
  }

  @property int goblins() {
    return unitTypes[UnitType.Goblin];
  }

  @property int elves() {
    return unitTypes[UnitType.Elf];
  }

  @property uint outcome() {
    return round * units.byValue.map!(u => u.hp).sum;
  }

  void nextRound() {
    foreach (position; units.keys) {
      if (units.containsKey(position)) {
        auto unit = units[position];
        if (!tryToAttack(position, unit)) {
          move(position, units[position]).each!(pos => tryToAttack(pos, unit));
        }
        if(isOver) return;
      }
    }
    round += 1;
  }

private:
  this(ulong rows, ulong cols) {
    round = 0;
    queue.reserve(rows * cols);
    dist = new int[][](rows, cols);
    pred = new Position[][](rows, cols);
    field = new bool[][](rows, cols);
    rows = rows;
    cols = cols;
  }

  TreeMap!(Position, Unit) units;
  int[2] unitTypes;
  bool[][] field;
  uint round;

  CyclicBuffer!Position queue;
  int[][] dist;
  Position[][] pred;

  bool tryToAttack(Position position, Unit unit) {
    auto possibleTargets = directions
      .map!(dir => position.withDirection(dir))
      .filter!(pos => units.containsKey(pos) && unit.isEnemyOf(units[pos]));

    if (refRange(&possibleTargets).empty)
      return false;

    auto targetPos = possibleTargets.minElement!(pos => units[pos].hp);
    auto target = units[targetPos];
    if (target.hp > unit.attackPower) {
      target.hp -= unit.attackPower;
      units[targetPos] = target;
    } else {
      unitTypes[target.type] -= 1;
      field.setIndex(targetPos, false);
      units.remove(targetPos);
    }
    return true;
  }

  auto move(Position position, Unit unit) {
    foreach (row; dist)
      row.fill(-1);

    queue.insertBack(position);
    dist.setIndex(position, 0);
    pred.setIndex(position, position);

    while (queue.length > 0) {
      auto pos = queue.front;
      queue.removeFront;
      foreach(dir; directions) {
        auto neighbor = pos.withDirection(dir);
        if (!field.getIndex(neighbor) && dist.getIndex(neighbor) == -1) {
          dist.setIndex(neighbor, dist.getIndex(pos) + 1);
          pred.setIndex(neighbor, pos);
          queue.insertBack(neighbor);
        }
      }
    }

    auto possibleTargets = units.byKey
      .filter!(k => units[k].isEnemyOf(unit))
      .map!(k => directions.map!(d => k.withDirection(d)))
      .joiner
      .filter!(k => !field.getIndex(k) && dist.getIndex(k) >= 0);

    if (possibleTargets.empty)
      return no!Position;
    
    auto chosenTarget = possibleTargets.minElement!(k => dist.getIndex(k));

    while (pred.getIndex(chosenTarget) != position) {
      chosenTarget = pred.getIndex(chosenTarget);
    }

    units.remove(position);
    field.setIndex(position, false);
    
    units.insert(chosenTarget, unit);
    field.setIndex(chosenTarget, true);

    return some(chosenTarget);
  }
}

auto puzzle1(string[] input) {
  auto battle = BattleState.fromInput(input, 3);
  while (!battle.isOver) {
    battle.nextRound();
  }
  return battle.outcome;
}

auto puzzle2(string[] input) {
  foreach(power; 4..1000) {
    auto battle = BattleState.fromInput(input, power);
    auto elvesTotal = battle.elves;
    while (battle.elves == elvesTotal && !battle.isOver) {
      battle.nextRound();
    }
    if (battle.elves == elvesTotal)
      return battle.outcome;
  }
  return 0;
}

void run() {
  import aoc2018.utils;

  auto input = readInput(__MODULE__).lineSplitter.array;
  runPuzzle!(__MODULE__, puzzle1)(input);
  runPuzzle!(__MODULE__, puzzle2)(input);
}
