module aoc2018.day13;

import std.algorithm;
import std.container.binaryheap;
import std.functional;
import std.range;
import std.string;
import std.typecons;
import std.utf;

enum Direction: ubyte {
  Up = 0, Down = 1, Left = 2, Right = 3
}

enum Track: ubyte {
  Nothing,
  Straight,
  LeftCurve,
  RightCurve,
  Intersection
}

const rightCurveTransition = [Direction.Right, Direction.Left, Direction.Down, Direction.Up];
const leftCurveTransition = [Direction.Left, Direction.Right, Direction.Up, Direction.Down];
const intersectionTransition = [
  [Direction.Left, Direction.Right, Direction.Down, Direction.Up],
  [Direction.Up, Direction.Down, Direction.Left, Direction.Right],
  [Direction.Right, Direction.Left, Direction.Up, Direction.Down]
];

const directions = [
  [0,-1],
  [0,1],
  [-1,0],
  [1,0]
];

struct Cart {
  uint tick;
  uint x;
  uint y;
  ushort id;
  ubyte intersectionCount;
  Direction direction;
}

auto before(Cart a, Cart b) {
  if (a.tick == b.tick) {
    if (a.y == b.y)
      return a.x > b.x;
    return a.y > b.y;
  }
  return a.tick > b.tick;
}

auto advance(Cart cart, Track[][] tracks) {
  auto dir = directions[cart.direction];
  auto x = cart.x + dir[0];
  auto y = cart.y + dir[1];
  auto intersectionCount = cart.intersectionCount;
  auto direction = cart.direction;
  auto track = tracks[y][x];
  final switch(track) {
    case Track.Nothing:
      throw new Error("Invalid direction");
    case Track.Straight:
      break;
    case Track.LeftCurve:
      direction = leftCurveTransition[direction];
      break;
    case Track.RightCurve:
      direction = rightCurveTransition[direction];
      break;
    case Track.Intersection:
      direction = intersectionTransition[intersectionCount][direction];
      intersectionCount = (intersectionCount + 1) % 3;
  }
  return Cart(cart.tick + 1, x, y, cart.id, intersectionCount, direction);
}

auto parseInput(string input) {
  auto lines = input.lineSplitter.array;
  auto maxWidth = lines.maxElement!"a.length".length;
  auto track = new Track[][](lines.length, maxWidth);
  auto directionMap = ['>': Direction.Right, '<': Direction.Left, '^': Direction.Up, 'v': Direction.Down];
  auto trackMap = [
    '-': Track.Straight,
    '|': Track.Straight,
    '\\': Track.LeftCurve,
    '/': Track.RightCurve,
    '+': Track.Intersection
  ];
  Cart[] carts;
  ushort cartId = 0;
  foreach(y, line; lines.enumerate) {
    foreach(x, c; line.byChar.enumerate) {
      switch(c) {
        case '>':
        case '<':
        case '^':
        case 'v':
          carts ~= Cart(0, cast(uint)(x), cast(uint)(y), cartId, 0, directionMap[c]);
          track[y][x] = Track.Straight;
          cartId += 1;
          break;
        default:
          track[y][x] = trackMap.get(c, Track.Nothing);
          break;
      }
    }
  }

  return tuple(carts, track);
}

Tuple!(uint,uint) puzzle1(Cart[] carts, Track[][] tracks) {
  auto cartQueue = heapify!before(carts);
  foreach(t; 0..ulong.max) {
    auto cart = cartQueue.front.advance(tracks);
    cartQueue.replaceFront(cart);
    foreach(c; carts) {
      if (cart.id != c.id && cart.x == c.x && cart.y == c.y)
        return tuple(cart.x, cart.y);
    }
  }

  return tuple(0u,0u);
}

Tuple!(uint,uint) puzzle2(Cart[] carts, Track[][] tracks) {
  auto cartsLen = carts.length;
  auto cartQueue = heapify!before(carts);
  auto crashed = new bool[carts.length];
  foreach(t; 0..ulong.max) {
    foreach(_; 0..cartsLen) {
      auto cart = cartQueue.removeAny.advance(tracks);
      if (crashed[cart.id])
        continue;
      foreach(c; carts.take(cartQueue.length)) {
        if (!crashed[c.id] && cart.id != c.id && cart.x == c.x && cart.y == c.y) {
          crashed[cart.id] = true;
          crashed[c.id] = true;
          cartsLen -= 2;
        }
      }
      if (!crashed[cart.id])
        cartQueue.insert(cart);
    }
    if (cartsLen == 1) {
      auto cart = cartQueue.front;
      return tuple(cart.x, cart.y);
    }
  }

  return tuple(0u,0u);
}

void run() {
  import aoc2018.utils;

  auto parsed = readInput(__MODULE__).parseInput;
  runPuzzle!(__MODULE__, puzzle1)(parsed.expand);
  runPuzzle!(__MODULE__, puzzle2)(parsed.expand);
}
