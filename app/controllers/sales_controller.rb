# frozen_string_literal: true

class SalesController < ApplicationController
  before_action :authenticate_user!

  def index; end
end
