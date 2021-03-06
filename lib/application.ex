# defmodule CertCache.Application do
#   use Application

#   @moduledoc """
#   CertCache startup functions.  See README.md for how to use CertCache in
#   your project.
#   """

#   @doc """
#   Invoked when parent application starts CertCache from extra_applications
#   option.  Requires base_dir to be defined in config.
#   """
#   def start(_type, _args) do
#     IO.puts "CertCache.Application.start()"
#     base_dir = Application.get_env(:cert_cache, :base_dir)
#     if base_dir == nil do
#       raise ArgumentError, "missing required configuration for base_dir"
#     end
#     CertCache.start_link(base_dir)
#   end

#   @doc """
#   Invoked when parent application starts CertCache from it's application
#   callback.  Pass base_dir via the call to CertCache.start_link() in parent
#   app's application start callback.
#   """
#   def start_link(base_dir) do
#     IO.puts "CertCache.Application.start_link() #{base_dir}"
#     CertCache.start_link(base_dir)
#   end
# end
