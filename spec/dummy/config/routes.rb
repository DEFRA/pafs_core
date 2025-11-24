# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect("/pafs")
  mount PafsCore::Engine => "/pafs"
end
