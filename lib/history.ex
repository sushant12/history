defmodule History do
  def grep(term, opts) do
    a = Keyword.get(opts, :A, 0)
    b = Keyword.get(opts, :B, 0)
    history = load_history()

    matches =
      history
      |> Enum.with_index()
      |> Enum.flat_map(fn {element, index} ->
        case String.match?(element, ~r/#{term}/) do
          true -> [index]
          false -> []
        end
      end)
      |> Enum.map(fn index ->
        lower_bound = index + a
        index..lower_bound
      end)
      |> group_ranges()
      |> Enum.each(fn list ->
        Enum.map(list, fn range -> Enum.to_list(range) end)
        |> List.flatten()
        |> Enum.uniq()
        |> Enum.each(fn index ->
          if index < Enum.count(history) do
            txt = Enum.at(history, index)
            IO.write("#{index}  ")

            IO.write(
              String.replace(txt, term, "#{IO.ANSI.red()}#{term}#{IO.ANSI.default_color()}")
            )
          end
        end)

        IO.write("-- \n")
      end)
  end

  def group_ranges([current | rest]), do: do_group_ranges(rest, [current], [])

  defp do_group_ranges([], group, grouped) do
    Enum.reverse([Enum.reverse(group) | grouped])
  end

  defp do_group_ranges([current | rest], [prev | _] = group, grouped) do
    if Range.disjoint?(current, prev) do
      # Create a new group
      do_group_ranges(rest, [current], [Enum.reverse(group) | grouped])
    else
      # Add to existing group
      do_group_ranges(rest, [current | group], grouped)
    end
  end

  def load_history do
    :group_history.load()
    |> Enum.map(&List.to_string/1)
    |> Enum.reverse()

    # [
    #   {"kubectl", 0},
    #   {"kubectl", 1},
    #   {"abc", 2},
    #   {"kubectl", 3},
    #   {"kubectl", 4},
    #   {"abc", 5},
    #   {"abc", 6},
    #   {"abc", 7},
    #   {"kubectl", 8},
    #   {"kubectl", 9},
    #   {"kubectl", 10},
    #   {"abc", 11},
    #   {"abc", 12},
    #   {"abc", 13},
    #   {"kubectl", 14}
    # ]
  end
end
