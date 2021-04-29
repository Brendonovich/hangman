defmodule Hangman.GameServer do
  alias Hangman.{Game}

  use GenServer

  @type t ::
          %__MODULE__{
            chat_guesses: MapSet.t(),
            guess_counts: map(),
            game: Game.t()
          }

  defstruct(
    chat_guesses: MapSet.new(),
    guess_counts: Map.new(),
    game: nil
  )

  def start_link(name) do
    GenServer.start_link(
      __MODULE__,
      %__MODULE__{},
      name: via_tuple(name)
    )
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def start_game(game) do
    game
    |> via_tuple()
    |> GenServer.call(:start_game)
  end

  def guess_letter(game, letter) do
    game
    |> via_tuple()
    |> GenServer.call({:guess_letter, letter})
  end

  def register_user_guess(game, user, letter) do
    game
    |> via_tuple()
    |> GenServer.call({:register_user_guess, user, letter})
  end

  def guess_counts(game) do
    game
    |> via_tuple()
    |> GenServer.call(:guess_counts)
  end

  def game(game) do
    game
    |> via_tuple()
    |> GenServer.call(:game)
  end

  def continue_guessing(game) do
    game
    |> via_tuple()
    |> GenServer.call(:continue_guessing)
  end

  @impl true
  def handle_call({:guess_letter, letter}, _from, %__MODULE__{} = state) do
    new_state = %{state | game: Game.guess_letter(state.game, letter)}
    {:reply, {:ok, new_state}, new_state}
  end

  @impl true
  def handle_call({:register_user_guess, user, letter}, _from, %__MODULE__{} = state) do
    normalized_letter =
      letter
      |> String.first()
      |> String.capitalize()

    new_state =
      cond do
        MapSet.member?(state.game.guesses, normalized_letter) ->
          state

        !MapSet.member?(state.chat_guesses, user) ->
          %{
            state
            | chat_guesses: MapSet.put(state.chat_guesses, user),
              guess_counts:
                Map.update(state.guess_counts, normalized_letter, 1, fn x -> x + 1 end)
          }

        true ->
          state
      end

    {:reply, {:ok, new_state}, new_state}
  end

  @impl true
  def handle_call(:start_game, _from, _state) do
    new_state = %__MODULE__{game: Game.new()}
    {:reply, {:ok, new_state}, new_state}
  end

  @impl true
  def handle_call(:guess_counts, _from, %__MODULE__{} = state) do
    guess_counts = state.guess_counts

    total_count =
      guess_counts
      |> Map.values()
      |> Enum.sum()

    {:reply, {:ok, %{guess_counts: guess_counts, total_count: total_count}}, state}
  end

  @impl true
  def handle_call(:game, _from, %__MODULE__{} = state) do
    {:reply, state.game, state}
  end

  @impl true
  def handle_call(:continue_guessing, _from, %__MODULE__{} = state) do
    new_state = %__MODULE__{game: Game.continue_guessing(state.game)}
    {:reply, {:ok, new_state}, new_state}
  end

  defp via_tuple(name) do
    {:via, Registry, {:game_server_registry, name}}
  end
end
