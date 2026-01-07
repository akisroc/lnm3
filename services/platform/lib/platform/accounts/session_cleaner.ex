defmodule Platform.Accounts.SessionCleaner do
  @moduledoc """
  GenServer that periodically cleans up expired sessions from the database.
  """
  use GenServer
  require Logger

  @cleanup_interval :timer.hours(12)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Schedule the first cleanup
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    clean_expired_sessions()
    schedule_cleanup()
    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_interval)
  end

  defp clean_expired_sessions do
    case Platform.Accounts.Session.delete_expired_sessions() do
      {:ok, count} when count > 0 ->
        Logger.info("Cleaned up #{count} expired session(s)")

      {:ok, 0} ->
        Logger.debug("No expired sessions to clean up")

      {:error, reason} ->
        Logger.error("Failed to clean up expired sessions: #{inspect(reason)}")
    end
  end
end
