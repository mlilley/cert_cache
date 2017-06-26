# CertCache

A certificate cache for Elixir / Pheonix.

## Installation

Add cert_cache to your dependencies:

```elixir
def deps do
  [{:cert_cache, "~> 0.1.0"}]
end
```

Then run:

```bash
$ mix deps.get
```

## Startup

CertCache supports two methods of being started.

1. Via extra_applications in parent app's mix.exs.

   Use this method when it is sufficient to configure base_dir from config
   files (ie: using a value that is fixed at compile time). Ex:

   Reference CertCache in your mix.exs as usual:

   ```elixir
   def application do
     [ extra_applications: [ :logger, :cert_cache ]
   end
   ```

   And configure base_dir in your configuration file(s):

   ```elixir
   config :cert_cache, base_dir: "path/to/certs"
   ```

2. Via application callback.

   Use this method when base_dir must be set to a value determined at
   run-time (ie: when specified in an environment variable that may change
   between runs).  Ex:

   Reference CertCache in your mix.exs via the included_applications option:

   ```elixir
   def application do
     [
       mod: { MyApp.Application: []}
       extra_applications: [ :logger ],
       included_applications: [ :cert_cache ]
     ]
   end
   ```

   Then manually start CertCache from your app's Application start callback,
   passing the desired run-time detemined value for base_dir:

   ```elixir
   defmodule MyApp.Application do
     use Application
     def start(_type, _args) do
       import Supervisor.Spec
       base_dir = System.get_env("CERT_BASE_DIR")
       children = [worker(CertCache, [{:base_dir, base_dir}])]
       {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
     end
   end
   ```

Note that path/to/certs is relative to the parent application's root
directory.

## Usage

Note:

* filename is relative to base_dir
* certs must be in PEM format

```elixir
CertCache.get_cert("filename.pem")
```

TODO: examples for HTTPoison, hackney, etc

# License

MIT
