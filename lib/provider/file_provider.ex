defmodule CertCache.FileProvider do
  @moduledoc """
  Loads certs from the filesystem.
  """

  @behaviour CertCache.Provider

  def load_cert(filename, base_path) do
    base_path
    |> Path.join(filename)
    |> Path.expand
    |> File.read!
    |> :public_key.pem_decode
  end
end
