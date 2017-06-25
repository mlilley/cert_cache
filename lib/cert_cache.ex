defmodule CertCache do
  @moduledoc """
  A certificate cache.

  NOTE: Currently, certificates must be stored on disk in PEM format.
  """

  @name __MODULE__
  alias CertCache.FileCertProvider

  @doc """
  """
  def start_link(base_dir) do
    initial_state = {base_dir, Map.new}
    Agent.start_link(fn -> initial_state end, name: @name)
  end

  @doc """
  Certs are loaded from disk on first get, and from cache then after, unless
  false is passed for the cached param.

  Raises File.Error if requested cert file is not found.

  Certs are returned in DER format. Pass them directly to erlang ssl via the
  cert/cacerts/key options instead of passing filenames via the
  certfile/cacertfile/keyfile options.

  ex: (hackney)
  ```
  mycert = CertCache.get_cert("cert.pem")
  :hackney.get(url, ssl_options: [ cacerts: [ mycert ] ])
  ```

  ex: (HTTPoison)
  ```
  mycert = CertCache.get_cert("cert.pem")
  HTTPoison.get(url, ssl: [ cacerts: [ mycert ] ])
  ```
  """
  def get_cert(filename, cached \\ true) do
    if not cached do
      load_cert_from_provider(filename)
    else
      case find_cert_in_cache(filename) do
        nil  -> load_cert_from_provider(filename)
        cert -> cert
      end
    end
  end

  defp find_cert_in_cache(filename) do
    Agent.get(@name, fn state -> Map.get(Kernel.elem(state, 1), filename) end)
  end

  defp load_cert_from_provider(filename) do
    base_path = Agent.get(@name, fn state -> Kernel.elem(state, 0) end)
    cert = FileCertProvider.load_cert(filename, base_path)
    Agent.update(@name, fn state -> {
      base_path, Map.put(Kernel.elem(state, 1), filename, cert)
    } end)
    cert
  end
end
