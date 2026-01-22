defmodule Open2logWeb.Router do
  use Open2logWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Open2logWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug Open2logWeb.Plugs.AuthenticateAPI
  end

  scope "/", Open2logWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Public API - no auth required
  scope "/api/v1", Open2logWeb.API.V1 do
    pipe_through :api

    # Auth
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login

    # Public product search
    get "/products", ProductController, :index
    get "/products/:id", ProductController, :show

    # Shops
    get "/shops", ShopController, :index
    get "/shops/nearby", ShopController, :nearby
  end

  # Protected API - requires auth
  scope "/api/v1", Open2logWeb.API.V1 do
    pipe_through :api_auth

    # Price submissions
    post "/prices", PriceController, :create
    get "/prices/upload_url", PriceController, :upload_url

    # Product matching votes
    post "/products/:id/match", ProductMatchController, :vote

    # User profile
    get "/me", UserController, :show
    put "/me", UserController, :update

    # Shopping lists (for NGO members)
    resources "/shopping_lists", ShoppingListController, except: [:new, :edit]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:open2log, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Open2logWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
