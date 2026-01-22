defmodule Open2logWeb.Plugs.AuthenticateAPI do
  @moduledoc """
  Plug to authenticate API requests using Bearer token.
  """
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- verify_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or missing authentication token"})
        |> halt()
    end
  end

  defp verify_token(token) do
    # Simple token verification - in production use Phoenix.Token or JWT
    case Phoenix.Token.verify(Open2logWeb.Endpoint, "user auth", token, max_age: 86400 * 30) do
      {:ok, user_id} ->
        case Open2log.Repo.get(Open2log.Accounts.User, user_id) do
          nil -> {:error, :not_found}
          user -> {:ok, user}
        end

      {:error, _reason} ->
        {:error, :invalid_token}
    end
  end
end
