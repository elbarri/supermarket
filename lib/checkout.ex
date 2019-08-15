defmodule Checkout do
  alias Checkout.Server

  @moduledoc """
  API for Checkout.

  Helpers for the pricing rules can be found in prive/rules.ex

  ## Example
    iex> pr = %PricingRules{discount_type: :buy_n_get_x_free, 
    ...>threshold: 2, 
    ...>operand: 1,
    ...>product_codes: ["GR1"]}
    iex> pid = Checkout.new(pr)
    iex> Checkout.scan(pid, "GR1")
    :ok
    iex> Checkout.total(pid)
    "£3.11"
    iex> Checkout.scan(pid, "GR1")
    :ok
    iex> Checkout.total(pid)
    "£3.11"
  """

  @doc """
  Creates a process that deals with a purchase and manages price discounts
  """
  def new(%PricingRules{} = pricing_rules) do
    new([pricing_rules])
  end

  @doc """
  Creates a process that deals with a purchase and manages price discounts

  ## Example
    iex> pid = Checkout.new([])
    iex> Checkout.scan(pid, "GR1")
    :ok
    iex> Checkout.scan(pid, "GR1")
    :ok
    iex> Checkout.total(pid)
    "£6.22"
  """
  def new(pricing_rules) when is_list(pricing_rules) do
    child_spec = %{
      id: Server,
      start: {Server, :start_link, [pricing_rules]}
    }

    {:ok, pid} = DynamicSupervisor.start_child(Cashier.Supervisor, child_spec)
    pid
  end

  @doc """
  Registers one new item to purchase.

  ## Example
    iex> pid = Checkout.new([])
    iex> Checkout.scan(pid, "GR1")
    :ok
    iex> Checkout.scan(pid, "AAAA")
    {:error, "Product not found."}
  """
  def scan(chashier_pid, item) do
    product = GenServer.call(chashier_pid, {:scan, item})

    case is_nil(product) do
      false -> :ok
      true -> {:error, "Product not found."}
    end
  end

  @doc """
  Returns total amount after applying discounts

  ## Example
    iex> pid = Checkout.new([])
    iex> Checkout.total(pid)
    "£0.00"
  """
  def total(chashier_pid) do
    GenServer.call(chashier_pid, {:total})
    |> Money.to_string()
  end
end
