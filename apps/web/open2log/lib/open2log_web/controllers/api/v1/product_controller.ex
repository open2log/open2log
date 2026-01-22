defmodule Open2logWeb.API.V1.ProductController do
  use Open2logWeb, :controller

  alias Open2log.Products

  action_fallback Open2logWeb.FallbackController

  def index(conn, params) do
    products =
      case params do
        %{"q" => query} ->
          Products.search(query, Map.get(params, "limit", "20") |> String.to_integer())

        %{"ean" => ean} ->
          [Products.get_by_ean(ean)] |> Enum.filter(& &1)

        _ ->
          Products.list_recent(Map.get(params, "limit", "20") |> String.to_integer())
      end

    render(conn, :index, products: products)
  end

  def show(conn, %{"id" => id}) do
    case Products.get(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Product not found"})

      product ->
        render(conn, :show, product: product)
    end
  end
end
