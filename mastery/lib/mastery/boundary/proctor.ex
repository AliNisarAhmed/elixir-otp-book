defmodule Mastery.Boundary.Proctor do
  use GenServer

  require Logger
  alias Mastery.Boundary.{QuizManager, QuizSession}

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, [], options)
  end

  def init(quizzes) do
    {:ok, quizzes}
  end

  def schedule_quiz(proctor \\ __MODULE__, quiz, temps, start_at, end_at) do
    quiz = %{
      fields: quiz,
      templates: temps,
      start_at: start_at,
      end_at: end_at
    }

    GenServer.call(proctor, {:schedule_quiz, quiz})
  end

  def handle_call({:schedule_quiz, quiz}, _from, quizzes) do
    now = DateTime.utc_now()

    ordered_quizzes =
      [quiz | quizzes]
      |> start_quizzes(now)
      |> Enum.sort(fn a, b ->
        date_time_less_than_or_equal?(a.start_at, b.start_at)
      end)

    build_reply_with_timeout({:reply, :ok}, ordered_quizzes, now)
  end

  def handle_info(:timeout, quizzes) do
    now = DateTime.utc_now()
    remaining_quizzes = start_quizzes(quizzes, now)
    build_reply_with_timeout({:noreply}, remaining_quizzes, now)
  end

  def handle_info({:end_quiz, title}, quizzes) do 
    QuizManager.remove_quiz(title)
    title 
    |> QuizSession.active_sessions_for()
    |> QuizSession.end_sessions()
    
    Logger.info("Stopped quiz #{title}")

    handle_info(:timeout, quizzes)
  end

  defp build_reply_with_timeout(reply, quizzes, now) do
    reply
    |> append_state(quizzes)
    |> maybe_append_timeout(quizzes, now)
  end

  # {:reply, :ok}, quizzes[] -> {:reply, :ok, quizzes[]}
  defp append_state(tuple, quizzes), do: Tuple.append(tuple, quizzes)

  # if quizzes/state is empty, do not timeout
  defp maybe_append_timeout(tuple, [], _now), do: tuple

  # if state is not empty, add a timeout in the reply {:reply, :ok, state, timeout}
  defp maybe_append_timeout(tuple, quizzes, now) do
    timeout =
      quizzes
      |> hd
      |> Map.fetch!(:start_at)
      |> DateTime.diff(now, :millisecond)

    Tuple.append(tuple, timeout)
  end

  defp start_quizzes(quizzes, now) do
    {ready_quizzes, not_ready_quizzes} =
      Enum.split_while(quizzes, fn quiz ->
        date_time_less_than_or_equal?(quiz.start_at, now)
      end)

    Enum.each(ready_quizzes, fn quiz -> start_quiz(quiz, now) end)
    not_ready_quizzes
  end

  defp start_quiz(quiz, now) do
    Logger.info("Starting quiz #{quiz.fields.title}...")
    QuizManager.build_quiz(quiz.fields)
    Enum.each(quiz.templates, &QuizManager.add_template(quiz.fields.title, &1))
    timeout = DateTime.diff(quiz.end_at, now, :millisecond)
    Process.send_after(self(), {:end_quiz, quiz.fields.title}, timeout)
  end

  defp date_time_less_than_or_equal?(a, b) do
    DateTime.compare(a, b) in ~w[lt eq]a
  end
end
