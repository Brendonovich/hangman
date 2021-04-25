defmodule HangmanWeb.OauthController do
  use HangmanWeb, :controller

  import Hangman.Utilities

  alias Plug.Conn
  alias Phoenix.Controller

  def redirect(conn, %{"code" => code} = _params) do
    %{
      "access_token" => access_token,
      "refresh_token" => refresh_token
    } =
      HTTPoison.post!(
        "https://id.twitch.tv/oauth2/token",
        "",
        [],
        params: %{
          "client_id" => get_env(:twitch_client_id),
          "client_secret" => get_env(:twitch_client_secret),
          "code" => code,
          "grant_type" => "authorization_code",
          "redirect_uri" => get_env(:twitch_redirect_uri)
        }
      )
      |> decode_body()

    [
      %{
        "login" => current_user
      }
    ] =
      HTTPoison.get!("https://api.twitch.tv/helix/users", [
        {"Authorization", "Bearer #{access_token}"},
        {"Client-ID", get_env(:twitch_client_id)}
      ])
      |> decode_body()
      |> Map.get("data")

    conn
    |> Conn.put_session(:access_token, access_token)
    |> Conn.put_session(:refresh_token, refresh_token)
    |> Conn.put_session(:current_user, current_user)
    |> Controller.redirect(to: "/play")
    |> Conn.halt()
  end

  def redirect_if_authenticated(conn, _params) do
    case attempt_token_refresh(conn) do
      {:error} ->
        conn

      {:ok, conn} ->
        conn
        |> Controller.redirect(to: "/play")
        |> Conn.halt()
    end
  end

  def authenticated(conn, _params) do
    case attempt_token_refresh(conn) do
      {:error} ->
        conn
        |> delete_session()
        |> Controller.redirect(to: "/")
        |> Conn.halt()

      {:ok, conn} ->
        conn
    end
  end

  defp attempt_token_refresh(conn) do
    try do
      old_refresh_token = Conn.get_session(conn, :refresh_token)

      %{
        "access_token" => access_token,
        "refresh_token" => refresh_token
      } =
        HTTPoison.post!(
          "https://id.twitch.tv/oauth2/token",
          "",
          [{"Content-Type", "application/x-www-form-urlencoded"}],
          params: %{
            "grant_type" => "refresh_token",
            "refresh_token" => old_refresh_token,
            "client_id" => get_env(:twitch_client_id),
            "client_secret" => get_env(:twitch_client_secret)
          }
        )
        |> decode_body()

      {:ok,
       conn
       |> Conn.put_session(:access_token, access_token)
       |> Conn.put_session(:refresh_token, refresh_token)}
    rescue
      _ -> {:error}
    end
  end

  defp delete_session(conn),
    do:
      conn
      |> Conn.delete_session(:access_token)
      |> Conn.delete_session(:refresh_token)
      |> Conn.delete_session(:current_user)
end
