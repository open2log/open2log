defmodule Open2logWeb.API.V1.AuthController do
  use Open2logWeb, :controller

  alias Open2log.Accounts
  alias Open2log.Accounts.User

  action_fallback Open2logWeb.FallbackController

  def register(conn, %{"email" => email, "password" => password}) do
    case Accounts.register_user(%{email: email, password: password}) do
      {:ok, user} ->
        token = generate_token(user)

        conn
        |> put_status(:created)
        |> render(:auth_response, user: user, token: token)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = generate_token(user)
        render(conn, :auth_response, user: user, token: token)

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  defp generate_token(%User{id: id}) do
    Phoenix.Token.sign(Open2logWeb.Endpoint, "user auth", id)
  end
end
