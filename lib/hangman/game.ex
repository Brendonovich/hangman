defmodule Hangman.Game do
  @type t ::
          %__MODULE__{
            turns_left: number,
            letters: list(String.t()),
            guesses: MapSet.t(),
            state: atom()
          }

  defstruct turns_left: 6,
            # The word, split into chars
            letters: [],
            # All currently guessed letters
            guesses: MapSet.new(),
            # State of game, can be :guessing, :good_guess, :bad_guess, :already_guessed, :win, :loss
            state: :guessing

  def new(word) do
    %Hangman.Game{
      letters:
        word
        |> String.upcase()
        |> String.codepoints()
    }
  end

  def new() do
    new(Dictionary.random_word())
  end

  @spec guess_letter(t(), String.t()) :: t()
  def guess_letter(game, letter) do
    case game.state do
      n when n not in [:win, :lose] ->
        normalised_letter =
          letter
          |> String.first()
          |> String.capitalize()

        _guess_letter(
          game,
          normalised_letter,
          MapSet.member?(game.guesses, normalised_letter)
        )

      _ ->
        game
    end
  end

  def continue_guessing(game), do: Map.put(game, :state, :guessing)

  def is_over(game), do: game.state in [:win, :lose]

  def reveal_guessed(game),
    do:
      Enum.map(game.letters, fn letter ->
        if MapSet.member?(game.guesses, letter), do: letter, else: "_"
      end)

  defp _guess_letter(game, _letter, _already_gessed = true),
    do: game

  defp _guess_letter(game, letter, _already_gessed),
    do:
      process_guess(
        Map.put(game, :guesses, MapSet.put(game.guesses, letter)),
        Enum.member?(game.letters, letter)
      )

  defp process_guess(game, _good_guess = true),
    do:
      process_maybe_win(
        game,
        all_letters_guessed(game.letters, game.guesses)
      )

  defp process_guess(game, _good_guess), do: process_maybe_lose(game, game.turns_left == 1)

  defp process_maybe_lose(game, _lose = true), do: Map.put(game, :state, :lose)

  defp process_maybe_lose(game, _lost),
    do:
      Map.merge(game, %{
        :state => :bad_guess,
        :turns_left => game.turns_left - 1
      })

  defp process_maybe_win(game, _win = true), do: Map.put(game, :state, :win)

  defp process_maybe_win(game, _win), do: Map.put(game, :state, :good_guess)

  defp all_letters_guessed(letters, guesses),
    do:
      Enum.reduce(letters, true, fn letter, acc ->
        if MapSet.member?(guesses, letter),
          do: acc,
          else: false
      end)
end
