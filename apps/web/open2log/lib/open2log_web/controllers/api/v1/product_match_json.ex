defmodule Open2logWeb.API.V1.ProductMatchJSON do
  alias Open2log.Products.ProductMatch

  def show(%{match: match}) do
    %{data: data(match)}
  end

  defp data(%ProductMatch{} = match) do
    %{
      id: match.id,
      physical_product_id: match.physical_product_id,
      online_product_id: match.online_product_id,
      vote: match.vote,
      inserted_at: match.inserted_at
    }
  end
end
