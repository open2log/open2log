defmodule Open2logWeb.API.V1.ShoppingListJSON do
  def index(%{shopping_lists: lists}) do
    %{data: Enum.map(lists, &data/1)}
  end

  def show(%{shopping_list: list}) do
    %{data: data(list)}
  end

  defp data(list) do
    %{
      id: list.id,
      name: list.name,
      items: list.items,
      shared: list.shared,
      inserted_at: list.inserted_at,
      updated_at: list.updated_at
    }
  end
end
