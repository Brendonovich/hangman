# Hangman

A simple hangman game built with Elixir and Phoenix LiveView.
In future I would like this to be a game Twitch streamers can play with their viewers.

## How It Works
`lib/hangman` contains all the game-specific code, which is essentially just the `Hangman.Game` module for now. In future, I would like game state to be stored in a `GenServer` that can share its data with multiple clients.

`lib/hangman-web` contains the client code that produces the user interface. `page_live.html.leex` is the single view that renders different output depending on `@game.state`. While a game is in progress, `@game.guesses` is mapped into the buttons that allow the user to guess letters, with simple `<p>` tags rendered if `Map.get(guesses, letter)` is true. Interactions with the buttons are handled by `page_live.ex`, which call `Game.guess_letter` with the current `game` object to handle letter guessing.

Deploying is managed by Dokku running on a Digital Ocean Droplet. Every push to the `master` branch triggers a GitHub Action that deploys the updated code to Dokku.

There is still a lot of cleanup and refactoring that can be done to this code, as I am new to Elixir and functional programming with pattern matching. I aim to work on this project as a service to those who may enjoy it and also to sharpen my skills with Elixir and Phoenix.