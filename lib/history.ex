defmodule History do
  def grep(term, opts) do
    history = load_history()
    history_count = Enum.count(history)

    history
    |> get_match_indices(term)
    |> maybe_add_contexts(opts)
    |> group_ranges()
    |> Enum.each(fn range_list ->
      parse_range(range_list)
      |> Enum.each(fn match_index ->
        if match_index < history_count do
          txt = Enum.at(history, match_index)

          IO.write("#{match_index}  ")

          IO.write(String.replace(txt, term, "#{IO.ANSI.red()}#{term}#{IO.ANSI.default_color()}"))
        end
      end)

      IO.write("#{IO.ANSI.red()}--- #{IO.ANSI.default_color()} \n")
    end)
  end

  defp get_match_indices(history, term) do
    history
    |> Enum.with_index()
    |> Enum.flat_map(fn {element, index} ->
      case String.match?(element, ~r/#{term}/) do
        true -> [index]
        false -> []
      end
    end)
  end

  defp maybe_add_contexts(match_indices, opts) do
    context_a = Keyword.get(opts, :A, 0)
    context_b = Keyword.get(opts, :B, 0)

    match_indices
    |> Enum.map(fn index ->
      upper_bound(index, context_b)..lower_bound(index, context_a)
    end)
  end

  defp upper_bound(index, 0), do: index

  defp upper_bound(index, context_b) do
    potential_index = index - context_b

    if potential_index < 0 do
      0
    else
      potential_index
    end
  end

  defp lower_bound(index, 0), do: index

  defp lower_bound(index, context_a), do: index + context_a

  def group_ranges([current | rest]), do: do_group_ranges(rest, [current], [])

  defp do_group_ranges([], group, grouped) do
    Enum.reverse([Enum.reverse(group) | grouped])
  end

  defp do_group_ranges([current | rest], [prev | _] = group, grouped) do
    if Range.disjoint?(current, prev) do
      do_group_ranges(rest, [current], [Enum.reverse(group) | grouped])
    else
      do_group_ranges(rest, [current | group], grouped)
    end
  end

  defp parse_range(range_list) do
    Enum.map(range_list, &Enum.to_list/1)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp load_history do
    :group_history.load()
    |> Enum.map(&List.to_string/1)
    |> Enum.reverse()
  end
end
