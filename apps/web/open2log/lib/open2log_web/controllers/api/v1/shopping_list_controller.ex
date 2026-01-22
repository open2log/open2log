defmodule Open2logWeb.API.V1.ShoppingListController do
  @moduledoc """
  Shopping lists for NGO members.
  Local lists stored in DuckDB, shared lists sync via Cloudflare D1.
  """
  use Open2logWeb, :controller

  action_fallback Open2logWeb.FallbackController

  def index(conn, _params) do
    user = conn.assigns.current_user

    case check_membership(user) do
      :ok ->
        # TODO: fetch from local DB + sync with D1
        lists = []
        render(conn, :index, shopping_lists: lists)

      {:error, :not_member} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Shopping lists require NGO membership"})
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with :ok <- check_membership(user),
         {:ok, list} <- fetch_list(user, id) do
      render(conn, :show, shopping_list: list)
    end
  end

  def create(conn, %{"shopping_list" => params}) do
    user = conn.assigns.current_user

    with :ok <- check_membership(user),
         {:ok, list} <- create_list(user, params) do
      conn
      |> put_status(:created)
      |> render(:show, shopping_list: list)
    end
  end

  def update(conn, %{"id" => id, "shopping_list" => params}) do
    user = conn.assigns.current_user

    with :ok <- check_membership(user),
         {:ok, list} <- fetch_list(user, id),
         {:ok, updated} <- update_list(list, params) do
      render(conn, :show, shopping_list: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with :ok <- check_membership(user),
         {:ok, list} <- fetch_list(user, id),
         {:ok, _} <- delete_list(list) do
      send_resp(conn, :no_content, "")
    end
  end

  # Private

  defp check_membership(%{membership_status: :active}), do: :ok
  defp check_membership(_), do: {:error, :not_member}

  # TODO: implement with actual DB queries
  defp fetch_list(_user, _id), do: {:error, :not_found}
  defp create_list(_user, _params), do: {:error, :not_implemented}
  defp update_list(_list, _params), do: {:error, :not_implemented}
  defp delete_list(_list), do: {:error, :not_implemented}
end
