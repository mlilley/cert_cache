defmodule CertCache.FileProvider do
  @moduledoc """
  Loads certs from the filesystem.
  """

  def load(identifier) do
    File.read!(identifier)
  end

end
