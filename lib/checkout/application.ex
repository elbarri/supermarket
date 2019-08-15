defmodule Checkout.Application do
  use Application

  def start(_type, _args) do
    options = [
      name: Cashier.Supervisor,
      strategy: :one_for_one
    ]

    DynamicSupervisor.start_link(options)

    children = [
      {Checkout.Catalog, []}
    ]

    options = [
      name: Catalog.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, options)
  end
end
