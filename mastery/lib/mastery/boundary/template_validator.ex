defmodule Mastery.Boundary.TemplateValidator do
  alias Mastery.Boundary.Validator

  def errors(fields) when is_list(fields) do
    fields = Map.new(fields)

    []
    |> Validator.require(fields, :name, &validate_name/1)
    |> Validator.require(fields, :category, &validate_name/1)
    |> Validator.optional(fields, :instructions, &validate_instructions/1)
    |> Validator.require(fields, :raw, &validate_raw/1)
    |> Validator.require(fields, :generators, &validate_generators/1)
    |> Validator.require(fields, :checker, &validate_checker/1)
  end

  def errors(_fields), do: [{nil, "A Keyword List of fields is required"}]

  def validate_name(name) when is_atom(name), do: :ok
  def validate_name(_name), do: {:error, "must be an atom"}

  def validate_instructions(ins) when is_binary(ins), do: :ok
  def validate_instructions(_ins), do: {:error, "must be a binary"}

  def validate_raw(raw) when is_binary(raw) do
    Validator.check(String.match?(raw, ~r{\S}), {:error, "can't be blank"})
  end

  def validate_raw(_raw), do: {:error, "must be a string"}

  def validate_generators(gens) when is_map(gens) do
    gens
    |> Enum.map(&validate_generator/1)
    |> Enum.reject(&(&1 == :ok))
    |> case do
      [] -> :ok
      errors -> {:errors, errors}
    end
  end

  def validate_generators(_gens), do: {:error, "must be a map"}

  def validate_generator({name, gen}) when is_atom(name) and is_list(gen) do
    Validator.check(gen != [], {:error, "cannot be empty"})
  end

  def validate_generator({name, gen}) when is_atom(name) and is_function(gen, 0) do
    :ok
  end

  def validate_generator(_gen), do: {:error, "must be a string to list or function pair"}

  def validate_checker(checker) when is_function(checker, 2), do: :ok
  def validate_checker, do: {:error, "must be an arity 2 function"}
end
