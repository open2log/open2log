defmodule Open2logWeb.API.V1.PriceController do
  use Open2logWeb, :controller

  alias Open2log.Products

  action_fallback Open2logWeb.FallbackController

  def create(conn, params) do
    user = conn.assigns.current_user

    price_params =
      params
      |> Map.put("user_id", user.id)
      |> Map.put("source", "user_scanned")

    case Products.create_price(price_params) do
      {:ok, price} ->
        conn
        |> put_status(:created)
        |> render(:show, price: price)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end

  @doc """
  Generate a presigned URL for uploading images to R2.
  """
  def upload_url(conn, %{"filename" => filename, "content_type" => content_type, "upload_type" => upload_type}) do
    # Call the Cloudflare Worker to get presigned URL
    case generate_upload_url(filename, content_type, upload_type) do
      {:ok, response} ->
        json(conn, response)

      {:error, reason} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Failed to generate upload URL: #{reason}"})
    end
  end

  def upload_url(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "filename, content_type, and upload_type required"})
  end

  defp generate_upload_url(filename, content_type, upload_type) do
    worker_url = Application.get_env(:open2log, :image_upload_worker_url)

    body = Jason.encode!(%{
      filename: filename,
      content_type: content_type,
      upload_type: upload_type
    })

    case Req.post(worker_url, body: body, headers: [{"content-type", "application/json"}]) do
      {:ok, %{status: 200, body: response}} ->
        {:ok, response}

      {:ok, %{status: status, body: body}} ->
        {:error, "HTTP #{status}: #{inspect(body)}"}

      {:error, error} ->
        {:error, inspect(error)}
    end
  end
end
