# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :authenticate_user!

  def index; end

  # create new order
    # option to create new customer / search for existing / transaction as a guest
  # search for product/variant and add to order
  # option to remove things from order as well
  # confirm order / order complete
  # record payment method > confirm payment taken
  # option to print receipt or email > if customer then use email but option to overide
                                    #> if not customer enter email
  # done, back to sales index

  # text box to insert the sku code
  # route to find the sku code, if found show it
  #
end
