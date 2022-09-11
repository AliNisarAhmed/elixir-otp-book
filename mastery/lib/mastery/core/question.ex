defmodule Mastery.Core.Question do
  @moduledoc """
    Questions consist of the text a user is asked, the template that created them &
      the specific substitutions used to build this question 

    asked (String): 
        The question text for a user e.g. "1 + 2"
    template (Template.t): 
        The template that created the question
    substitutions (%{ substitution: any }): 
        The values chosen for each field in a template
        e.g. <%= left %> + <%= right %> , substitutions might be %{ "left" => 1, "right" => 2 }
  """

  alias Mastery.Core.Template

  defstruct ~w[asked template substitutions]a

  def new(%Template{} = template) do 
    template.generators
    |> Enum.map(&build_substitution/1)
    |> evaluate(template)
  end

  defp compile(template, substitutions) do 
    template.compiled 
    |> Code.eval_quoted(assigns: substitutions)
    |> elem(0)
  end

  defp evaluate(substitutions, template) do 
    %__MODULE__{
      asked: compile(template, substitutions),
      substitutions: substitutions,
      template: template
    }
  end

  defp build_substitution({name, choices_or_generators}) do
    {name, choose(choices_or_generators)}
  end

  defp choose(choices) when is_list(choices) do
    Enum.random(choices)
  end

  defp choose(generator) when is_function(generator) do
    generator.()
  end
end
