defmodule CertCache do
  @name __MODULE__
  @provider CertCache.FileProvider

  @moduledoc """
  In-memory cache for certificates.
  """

  def start_link(opts \\ []) do
    IO.puts "CertCache.start_link() #{inspect(opts)}"
    opts = Keyword.put_new(opts, :name, @name)
    Agent.start_link(fn -> %{} end, name: opts[:name])
  end

  @doc """
  Returns cert from cache (if previous got), otherwise loads it from filesystem.
  Certs are returned in DER format.  If cert does not exist, File.Error is
  raised.
  """
  def get(filename, opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    opts = Keyword.put_new(opts, :provider, @provider)
    case get_from_cache(opts[:name], filename) do
      nil  -> fetch(filename, opts)
      cert -> cert
    end
  end

  @doc """
  Loads a cert from filesystem (regardless of whether its in the cache or not).
  Cache is updated with the loaded cert.  If cert does not exist, File.Error is
  raised.
  """
  def fetch(filename, opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    opts = Keyword.put_new(opts, :provider, @provider)
    cert = get_from_system(opts[:provider], filename)
    Agent.update(opts[:name], fn cache -> Map.put(cache, filename, cert) end)
    cert
  end

  defp get_from_system(provider, filename) do
    filename
      |> provider.load
      |> convert
  end

  defp get_from_cache(name, filename) do
    Agent.get(name, fn cache -> Map.get(cache, filename) end)
  end

  defp convert(pem) do
    :public_key.pem_decode(pem)
  end
end
