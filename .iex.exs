alias Bander, as: B
alias Bandit, as: Bt

alias Helper, as: Helper

## Client
alias Req, as: R
alias Mint, as: M
alias Minter, as: Mc
alias Minter.Ws, as: Ws

alias ThousandIsland, as: T
alias ThousandIsland.Server, as: Ts
alias ThousandIsland.ServerConfig, as: Tsc
alias ThousandIsland.Listener, as: Tl

alias Kland, as: K

alias ProcessHelper, as: Ph
alias AppHelper, as: Ah

alias Pkey, as: Pk


if Code.ensure_loaded?(Mix) do
  # if in Mix available
  # Mix.Local.append_archives()
  ## Add ehelper into beam code path
  Mix.path_for(:archives)
  |> Path.join("ehelper*/ehelper*")
  |> Path.wildcard()
  |> Enum.map(fn p ->
      ebin_path = Path.join(p, "ebin")
      Code.append_path(ebin_path, cache: true)
  end)
  # :code.get_path()|> Enum.map(&to_string/1)|> Enum.sort()
  Ehelper.start!()
else
  raise "Mix and ehelper not loaded"
end

import Ehelper.Iex
# Eh.hi
alias Ehelper, as: Eh
alias Ehelper, as: H
