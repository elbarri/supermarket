defmodule PricingRules do
  @moduledoc "false"
  @enforce_keys [:discount_type, :threshold, :operand]
  defstruct [:discount_type, :threshold, :operand, :product_codes]
end
