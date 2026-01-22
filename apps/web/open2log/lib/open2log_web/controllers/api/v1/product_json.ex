defmodule Open2logWeb.API.V1.ProductJSON do
  alias Open2log.Products.Product

  def index(%{products: products}) do
    %{data: for(product <- products, do: product_data(product))}
  end

  def show(%{product: product}) do
    %{data: product_data(product)}
  end

  defp product_data(%Product{} = product) do
    %{
      id: product.id,
      ean: product.ean,
      sku: product.sku,
      name: product.name,
      brand: product.brand,
      description: product.description,
      category: product.category,
      unit_size: product.unit_size,
      unit_type: product.unit_type,
      image_url: product.image_url,
      source: product.source,
      match_confidence: product.match_confidence,
      vote_count: product.vote_count
    }
  end
end
