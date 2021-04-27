defmodule HangmanWeb.PlayLive do
  use Phoenix.HTML
  use HangmanWeb, :live_view

  alias Phoenix.PubSub
  alias Hangman.GameServer

  @impl true
  def mount(_params, session, socket) do
    %{
      "current_user" => username,
      "access_token" => token
    } = session

    if(connected?(socket)) do
      game_name = Hangman.create_game(username, token)

      PubSub.subscribe(Hangman.PubSub, "chat:#{username}")
      PubSub.subscribe(Hangman.PubSub, "game:#{game_name}")

      {:ok,
       assign(socket,
         state: :waiting,
         game_name: game_name,
         game: GameServer.game(game_name)
       )}
    else
      {:ok,
       assign(socket,
         state: :waiting,
         game: %Hangman.Game{}
       )}
    end
  end

  @impl true
  def handle_event("start_game", _params, socket) do
    game_name = socket.assigns.game_name

    GameServer.start_game(game_name)

    {:noreply,
     assign(socket,
       game: GameServer.game(socket.assigns.game_name),
       state: :playing,
       guess_counts: %{},
       total_count: 0
     )}
  end

  def handle_event("new_game", _params, socket) do
    {:noreply, assign(socket, state: :waiting)}
  end

  @impl true
  def handle_event("submit_guess", _params, socket) do
    most_voted_letter =
      socket.assigns.guess_counts
      |> Hangman.Utilities.sort_guesses_map()
      |> List.first()
      |> elem(0)

    {:ok, %{:game => game}} = GameServer.guess_letter(socket.assigns.game_name, most_voted_letter)

    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def handle_event("next_round", _params, socket) do
    {:ok, %{:game => game, :guess_counts => guess_counts}} =
      GameServer.continue_guessing(socket.assigns.game_name)

    {:noreply, assign(socket, game: game, guess_counts: guess_counts, total_count: 0)}
  end

  @impl true
  def handle_info({:message, user, "!guess " <> msg}, socket) do
    if(socket.assigns.game.state == :guessing) do
      GameServer.register_user_guess(socket.assigns.game_name, user, msg)

      PubSub.broadcast!(
        Hangman.PubSub,
        "game:#{socket.assigns.game_name}",
        {:guess_counts_updated}
      )
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:message, _user, _msg}, socket) do
    {:noreply, socket}
  end

  def handle_info({:guess_counts_updated}, socket) do
    {:ok, %{:guess_counts => guess_counts, :total_count => total_count}} =
      GameServer.guess_counts(socket.assigns.game_name)

    {:noreply,
     assign(socket,
       guess_counts: guess_counts,
       total_count: total_count
     )}
  end

  @impl true
  def handle_info({:guess_timer_updated, time}, socket) do
    {:noreply, assign(socket, guess_time: time)}
  end

  @impl true
  def handle_info(:new_guess, socket) do
    {:noreply, assign(socket, guess_state: :guessing)}
  end
end
