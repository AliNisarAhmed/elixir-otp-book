alias Mastery.Core.{Template, Response, Question, Quiz}

generator = %{ left: [1, 2], right: [3, 4] }
checker = fn(sub, answer) -> sub[:left] + sub[:right] == String.to_integer(answer) end

template_fields = 
  [
    name: :single_digit_addition,
    category: :addition,
    instructions: "Add the numbers",
    raw: "<%= @left %> + <%= @right %>",
    generators: generator,
    checker: checker
  ]

quiz = 
  Quiz.new(title: "Addition", mastery: 2)
  |> Quiz.add_template(template_fields)
  |> Quiz.select_question()
#
email = "ali@test.com"

response = Response.new(quiz, email, "5")
