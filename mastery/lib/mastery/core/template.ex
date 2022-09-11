defmodule Mastery.Core.Template do
  @moduledoc """
    Templates generate Questions

    name: 
        The name of the template
    category: 
        A grouping of questions of the same name
    instructions: 
        A string telling the user how to answer questions of this type
    raw (string): 
        The template code before compilation
    compiled (macro): 
        The compiled version of the template for execution
    generators (%{ substitution: list or function}): 
        generator for each substition in template, fire the function OR pick random from list
    checker (function(substitions, string) -> boolean): 
        given substition strings & answer, return true if answer is correct
  """

  defstruct ~w[
    name 
    category 
    instructions 
    raw 
    compiled 
    generators 
    checker]a

  def new(fields) do
    raw = Keyword.fetch!(fields, :raw)

    struct!(
      __MODULE__,
      Keyword.put(fields, :compiled, EEx.compile_string(raw))
    )
  end
end
