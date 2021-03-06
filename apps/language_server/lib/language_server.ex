defmodule ElixirLS.LanguageServer do
  @moduledoc """
  Implementation of Language Server Protocol for Elixir
  """
  require Logger
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(ElixirLS.LanguageServer.Server, [ElixirLS.LanguageServer.Server]),
      worker(ElixirLS.LanguageServer.JsonRpc, [[name: ElixirLS.LanguageServer.JsonRpc]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirLS.LanguageServer.Supervisor, max_restarts: 0]
    Supervisor.start_link(children, opts)
  end

  def stop(_state) do
    # VS Code, unfortunately, disappears the "Output" pane if the server terminates so we can't see
    # an error message, so we can't kill the VM... We attempt to show an error message instead.
    if ElixirLS.Utils.WireProtocol.io_intercepted?() do
      ElixirLS.LanguageServer.JsonRpc.show_message(
        :error,
        "ElixirLS has crashed. See Output panel."
      )
    end

    :ok
  end
end
