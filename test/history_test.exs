defmodule HistoryTest do
  use ExUnit.Case
  import Mock

  @history [
    {"kubectl", 0},
    {"kubectl", 1},
    {"abc", 2},
    {"kubectl", 3},
    {"kubectl", 4},
    {"abc", 5},
    {"abc", 6},
    {"abc", 7},
    {"kubectl", 8},
    {"kubectl", 9},
    {"kubectl", 10},
    {"abc", 11},
    {"abc", 12},
    {"abc", 13},
    {"kubectl", 14}
  ]

  test "greets the world" do
    with_mock History, [:passthrough], load_history: fn -> @history end do
      assert History.grep("kubectl", A: 2) == [[0, 1, 2, 3, 4, 5, 6], [8, 9, 10, 11, 12], [14]]
    end
  end
end
