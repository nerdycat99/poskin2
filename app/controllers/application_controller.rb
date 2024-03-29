# frozen_string_literal: true

class ApplicationController < ActionController::Base

  protected

  def remember_page
    session[:previous_pages] ||= []
    new_page = url_for(params.to_unsafe_h)
    return unless session[:previous_pages].last != new_page

    session[:previous_pages] << new_page if request.get?
    session[:previous_pages] = session[:previous_pages].last(2)
  end
end
