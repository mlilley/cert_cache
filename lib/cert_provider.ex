defmodule CertCache.CertProvider do
  @moduledoc """
  Behaviour definition for CertProviders
  """

  @callback load_cert(filename :: String.t, base_path ::String.t) :: any
end
