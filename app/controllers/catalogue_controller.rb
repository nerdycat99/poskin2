# frozen_string_literal: true

class CatalogueController < ApplicationController
  before_action :authenticate_user!
  def index; end
end
