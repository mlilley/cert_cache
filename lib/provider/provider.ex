defmodule CertCache.Provider do
  @moduledoc """
  Behaviour definition for certificate Providers
  """

  @callback load_cert(filename :: String.t, base_path ::String.t) :: any
end
