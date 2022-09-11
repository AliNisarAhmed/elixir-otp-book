defmodule Mastery.Core.Response do
  @moduledoc """
    When a user answers a question, we generate a response

    quiz_title (String): 
        Title field from a quiz
    template_name (atom): 
        Name field identifying the template 
    to (String): 
        The question being answered
    email (String): 
        user's email 
    answer (String): 
        answer by the user 
    correct (boolean): 
        was answer correct? 
    timestamp (Time.t): 
        The time the answer was given
  """
  defstruct ~w[quiz_title template_name to email answer correct timestamp]a

  def new(quiz, email, answer) do
    question = quiz.current_question
    template = question.template

    %__MODULE__{
      quiz_title: quiz.title,
      template_name: template.name,
      to: question.asked,
      email: email,
      answer: answer,
      correct: template.checker.(question.substitutions, answer),
      timestamp: DateTime.utc_now()
    }
  end
end
