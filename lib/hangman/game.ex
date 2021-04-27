defmodule Hangman.Game do
  @type t :: %{
          turns_left: number(),
          letters: list(binary()),
          guesses: map(),
          game_state: :initializing
        }

  defstruct(
    turns_left: 6,
    # The word, split into chars
    letters: [],
    # All currently guessed letters
    guesses: Map.new(?A..?Z, fn l -> {<<l::utf8>>, false} end),
    # State of game, can be :initializing, :good_guess, :bad_guess, :already_guessed, :win, :loss
    game_state: :initializing
  )

  def new_game(word),
    do: %Hangman.Game{
      letters:
        word
        |> String.upcase()
        |> String.codepoints()
    }

  def new_game(), do: new_game(Dictionary.random_word())

  @spec guess_letter(t(), String.t()) :: t()
  def guess_letter(game, letter) do
    case game.game_state do
      n when n not in [:win, :lose] ->
        normalised_letter =
          letter
          |> String.first()
          |> String.capitalize()

        _guess_letter(
          game,
          normalised_letter,
          Map.get(game.guesses, normalised_letter)
        )

      _ ->
        game
    end
  end

  def reveal_guessed(game),
    do:
      Enum.map(game.letters, fn letter ->
        if Map.get(game.guesses, letter), do: letter, else: "_"
      end)

  defp _guess_letter(game, _letter, _already_gessed = true),
    do: Map.put(game, :game_state, :already_guessed)

  defp _guess_letter(game, letter, _already_gessed),
    do:
      process_guess(
        Map.put(game, :guesses, Map.put(game.guesses, letter, true)),
        Enum.member?(game.letters, letter)
      )

  defp process_guess(game, _good_guess = true),
    do:
      process_maybe_win(
        game,
        all_letters_guessed(game.letters, game.guesses)
      )

  defp process_guess(game, _good_guess), do: process_maybe_lose(game, game.turns_left == 1)

  defp process_maybe_lose(game, _lose = true), do: Map.put(game, :game_state, :lose)

  defp process_maybe_lose(game, _lost),
    do:
      Map.merge(game, %{
        :game_state => :bag_guess,
        :turns_left => game.turns_left - 1
      })

  defp process_maybe_win(game, _win = true), do: Map.put(game, :game_state, :win)

  defp process_maybe_win(game, _win), do: Map.put(game, :game_state, :good_guess)

  defp all_letters_guessed(letters, guesses),
    do:
      Enum.reduce(letters, true, fn letter, acc ->
        if Map.get(guesses, letter),
          do: acc,
          else: false
      end)
end
