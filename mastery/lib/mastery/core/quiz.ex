defmodule Mastery.Core.Quiz do 
  @moduledoc """
    Quizes keep asking questions till a user achieves Mastery

    title (String): 
        title for quiz 
    mastery (int): 
        number of questions to get right to consider Mastery 
    current_question (Question.t): 
        the current question presented to the user 
    last_response (Response.t): 
        the last response given by the user 
    templates (%{ "category" => [Tempplate.t] })
        the master list of templates, by category
    used ([Template.t]):
        the templates that we have used, this cycle, not yet mastered
    mastered ([Template.t]):
        already mastered templates
    record (%{ "template_name" => int }): 
        The number of correct answers in a row that the user has given for each template
  """
  defstruct title: nil,
              mastery: 3,
              templates: %{},
              used: [],
              current_question: nil,
              last_response: nil,
              record: %{},
              mastered: []
end
