prs = [
  %PricingRules{
    discount_type: :buy_n_get_x_free,
    threshold: 2,
    operand: 1,
    product_codes: ["GR1"]
  },
  %PricingRules{
    discount_type: :proportional,
    threshold: 3,
    operand: 0.10,
    product_codes: ["SR1"]
  },
  %PricingRules{
    discount_type: :proportional,
    threshold: 3,
    operand: 1 / 3,
    product_codes: ["CF1"]
  }
]
