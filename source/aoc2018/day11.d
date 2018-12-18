module aoc2018.day11;

import std.algorithm;
import std.range;
import std.typecons;

auto hundredsDigit(int number) {
  return (number / 100) % 10;
}

auto powerLevel(int x, int y, int serial) {
  auto rackID = x + 10;
  return hundredsDigit((rackID * y + serial) * rackID) - 5;
}

auto maxSumSlidingWindow(int[] arr, int size, ref int start) {
  start = 0;
  auto maxSum = 0;
  for(int i = 0; i < size; i++) {
    maxSum += arr[i];
  }
  auto slidingSum = maxSum - arr[start];
  for(int i = size; i < arr.length; i++) {
    auto sum = slidingSum + arr[i];
    auto slideStart = i-size+1;
    if (sum > maxSum) {
      maxSum = sum;
      start = slideStart;
    }
    slidingSum = sum - arr[slideStart];
  }
  return maxSum;
}

auto puzzle1(ref int[300][300] grid) {
  auto maxSum = int.min;
  auto maxX = 0;
  auto maxY = 0;
  int[300] tmp;
  foreach(left; 1..298) {
    fill(tmp[], 0);
    foreach(right; left..left+3) {
      foreach(i; 0..300) {
        tmp[i] += grid[i][right-1];
      }
    }
    auto start = 0;
    auto sum = maxSumSlidingWindow(tmp, 3, start);
    if (sum > maxSum) {
      maxSum = sum;
      maxX = start+1;
      maxY = left;
    }
  }

  return tuple(maxX, maxY);
}

auto puzzle2(ref int[300][300] grid) {
  auto maxSum = int.min;
  auto maxSize = 0;
  auto maxX = 0;
  auto maxY = 0;
  int[300] tmp;
  foreach(left; 1..301) {
    fill(tmp[], 0);
    foreach(right; left..301) {
      foreach(i; 0..300) {
        tmp[i] += grid[i][right-1];
      }
      auto start = 0;
      auto size = right - left + 1;
      auto sum = maxSumSlidingWindow(tmp, size, start);
      if (sum > maxSum) {
        maxSum = sum;
        maxSize = size;
        maxX = start+1;
        maxY = left;
      }
    }
  }

  return tuple(maxX, maxY, maxSize);
}

// An implementation that I saw on reddit that's very fast
auto puzzle2WithSummedAreaTable(int serial) {
  int[301][301] summed;
  foreach(x; 1..301) {
    foreach(y; 1..301) {
      auto level = powerLevel(x,y,serial);
      summed[x][y] = summed[x-1][y] + summed[x][y-1] - summed[x-1][y-1];
    }
  }
  auto maxSum = int.min;
  auto maxSize = 0;
  auto maxX = 0;
  auto maxY = 0;
  foreach(s; 1..301) {
    foreach(x; s..301) {
      foreach(y; s..301) {
        int total = summed[x][y] - summed[x-s][y] - summed[x][y-s] + summed[x-s][y-s];
        if (total > maxSum) {
          maxSize = s;
          maxX = x;
          maxY = y;
        }
      }
    }
  }
  
  return tuple(maxX, maxY, maxSize);
}

void run() {
  import aoc2018.utils;
  
  int serial = 7165;
  int[300][300] grid;
  foreach(x; 1..301) {
    foreach(y; 1..301) {
      grid[x-1][y-1] = powerLevel(x,y,serial);
    }
  }

  runPuzzle!("day11", puzzle1)(grid);
  runPuzzle!("day11", puzzle2)(grid);
}