defmodule Checkout.Server do
  alias Checkout.Cashier

  use GenServer

  def start_link(pricing_rules) do
    GenServer.start_link(__MODULE__, pricing_rules)
  end

  def init(pricing_rules) do
    {:ok, Cashier.new_with(pricing_rules)}
  end

  def handle_call({:scan, item}, _from, basket) do
    {basket, product} = Cashier.scan(basket, item)
    {:reply, product, basket}
  end

  def handle_call({:total}, _from, basket) do
    total = Cashier.total(basket)
    {:reply, total, basket}
  end
end
