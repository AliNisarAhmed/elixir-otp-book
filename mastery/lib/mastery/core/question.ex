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

  defstruct ~w[asked template substitutions]a
end
