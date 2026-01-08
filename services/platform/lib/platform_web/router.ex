defmodule PlatformWeb.Router do
  use PlatformWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    # Todo
  end

  # --- Public routes ---
  scope "/", PlatformWeb do
    pipe_through :api

    get "/", HealthController, :health
    post "/login", SessionController, :login
    post "/register", UserController, :create
  end

  # Todo: Other scope for private?
  # --- Private routes ---
  scope "/", PlatformWeb do
    pipe_through [:api, :auth]

    get "/me", UserController, :me
    post "/logout", SessionController, :logout
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:platform, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PlatformWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
