defimpl Plug.Exception, for: WebSockAdapter.UpgradeError do
  # https://hexdocs.pm/plug/1.18.1/Plug.Conn.Status.html#code/1-known-status-codes
  # :upgrade_required - 426
  # :precondition_required - 428
  def status(_), do: :upgrade_required

  def actions(_), do: []
end
