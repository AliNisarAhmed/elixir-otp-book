defmodule Mastery.Examples.Math do
  alias Mastery.Core.Quiz

  def template_fields() do
    [
      name: :single_digit_addition,
      category: :addition,
      instructions: "Add the numbers",
      raw: "<%= @left %> + <%= @right %>",
      generators: addition_generators(),
      checker: &addition_checker/2
    ]
  end

  def addition_checker(subs, answer) do
    left = Keyword.fetch!(subs, :left)
    right = Keyword.fetch!(subs, :right)
    to_string(left + right) == String.trim(answer)
  end

  def addition_generators() do
    %{left: Enum.to_list(0..9), right: Enum.to_list(0..9)}
  end

  def quiz_fields() do
    %{mastery: 2, title: :simple_addition}
  end

  def quiz() do
    quiz_fields()
    |> Quiz.new()
    |> Quiz.add_template(template_fields())
  end
end
