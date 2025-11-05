defmodule Bander.JokeError do
  @moduledoc """
  iex>  Plug.Exception.status %TeapotJoke{message: "test teapot"}
  """

  # defexception message: nil , plug_status: :im_a_teapot
  defexception message: nil

  defimpl Plug.Exception do
    def status(_), do: :im_a_teapot
    def actions(_), do: []
  end
end
