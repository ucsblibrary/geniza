# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "routes for static files from CSV", type: :request do
  it "loads static images from the configured directory" do
    get "/blake_image.jpg"
    expect(response.code).to eq "200"
  end
end
