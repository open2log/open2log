defmodule Open2logWeb.API.V1.UserController do
  use Open2logWeb, :controller

  alias Open2log.Accounts

  action_fallback Open2logWeb.FallbackController

  def show(conn, _params) do
    user = conn.assigns.current_user
    render(conn, :show, user: user)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    with {:ok, user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end
end
